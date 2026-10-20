#!/bin/bash

source ./find_tomcat.sh

echo "WEB-08 웹 서비스 파일 업로드 및 다운로드 용량 제한"

VULN=0

VALUES=$(awk -v RS='<!--|-->' 'NR%2' "$SERVER_XML" | grep -o 'maxPostSize="[^"]*"' | cut -d'"' -f2)

if [ -z "$VALUES" ]; then
    echo " maxPostSize가 설정되어 있지 않음(Default 2MB로 설정) "
fi

for SIZE in $VALUES; do
    if [ "$SIZE" -lt 0 ]; then
        echo "maxPostSize=$SIZE (용량 제한 없음) "
        VULN=1
    else
        echo "maxPostSize=$SIZE ($((SIZE / 1024 / 1024)) MB )"
    fi
done

if [ "$VULN" -eq 1 ]; then
    echo "취약: 업로드 용량이 제한되어 있지 않습니다."
    echo "경로 : $SERVER_XML"
    exit 1
else
    echo "양호: 업로드 용량이 제한되어 있습니다."
    exit 0
fi