#!/bin/bash -e

IFS= read -r PASS
test -n "$PASS"

hash="$(printf '%s\n' "$PASS" | htpasswd -niBC 10 '' |
    tr -d '\n' | sed 's/\$2y\$/\$2a\$/' | cut -d: -f2)"
sed -i "/passwordHash/s#:.*<#:$hash<#" /var/lib/jenkins/users/admin_*/config.xml
grep -Fq -- "$hash" /var/lib/jenkins/users/admin_*/config.xml

systemctl restart jenkins
