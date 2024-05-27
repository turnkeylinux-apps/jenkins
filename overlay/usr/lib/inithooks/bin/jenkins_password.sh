#!/bin/bash -e

PASS="$1"
shift

hash="$(htpasswd -nbBC 10 '' "$PASS" | tr -d '\n' | sed 's/\$2y\$/\$2a\$/' | cut -d: -f2)"
sed -i "/passwordHash/s#:.*<#:$hash<#" /var/lib/jenkins/users/admin_*/config.xml

systemctl restart jenkins
