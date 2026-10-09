#!/bin/bash

get_tomcat_home(){
    local PROC=$(ps -ef | grep "org.apache.catalina.startup.Bootstrap" | grep -v grep | head -n1)
    local CHECK_TOMCAT_HOME=$(echo "$PROC" | awk -F "-Dcatalina.home=" '{print $2}' | awk '{print $1}')
    local CHECK_TOMCAT_BASE=$(echo "$PROC" | awk -F "-Dcatalina.base=" '{print $2}' | awk '{print $1}')

    if [ -n "$CHECK_TOMCAT_HOME" ] && [ -d "$CHECK_TOMCAT_HOME" ]; then
        echo "$CHECK_TOMCAT_HOME|${CHECK_TOMCAT_BASE:-$CHECK_TOMCAT_HOME}"
        return
    fi

    if [ -n "$CATALINA_HOME" ] && [ -d "$CATALINA_HOME" ]; then
        echo "$CATALINA_HOME|${CATALINA_BASE:-$CATALINA_HOME}"
        return
    fi

    echo "NOT FOUND"
}

TOMCAT_DIR=$(get_tomcat_home)
if [ "$TOMCAT_DIR" = "NOT FOUND" ]; then
    echo "[-] Tomcat 경로를 찾을 수 없어서 수동 점검을 해야 합니다."
    exit 1
fi

TOMCAT_HOME=$(echo "$TOMCAT_DIR" | cut -d'|' -f1)
TOMCAT_BASE=$(echo "$TOMCAT_DIR" | cut -d'|' -f2)

CONF_DIR=""
for dir in "$TOMCAT_BASE/conf" "$TOMCAT_HOME/conf" /etc/tomcat*; do
    if [ -f "$dir/server.xml" ]; then
        CONF_DIR="$dir"
        break
    fi
done

if [ -z "$CONF_DIR" ]; then
    echo "[-] Tomcat 설정 디렉터리를 찾을 수 없습니다."
    exit 1
fi

SERVER_XML="$CONF_DIR/server.xml"
TOMCAT_USERS_XML="$CONF_DIR/tomcat-users.xml"

echo "[+] 설정 디렉터리: $CONF_DIR"
echo "[+] 점검 server.xml: $SERVER_XML"
echo "[+] 점검 tomcat-users.xml: $TOMCAT_USERS_XML"