#!/bin/bash

source ./find_tomcat.sh

echo "WEB-01 Default 관리자 계정명 변경"

VULN_STATUS=0

if [ ! -f "$TOMCAT_USERS_XML" ]; then
    echo "$TOMCAT_USERS_XML 파일이 존재하지 않습니다."
    exit 2
fi

if awk -v RS='<!--|-->' 'NR%2' "$TOMCAT_USERS_XML" | grep -q -IE 'username="(root|admin|tomcat|manager)"' ; then
    VULN_STATUS=1

fi

if [ "$VULN_STATUS" -eq 1 ]; then
    echo "취약: 계정명이 기본 계정명으로 설정되어 있습니다."
    echo "경로 : $TOMCAT_USERS_XML 입니다."
else 
    echo "양호: 기본 관리자 계정이 사용되고 있지 않습니다."
fi
