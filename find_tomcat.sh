#!/bin/bash

get_tomcat_home(){
    local tomcat_PATH=$(ps -ef | grep java | grep tomcat | awk -F "-Dcatalina.home=" '{print $2}' | awk '{print $1}')
    if [ -n "$tomcat_PATH" ] && [ -d "$tomcat_PATH" ]; then
        echo "$tomcat_PATH"
        return
    fi

    if [ -n "$CATALINA_HOME" ] && [ -d "$CATALINA_HOME" ]; then
    echo "$CATALINA_HOME"
    return
    fi
    
    echo "NOT FOUND"
}

TOMCAT_DIR=$(get_tomcat_home)
if [ "$TOMCAT_DIR" = "NOT FOUND" ]; then
    echo "[-] tomcat의 경로를 찾을 수 없어서 수동 점검을 해야합니다."
    exit 1
else
    echo "[+] tomcat의 설치 경로는 $TOMCAT_DIR 입니다"
fi