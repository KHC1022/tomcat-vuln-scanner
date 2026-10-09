#!/bin/bash

source ./find_tomcat.sh

echo "WEB-02 취약한 비밀번호 사용 제한"

if [ ! -f "$TOMCAT_USERS_XML" ]; then
    echo "$TOMCAT_USERS_XML 파일이 존재하지 않습니다."
    exit 2
fi

if grep -q "CredentialHandler" "$SERVER_XML"; then
    echo "수동 점검: 비밀번호가 해시로 저장되어 있어 복잡도를 자동으로 확인할 수 없습니다."
    exit 2
fi

WEAK_LIST="admin admin123 administrator password password123 123456 12345678 123456789 1234567890 qwerty qwerty123 abc123 111111 000000 123123 1q2w3e4r P@ssw0rd Password1 changeme root
tomcat tomcat123 manager manager123 test test123 guest <must-be-changed>"
VULN=0

USERS=$(awk -v RS='<!--|-->' 'NR%2' "$TOMCAT_USERS_XML" | grep -oE '<user [^>]*>')

while read -r LINE; do
    [ -z "$LINE" ] && continue
    NAME=$(echo "$LINE" | sed -nE 's/.*username="([^"]*)".*/\1/p')
    PASS=$(echo "$LINE" | sed -nE 's/.*password="([^"]*)".*/\1/p')

    TYPES=0
    echo "$PASS" | grep -q '[A-Za-z]' && TYPES=$((TYPES+1))
    echo "$PASS" | grep -q '[0-9]' && TYPES=$((TYPES+1))
    echo "$PASS" | grep -q '[^A-Za-z0-9]' && TYPES=$((TYPES+1))

    REASON=""
    if [ -z "$PASS" ]; then
        REASON="비밀번호 미설정"
    elif [ "$PASS" = "$NAME" ]; then
        REASON="계정명과 동일"
    elif echo " $WEAK_LIST " | grep -qi " $PASS "; then
        REASON="기본/추측 가능한 비밀번호"
    elif ! { [ "$TYPES" -ge 3 ] && [ ${#PASS} -ge 8 ]; } && ! { [ "$TYPES" -ge 2 ] && [ ${#PASS} -ge 10 ]; }; then
        REASON="복잡도 부족 (${TYPES}종류, ${#PASS}자리)"
    fi

    if [ -n "$REASON" ]; then
        echo "  - 계정 '$NAME': $REASON"
        VULN=1
    fi
done <<< "$USERS"

if [ -z "$USERS" ]; then
    echo "양호: 등록된 계정이 없습니다."
    exit 0
elif [ "$VULN" -eq 1 ]; then
    echo "취약: 취약한 비밀번호를 사용하는 계정이 있습니다."
    echo "경로: $TOMCAT_USERS_XML"
    exit 1
else
    echo "양호: 모든 계정이 비밀번호 복잡도 기준을 만족합니다."
    exit 0
fi