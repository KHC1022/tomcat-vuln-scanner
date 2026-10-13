#!/bin/bash

source ./find_tomcat.sh

echo "WEB-04 웹 서비스 디렉터리 리스팅 방지 설정"

WEB_XML="$CONF_DIR/web.xml"
if [ ! -f "$WEB_XML" ]; then
    echo "$WEB_XML 파일이 존재하지 않습니다."
    exit 2
fi

VULN=0

for FILE in "$WEB_XML" "$TOMCAT_BASE"/webapps/*/WEB-INF/web.xml; do
    [ -f "$FILE" ] || continue
    
    if awk -v RS='<!--|-->' 'NR%2' "$FILE" | grep -A1 "<param-name>listings</param-name>" | grep -qi "<param-value>true</param-value>"; then
        echo "listings true: $FILE"
        VULN=1
    fi
done

if [ "$VULN" -eq 1 ]; then
    echo "취약: 디렉터리 리스팅이 활성화되어 있습니다."
    exit 1
else
    echo "양호: 디렉터리 리스팅이 비활성화되어 있습니다."
    exit 0
fi