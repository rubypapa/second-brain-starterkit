# 제2의 뇌 스타터킷 — 원클릭 설치 (설치.bat가 이걸 실행)
$ErrorActionPreference = 'Stop'
try {
  $kit = Split-Path -Parent $MyInvocation.MyCommand.Path
  Write-Host ""
  Write-Host "===============================================" -ForegroundColor Cyan
  Write-Host "   제2의 뇌 스타터킷 설치" -ForegroundColor Cyan
  Write-Host "===============================================" -ForegroundColor Cyan
  Write-Host ""

  $target = Read-Host "설치할 프로젝트 폴더 경로를 붙여넣고 엔터 (엔터만 = 현재 폴더)"
  if ([string]::IsNullOrWhiteSpace($target)) { $target = (Get-Location).Path }
  $target = $target.Trim('"').Trim()
  if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }

  $pname = Read-Host "프로젝트 이름 (예: 내유튜브, 내블로그) [엔터=내 프로젝트]"
  if ([string]::IsNullOrWhiteSpace($pname)) { $pname = "내 프로젝트" }

  Write-Host ""
  Write-Host "복사 중..." -ForegroundColor Yellow
  Copy-Item (Join-Path $kit 'CLAUDE.md') $target -Force
  Copy-Item (Join-Path $kit 'MEMORY.md') $target -Force
  Copy-Item (Join-Path $kit '.claude') $target -Recurse -Force
  Copy-Item (Join-Path $kit 'memory') $target -Recurse -Force
  Copy-Item (Join-Path $kit 'tools')  $target -Recurse -Force
  $conv = Join-Path $target 'conversations'
  if (-not (Test-Path $conv)) { New-Item -ItemType Directory -Path $conv -Force | Out-Null }

  # PROJECT_NAME 자동 치환
  $sp = Join-Path $target 'tools\session_start.py'
  $c = Get-Content -Raw -Encoding UTF8 $sp
  $c = $c -replace 'PROJECT_NAME = "내 프로젝트"', ('PROJECT_NAME = "' + $pname + '"')
  Set-Content -Path $sp -Value $c -Encoding UTF8 -NoNewline

  Write-Host ""
  Write-Host "설치 완료! ->  $target" -ForegroundColor Green
  Write-Host ""
  Write-Host "다음 3단계:" -ForegroundColor Cyan
  Write-Host "  1) 그 폴더에서 Claude Code 를 켜세요  (터미널에서 claude)"
  Write-Host "  2) CLAUDE.md 의 [[ ]] 부분을 채우세요 (Claude 에게 '내 상황으로 채워줘' 해도 됨)"
  Write-Host "  3) 끝! 새 세션마다 hook 가 과거 기록을 자동으로 읽어줍니다"
  Write-Host ""
  Write-Host "* Python 이 필요합니다 (hook 실행용). 없으면 python.org 에서 설치하세요." -ForegroundColor DarkGray
}
catch {
  Write-Host ""
  Write-Host "설치 중 오류: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "경로에 한글/공백이 있어도 됩니다. 안 되면 영상 댓글로 알려주세요."
}
Write-Host ""
Read-Host "엔터를 누르면 닫힙니다"
