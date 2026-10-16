#!/bin/bash

source ./find_tomcat.sh

echo "WEB-06 웹 서비스 상위 디렉터리 접근 제한 설정"

VULN=0

for FILE in "$CONF_DIR/context.xml" "$SERVER_XML" "$TOMCAT_BASE"/webapps/*/META-INF/context.xml; do
    [ -f "$FILE" ] || continue

    if awk -v RS='<!--|-->' 'NR%2' "$FILE" | grep -qi 'allowLinking=“true”' ; then
        echo "allowlinking=true: $FILE"
        VULN=1
    fi
done

if [ "$VULN" -eq 1 ]; then
    echo "취약: 심볼릭 링크를 통해 상위 디렉터리 접근이 허용되어 있습니다."
    exit 1
else
    echo "양호: 심볼릭 링크 사용이 제한되어 있습니다."
    exit 0
fi