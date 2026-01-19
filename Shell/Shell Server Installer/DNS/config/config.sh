#!/bin/bash

# DNS config


Localhost() {
	if locate named.localhost > /dev/null 2>&1; then
		read -p "정방향 설정 파일이 존재합니다. 설정하시겠습니까?[y/n]" Choice
	else
		Update
	fi
}

Loopback() {
	if locate named.loopback > /dev/null 2>&1; then
		read -p "역방향 설정 파일이 존재합니다. 설정하시겠습니까?[y/n]" Choice
	else
		Update
	fi
}

Update() {
	read -p "파일이 존재하지 않습니다. 검색 목록을 최신화 하시습니까?[y/n]" Choice
	case $Choice in
		Y|y)
			echo "검색 목록을 최신화 후 재검색합니다."
			updatedb
			if [[ $Config -eq 1 ]]; then
				Localhost
			else
				Loopback
			fi
			;;
		N|n)
			echo "프로그램을 종료합니다."
			exit 0
			;;
		*)
			echo "잘못 입력하셨습니다."
			;;
	esac
}

Config() {
	echo "----- DNS 설정 프로그램을 실행합니다."
	echo "1. 정방향 DNS 설정"
	echo "2. 역방향 DNS 설정"
	read -p "----- 메뉴를 선택해주세요: " Choice
	case $Choice in
		1)
			Localhost
			;;
		2)
			Loopback
			;;
		*)
			echo "잘못 선택하셨습니다."
			;;
	esac
}
