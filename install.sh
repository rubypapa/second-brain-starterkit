#!/usr/bin/env bash
# 제2의 뇌 스타터킷 — 원클릭 설치 (Mac/Linux)
set -e
KIT="$(cd "$(dirname "$0")" && pwd)"
echo "=============================================="
echo "   제2의 뇌 스타터킷 설치"
echo "=============================================="
read -r -p "설치할 프로젝트 폴더 경로 (엔터=현재 폴더): " TARGET
[ -z "$TARGET" ] && TARGET="$(pwd)"
read -r -p "프로젝트 이름 [엔터=내 프로젝트]: " PNAME
[ -z "$PNAME" ] && PNAME="내 프로젝트"
mkdir -p "$TARGET"
cp "$KIT/CLAUDE.md" "$KIT/MEMORY.md" "$TARGET/"
cp -r "$KIT/.claude" "$KIT/memory" "$KIT/tools" "$TARGET/"
mkdir -p "$TARGET/conversations"
python3 - "$TARGET/tools/session_start.py" "$PNAME" <<'PY'
import sys
p, name = sys.argv[1], sys.argv[2]
s = open(p, encoding='utf-8').read().replace('PROJECT_NAME = "내 프로젝트"', f'PROJECT_NAME = "{name}"')
open(p, 'w', encoding='utf-8').write(s)
PY
echo ""
echo "설치 완료! -> $TARGET"
echo "1) 그 폴더에서 claude 실행   2) CLAUDE.md 의 [[ ]] 채우기   3) 끝"
echo "* Python3 필요 (hook 실행용)"
