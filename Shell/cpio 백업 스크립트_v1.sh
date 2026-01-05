* CPIO 통합 스크립트
	1. 전체, 차등 백업 및 SCP 자동 전송
	2. 증분 백업 및 SCP 자동 전송
	3. 선택 파일 복원
	4. 기본 디렉터리 및 파일 설치
	5. 기본 디렉터리 삭제
	6. 크론탭 등록

* 한글이 깨질 경우, 스크립트 붙여넣기 또는 다운로드 후 아래 명령줄 실행

iconv -f euc-kr -t utf-8 [자신의 파일명] -o cpio.sh	-> utf-8 파일을 euc-kr(한글)로 변형한다.
chmod 700 cpio.sh

* 실행 파일 이름 : cpio.sh

=============================================================================================

#!/bin/bash
#################################################################
# Writer: KMJ
# 1. 쉘 사용자 프로파일 설정
# 2. 백업 클라이언트로 SSH 키 복사
# 3. 백업 후 파일 전송
echo "==========================================================="
echo "==== 원활한 파일 전송을 위해 SSH 인증 키를 수신자에게 복사해주세요 ===="
#################################################################
##### 기본 설정
DATE_T="$(date +%Y%m%d%H%M)"
DIR_ORI="/root/Team3"
DIR_BACK="$DIR_ORI/backup"
DIR_SOUR="$DIR_ORI/source"
TIME_REF="$DIR_ORI/.TimeRef"
##### 크론탭 파일 경로 및 설정
ADMIN="root"
CRON_LOC="/var/spool/cron"
THIS="cpio.sh"
P_THIS="$DIR_ORI/.$THIS"
CROND_SET="30 4 * * * root $P_THIS"
#################################################################
##### 백업 설정
# 백업 명령어 및 옵션
COM="cpio"
EXT="cpio"
OPT_FULL="-ov"
OPT_DIFF="-ov"
OPT_INCR="-ov"
# 백업 파일 이름
NAME_MID="_BACKUP_"
NAME_FULL="FULL"
NAME_DIFF="DIFF"
NAME_INCR="INCR"
RECENT="$(ls -t $DIR_BACK | head -n 1)"
#################################################################
# SCP(백업 파일 전송용) 설정
#if [ ! -f /$ADMIN/.ssh/authorized_keys ]; then
#	echo "============================= Need SCP Client Settings"
#	ssh-keygen
#fi
USERNAME="user9"
UP_DIR="/home/user9"
SCP_ADD="192.168.10.59"	# IP 주소 입력
# scp $DIR_BACK/$RECENT $USERNAME@$SCP_ADD:$UP_DIR
#################################################################
# 백업 메뉴 출력
echo "============================== 메뉴 선택 =============================="
echo "| 1) : 전체 백업 및 차등 백업 수행"
echo "| 2) : 증분 백업 수행"
echo "| 3) : 초기 디렉터리 및 파일 생성"
echo "| 4) : 파일 복원 수행"
echo "| 5) : 모든 파일 및 디렉터리 삭제"
echo "| 6) : 크론탭에 스케줄 등록"
echo "======================================================================="
read -p "메뉴를 선택하세요 : " CHOICE 

