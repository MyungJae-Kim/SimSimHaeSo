# Hash 체커
# - 대조 절차
# 1. 이미지 파일 탐색
# 2. 이미지 파일의 정보 저장
# 3. 사용자의 Hash 입력
# 4. 저장된 정보와 대조
# 5. 일치하는 이미지 파일 정보 출력
# 6. 성공 여부 출력
# - 추가 사항: 오류 제어
# 테스트 이미지: Gooroom-4.4-amd64.iso(Gooroom-4.4-20251017-amd64.hybrid.iso) -> 구름OS 4.4 버전
# 테스트 Hash: 594bca6de371763e5868abe90cf6088a44bb43e5bb7de6bf84ad91494806af11
$ImgLoc = Read-Host "이미지 파일의 경로를 입력하세요: "
Get-FileHash $ImgLoc\*.iso -Algorithm SHA256 | Out-File $ImgLoc\HashChecker.txt # 1,2
Write-Host "이미지 파일의 경로에 HashChecker.txt 파일이 생성되었습니다."
$OriginHash = (Get-FileHash $ImgLoc\*.iso -Algorithm SHA256).Hash
$InputHash = Read-Host "무결성을 체크할 값을 입력하세요(Sha256): "
if ($OriginHash -eq $InputHash) { # 3
    Write-Host "Hash가 일치합니다. 이미지 파일의 정보를 출력합니다." # 4
    Get-Content $ImgLoc\HashChecker.txt # 5
    Write-Host "검사가 완료되었습니다." # 6
} else {
    Write-Host "오류가 발생했습니다." # 6
}