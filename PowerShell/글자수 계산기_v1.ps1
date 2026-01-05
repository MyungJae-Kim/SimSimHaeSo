$SELCECTION = Read-Host "선택하세요. `n1) 파일명 `n2) 입력`n"
# @ -> Here-String 사용해도 좋음.
# 예) 선택하세요
# 1) 파일명
# 2) 입력

switch ($SELCECTION) {
    "1" {
        $FileName = Read-Host "파일의 경로와 이름을 입력하세요 "
        Write-Host "$FileName 파일 내용을 분석합니다."
        Write-Host "$FileName의 줄 수: $((Get-Content $FileName | Measure-Object -Line).Lines)"
        Write-Host "$FileName의 단어 수: $((Get-Content $FileName | Measure-Object -Word).Words)"
        Write-Host "$FileName의 글자 수: $((Get-Content $FileName | Measure-Object -Character).Characters)"
    }
    "2" {
        $Text = Read-Host "문자열을 입력하세요 "
        Write-Host "$Text의 줄 수: $($Text.Split("`n").Count)"
        Write-Host "$Text의 단어 수: $($Text.Split(" ",[StringSplitOptions]::RemoveEmptyEntries).Count)"
        Write-Host "$Text의 글자 수: $($Text.Length)"
    }
    default {
        Write-Host "1 또는 2 만 입력해 선택해주세요."
    }
}

Read-Host "엔터키를 누르면 종료합니다.`n"
