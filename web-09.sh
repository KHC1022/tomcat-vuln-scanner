#!/bin/bash

source ./find_tomcat.sh

echo "WEB-09 웹 서비스 프로세스 권한 제한"

VULN=0

PROC_USER=$(ps -eo user,args \
    | awk '/[o]rg.apache.catalina.startup.Bootstrap/ {
        print $1 
    }')

if [ -z "$PROC_USER" ]; then
    echo "Tomcat 프로세스를 찾을 수 없습니다."
else
    echo "실행 계정 : $PROC_USER"
    if [ "$PROC_USER" = 'root' ]; then
        echo "취약: Tomcat이 root 권한으로 실행중입니다."
        exit 1
    else
        echo "양호: Tomcat이 root가 아닌 계정으로 실행 중입니다."
        exit 0
    fi
fi

for FILE in /etc/systemd/system/tomcat*.service /lib/systemd/system/tomcat*.service; do
    [ -f "$FILE" ] || continue
    FOUND=1

    SVC_USER=$(grep '^User=' "$FILE" | cut -d'=' -f2)

    if [ -z "$SVC_USER" ] || [ "$SVC_USER" = "root" ]; then
        echo "실행 계정 : $[SVC_USER:-root (User 미설정)] ($FILE)"
        VULN=1
    else
        echo " 실행 계정: $SVC_USER ($FILE)"
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "수동 점검: 실행 중인 프로세스와 서비스 설정 파일이 없어 실행 계정을 확인할 수 없습니다."
    exit 2
elif [ "$FOUND" -eq 1 ]; then
    echo "취약: Tomcat의 권한이 root로 설정되어 있습니다."
    exit 1
else
    echo "양호: Tomcat의 권한이 root가 아닌 계정으로 설정되어 있습니다."
    exit 0
fi