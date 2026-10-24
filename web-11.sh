#!/bin/bash

source ./find_tomcat.sh

echo "WEB-11 웹 서비스 경로 설정"

VULN=0

CONF=$(awk -v RS='<!--|-->' 'NR%2' "$SERVER_XML")
APP_BASE=$(echo "$CONF" | grep -o 'appBase="[^"]*"' | cut -d '"' -f2)
DOC_BASE=$(echo "$CONF" | grep -o 'docBase="[^"]*"' | cut -d '"' -f2)

echo " appBase: ${APP_BASE:-없음}"
echo " docBase: ${DOC_BASE:-없음}"

BASE_DEFAULT=0

case "$APP_BASE" in (webapps|./webapps|'${catalina.base}/webapps'|"$TOMCAT_BASE/webapps"|"$TOMCAT_HOME/webapps") BASE_DEFAULT=1 ;;
esac

if [ -z "$DOC_BASE" ] && [ "$BASE_DEFAULT" -eq 1 ]; then
    echo "기본 경로를 웹 서비스 경로로 사용 중"
    VULN=1
fi

if [ "$VULN" -eq 1 ]; then
    echo "취약: 웹 서비스 경로가 영역 분리가 되어 있지 않습니다."
    echo "$SERVER_XML"
    exit 1
else
    echo "양호: 웹 서비스 경로가 별도의 경로로 분리 되어 있습니다."
    exit 0
fi