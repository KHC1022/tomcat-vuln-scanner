#!/bin/bash

source ./find_tomcat.sh

echo "WEB-10 웹 서비스 프로세스 권한 제한"

VULN=0

PROXY=$(awk -v RS='<!--|-->' 'NR%2' "$SERVER_XML" | grep -oE "proxyName|proxyPort")

if [ -n "$PROXY" ]; then
    echo "확인 필요 : proxy 관련 설정이 발견되었습니다."
    echo "경로 : $SERVER_XML"
else
    echo "양호 : 불필요한 proxy 설정이 존재하지 않습니다."
fi