case "$CHOICE" in
	1) # 전체 및 차등 백업
		if [ -d $DIR_SOUR ]; then
		ARC_F_DIFF="$DIR_BACK/${NAME_DIFF}${NAME_MID}${DATE_T}.${EXT}"
		ARC_F_FULL="$DIR_BACK/${NAME_FULL}${NAME_MID}${DATE_T}.${EXT}"

			if ls $DIR_BACK/$NAME_FULL* ; then
				echo "===== 차등 백업 아카이브 중 ====="
				find $DIR_SOUR | $COM $OPT_DIFF > $ARC_F_DIFF 
				echo "===== 백업 파일: $NAME_DIFF$NAME_MID$DATE_T.$EXT ====="
				touch -t $DATE_T $TIME_REF
				sleep 1.5
				scp "$DIR_BACK/$RECENT" "$USERNAME@$SCP_ADD:$UP_DIR"
			else
				echo "===== 전체 백업 아카이브 중 ====="
				find $DIR_SOUR | $COM $OPT_FULL > $ARC_F_FULL
				echo "===== 백업 파일: $NAME_FULL$NAME_MID$DATE_T.$EXT ====="
				touch -t $DATE_T $TIME_REF
				if [ -f "$DIR_BACK/$RECENT" ]; then
					sleep 1.5
					scp "$DIR_BACK/$RECENT" "$USERNAME@$SCP_ADD:$UP_DIR"
				else
					echo "전송할 백업 파일이 없습니다."
				fi
			fi
		else
			echo "===== 백업할 데이터가 존재하지 않습니다. ====="
		fi
		;;

	2) # 증분 백업
		if [ -d $DIR_SOUR ]; then
			ARC_F_INCR="$DIR_BACK/${NAME_INCR}${NAME_MID}${DATE_T}.${EXT}"
			FILE_LIST="$DIR_BACK/.FileList"

			if ls $DIR_BACK/$NAME_FULL* ; then
				echo "===== 증분 백업 아카이브 중 ====="
				find $DIR_SOUR -newer $TIME_REF > $FILE_LIST
				cat $FILE_LIST | $COM $OPT_INCR > $ARC_F_INCR
				echo "===== 백업 파일: $NAME_INCR$NAME_MID$DATE_T.$EXT ====="
				if [ -f "$DIR_BACK/$RECENT" ]; then
					sleep 1.5
					scp "$DIR_BACK/$RECENT" "$USERNAME@$SCP_ADD:$UP_DIR"
				else
					echo "전송할 백업 파일이 없습니다."
				fi
			fi 

		else
			echo "===== 백업할 데이터가 존재하지 않습니다. ====="
		fi
		;;

	3) # 기본 디렉터리 및 파일 생성
		[ ! -d "$DIR_BACK" ] && mkdir -p $DIR_BACK 
		[ ! -d "$DIR_SOUR" ] && mkdir -p $DIR_SOUR  
		echo "########## 디렉터리 생성 완료: '$DIR_BACK', '$DIR_SOUR'"
		[ ! -f "$P_THIS" ] && sudo find / -type f -name $THIS -exec cp {} $P_THIS \;  
		echo "########## 크론탭 파일 복사: '$THIS'"  
		echo "########## 초기화 완료"
		;;

	4) # 파일 복원 수행
		if [ -d $DIR_ORI ]; then
			DIR_REST=""
			FILE_REST=""

			echo "파일 복원을 수행합니다."
			read -p "복원할 파일을 입력하세요. (미입력시 가장 최신 파일)" FILE_REST

			if [ -z "$FILE_REST" ]; then
				echo "선택한 경로에 가장 최근 파일을 복원합니다"
				cpio -idv < $DIR_BACK/$RECENT
			else
				echo "선택한 경로에 $FILE_REST 파일을 복원합니다"
				cpio -idv < $DIR_BACK/$FILE_REST
			fi
		fi					
		;;

	5) # 모든 파일 제거
		rm -rf $DIR_ORI && rm -f "$CRON_LOC/$ADMIN_$THIS" "$UP_DIR"
		echo "########## 모든 디렉터리와 파일 제거 완료"
		;;

	6) # 크론탭에 등록
		if [ -d $DIR_ORI ]; then
			if crontab -l | grep -q "$P_THIS"; then
   				 echo "이미 등록되어 있습니다."
			else
    				(crontab -l 2>/dev/null; echo "$CROND_SET") | crontab -
   				 echo "크론탭 등록 완료"
			fi
		else
			echo "########## $DIR_ORI 파일이 없습니다.."
		fi
		;;

	*) # 잘못된 입력 처리
		echo "잘못 입력하셨습니다."
		;;
esac

