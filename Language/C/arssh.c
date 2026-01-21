#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define CONF "/etc/ssh/sshd_config"
#define CONF_BAK "/etc/ssh/sshd_config.bak"
#define AUTH_YES "PermitRootLogin yes"
#define AUTH_NO "PermitRootLogin no"

void backup() {
	FILE *fp = fopen(CONF, "r");
	
}

void auth_yes() {
	FILE *fp = fopen(CONF, "r");
	if (!fp) {
		perror("파일이 없습니다.");
		exit(1);
	}
		
	char line[256];
	while (fgets(line, sizeof(line), fp)) {
		if(strstr(line, AUTH_NO)) {
			fprintf(fp, "%s\n", AUTH_YES);
		} else {
			fputs(line, fp);
		}
	}

	fclose(fp);
}

void auth_no() {
	FILE *fp = fopen(CONF, "r");
	if (!fp) {
		perror("파일이 없습니다.");
		exit(1);
	}
		
	char line[256];
	while (fgets(line, sizeof(line), fp)) {
		if(strstr(line, AUTH_YES)) {
			fprintf(fp, "%s\n", AUTH_NO);
		} else {
			fputs(line, fp);
		}
	}

	fclose(fp);
}

void restart_d() {
	pid_t pid = fork();
	if (pid == 0) {
		execl("systemctl restart sshd");
		return 0;
	} else {
		int status; wait(&status);
		if (WIFEXITED(status)) {
			printf("systemctl 종료 코드: %d\n" WEXITSTATUS(status));
		}
	}
}

int main() {
	if (geteuid() != 0) {
		fprintf(stderr, "관리자 권한으로만 실행 가능합니다.\n");
		return 1;
	}

	int menu;
	printf("1. Root 원격 접속 불허\n");
	printf("2. Root 원격 접속 허용\n");
	printf("메뉴를 선택하세요: ");
	scanf("%d", &menu);

	switch (menu) {
		case 1:
			auth_no();
			printf("Root 원격 접속을 [불허]하였습니다.\n");
			restart_d();
			break;
		case 2:
			auth_yes();
			printf("Root 원격 접속을 [허용]하였습니다.\n");
			restart_d();
			break;
		default:
			printf("잘못 선택하셨습니다.\n");
			continue;
	}

	return 0;
}
