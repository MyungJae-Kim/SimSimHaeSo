#!/bin/bash

# Check authentication
CheckAuth() {
	Auth="$(id -u)"
	if [[ $Auth -eq 0 ]]; then
		echo "[권한 OK]"
	else
		echo "[권한 FAIL] 관리자 계정으로 실행해주세요."
		exit 1
		echo "[ERROR 001: 권한 오류] $(date +%Y-%m-%d-%H:%M:%S)_$(id)" >> ../logs/Error_CheckAuth.log
	fi
}

# Check network
CheckNetwork() {
	ping -c 1 168.126.63.1 > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo "[네트워크 연결 OK]"
	else
		echo "[네트워크 연결 FAIL] 인터넷이 연결되어 있지 않습니다. 인터넷 연결후 다시 실행해주세요."
		exit 1
		echo "[ERROR 002: 네트워크 연결 오류] $(date +%Y-%m-%d-%H:%M:%S)_$(id)" >> ../logs/Error_CheckNetwork.log
	fi
}

# Check DNS Package
CheckPackage() {
	rpm -qic bind | grep named.conf > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo "[패키지 named 설치 OK]"
	else
		read -p "[패키지 설치 FAIL] named 패키지가 설치되어 있지 않습니다. 설치 하시겠습니까?[y/n]" CheckPackage
		case CheckPackage in
			Y|y)
				dnf install named named-chroot -y
				;;
			N|n)
				echo "설치를 취소합니다."
				;;
			*)
				echo "잘못 입력하셨습니다."
				;;
		esac	
	fi
}

Check() {
	CheckAuth
	CheckNetwork
	CheckPackage
}
