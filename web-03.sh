#!/bin/bash

source ./find_tomcat.sh

echo "WEB-03 비밀번호 파일 권한 관리"

if [ ! -f "$TOMCAT_USERS_XML" ]; then
    echo "$TOMCAT_USERS_XML 파일이 존재하지 않습니다."
    exit 2
fi

PERM=$(stat -c %a "$TOMCAT_USERS_XML")

if [ $((8#$PERM & 8#177)) -eq 0 ]; then
    echo "양호: 비밀번호 파일에 권한이 600 이하로 설정된 경우 (권한 : $PERM)"
    exit 0
else
    echo "취약: 비밀번호 파일에 권한이 600 초과로 설정된 경우 (권한 : $PERM)"
    echo "경로: $TOMCAT_USERS_XML"
    exit 1
fi