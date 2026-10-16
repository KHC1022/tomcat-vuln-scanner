#!/bin/bash

source ./find_tomcat.sh

echo "WEB-05 지정하지 않은 CGI/ISAPI 실행 제한"

WEB_XML="$CONF_DIR/web.xml"
if [ ! -f "$WEB_XML" ]; then
    echo "$WEB_XML 파일이 존재하지 않습니다."
    exit 2
fi

VULN=0


for FILE in "$WEB_XML" "$TOMCAT_BASE"/webapps/*/WEB-INF/web.xml; do
    [ -f "$FILE" ] || continue
    
    if awk -v RS='<!--|-->' 'NR%2' "$FILE" | grep -q "org.apache.catalina.servlets.CGIServlet"; then
        echo " CGIServlet 활성화 : $FILE"
        VULN=1
    fi
done

if [ "$VULN" -eq 1 ]; then
    echo "취약: CGI가 활성화되어 있습니다."
    exit 1
else
    echo "양호: CGI가 비활성화되어 있습니다."
    exit 0
fi