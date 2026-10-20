#!/bin/bash

source ./find_tomcat.sh

echo "WEB-07 웹 서비스 경로 내 불필요한 파일 제거"

VULN=0

for DIR in "$TOMCAT_BASE/webapps" "$TOMCAT_HOME/webapps" ; do
    [ -d "$DIR" ] || continue

    for FILE in "docs" "examples" ; do
        if [ -f "$DIR/$FILE" ]; then
            echo "불필요한 파일 : $DIR/$FILE "
            VULN=1
        fi
    done
    [ "$TOMCAT_BASE/webapps" = "$TOMCAT_HOME/webapps" ] && break
done

if [ "$VULN" -eq 1 ]; then
    echo "취약: 기본으로 생성되는 불필요한 파일 및 디렉터리가 존재합니다."
    exit 1
else
    echo "양호: 기본으로 생성되는 불필요한 파일 및 디렉터리가 존재하지 않습니다."
    exit 0
fi