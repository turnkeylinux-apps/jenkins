#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
app_password=${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS is required}
source_file=/usr/local/share/turnkey-jenkins/source
fixture="turnkey-v19-$(date +%s)-$$"
marker="Jenkins-v19-build-$fixture"
work=$(mktemp -d /tmp/jenkins-v19.XXXXXXXX)
job_created=false

json_field() {
    python3 -c '
import json
import sys

value = json.load(sys.stdin)[sys.argv[1]]
if value is None or value is False:
    raise SystemExit(1)
print(value)
' "$1"
}

cat >"$work/netrc" <<EOF
machine 127.0.0.1 login admin password $app_password
EOF

jcurl() {
    curl --insecure --fail --silent --show-error \
        --netrc-file "$work/netrc" "$@"
}

refresh_crumb() {
    local response
    response=$(jcurl https://127.0.0.1/crumbIssuer/api/json)
    crumb_field=$(json_field crumbRequestField <<<"$response")
    crumb=$(json_field crumb <<<"$response")
}

jpost() {
    jcurl --request POST --header "$crumb_field: $crumb" "$@"
}

cleanup() {
    set +e
    if $job_created; then
        refresh_crumb
        jpost "https://127.0.0.1/job/$fixture/doDelete" >/dev/null
    fi
    find "$work" -depth -delete
}
trap cleanup EXIT
trap 'printf "test_failure line=%s status=%s command=%q\n" "$LINENO" "$?" "$BASH_COMMAND" >&2' ERR

for unit in apache2.service jenkins.service postfix.service; do
    systemctl --quiet is-active "$unit"
done
apache2ctl configtest
grep -Fxq 'VERSION_CODENAME=trixie' /etc/os-release
grep -Eq '^turnkey-jenkins-19\.0' /etc/turnkey_version
test -d /usr/share/webmin/apache
test -d /usr/share/webmin/postfix
test -x /usr/local/bin/jenkins-cli
grep -Fxq 'export JENKINS_HOME=/var/lib/jenkins' /root/.bashrc.d/jenkins

# shellcheck disable=SC1090
. "$source_file"
test "$installed_version" = 2.568.2
test "$(dpkg-query -W -f='${Version}' jenkins)" = "$installed_version"
test "$package_sha256" = abaa015c3a39a8182eed136333d6d0ba055564df37584e699cc9693ad64ad7d5
test "$(gpg --show-keys --with-colons /usr/share/keyrings/jenkins-keyring.asc |
    awk -F: '$1 == "fpr" && !found { print $10; found = 1 }')" = \
    "$repository_key_fingerprint"
test ! -e /etc/systemd/system/jenkins.service.d/timeout.conf
jenkins_environment=$(systemctl show --property=Environment --value jenkins.service)
! grep -q 'sun.net.client.default.*Timeout' <<<"$jenkins_environment"
grep -Fq '<url>https://updates.jenkins.io/update-center.json</url>' \
    /var/lib/jenkins/hudson.model.UpdateCenter.xml
java -version 2>&1 | grep -E 'version "21[.]' >/dev/null
git --version
svn --version --quiet
ant -version

test "$(jcurl https://127.0.0.1/api/json | json_field mode)" = NORMAL
whoami=$(jcurl https://127.0.0.1/whoAmI/api/json)
test "$(json_field authenticated <<<"$whoami")" = True
test "$(json_field name <<<"$whoami")" = admin
# shellcheck source=/dev/null
. /root/.bashrc.d/jenkins
test "$(jenkins-cli -auth "admin:$app_password" version)" = "$installed_version"

for plugin in git subversion workflow-scm-step mailer junit; do
    [[ -f /var/lib/jenkins/plugins/$plugin.jpi ||
       -f /var/lib/jenkins/plugins/$plugin.hpi ]]
done

cat >"$work/job.xml" <<EOF
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>TurnKey v19 acceptance fixture</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>printf '%s\n' '$marker'</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

refresh_crumb
jpost --header 'Content-Type: application/xml' \
    --data-binary "@$work/job.xml" \
    "https://127.0.0.1/createItem?name=$fixture" >/dev/null
job_created=true
jpost "https://127.0.0.1/job/$fixture/build" >/dev/null

build_result=
for attempt in {1..60}; do
    if build=$(jcurl "https://127.0.0.1/job/$fixture/lastBuild/api/json" \
        2>/dev/null); then
        build_result=$(json_field result <<<"$build" 2>/dev/null || true)
        [[ -n $build_result ]] && break
    fi
    sleep 2
done
test "$build_result" = SUCCESS
jcurl "https://127.0.0.1/job/$fixture/lastBuild/consoleText" |
    grep -F "$marker" >/dev/null

systemctl restart jenkins.service
for attempt in {1..60}; do
    jcurl "https://127.0.0.1/job/$fixture/api/json" >/dev/null 2>&1 && break
    sleep 2
done
test "$(jcurl "https://127.0.0.1/job/$fixture/api/json" |
    json_field name)" = "$fixture"

jenkins-update --check >"$work/update"
candidate=$(sed -n 's/^candidate=//p' "$work/update")
status=$(sed -n 's/^status=//p' "$work/update")
test -n "$candidate"
grep -Fxq 'channel=official-jenkins-lts-debian' "$work/update"
grep -Fxq "integrity=APT-signed-by-$repository_key_fingerprint" "$work/update"

cat >"$result" <<EOF
package_source=Official Jenkins LTS Debian repository; Debian Trixie OpenJDK 21
installed_version=Jenkins $installed_version; Java 21
runtime_checks=normal init; HTTPS admin login; freestyle job create and successful build; console marker readback; restart persistence; Git, Subversion, Ant, plugins, Postfix, Webmin modules
updater_command=jenkins-update --check
updater_result=$status; candidate=$candidate
updater_channel=official Jenkins LTS Debian
integrity_evidence=repository key $repository_key_fingerprint; package SHA-256 $package_sha256
EOF
