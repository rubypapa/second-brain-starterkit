# 세션 시작 hook — AI가 새 세션마다 과거를 강제로 통독하게 만든다(= "제2의 뇌"의 핵심).
# .claude/settings.json 의 SessionStart 에 배선됨. stdout이 AI 컨텍스트에 주입된다.
# 사용법: (자동 실행됨. 수동 테스트: python tools/session_start.py)
import os, glob, subprocess, sys

PROJECT_NAME = "내 프로젝트"   # ← 여기를 당신 프로젝트 이름으로 바꾸세요.

def main():
    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    # 1) 대화 기록을 최신으로 재생성
    try:
        subprocess.run([sys.executable, os.path.join(here, "tools", "extract_conversation.py")],
                       cwd=here, timeout=60, capture_output=True)
    except Exception:
        pass
    # 2) AI에게 통독 지시 + 안 읽은 최신 대화 목록
    print(f"=== [{PROJECT_NAME}] 세션 시작 프로토콜 ===")
    print("작업 착수 전 반드시: ①MEMORY.md 목차 읽기 ②memory/ 폴더의 관련 사실 파일 펼쳐보기")
    print("③아래 최근 대화 txt를 처음부터 끝까지 정독 → 그다음 이어간다.")
    print("요약만 읽고 '파악 끝' 금지. 같은 걸 두 번 묻지 말 것.\n")
    convs = sorted(glob.glob(os.path.join(here, "conversations", "*.txt")),
                   key=os.path.getmtime, reverse=True)
    if convs:
        print("최근 대화 기록 (새것 순):")
        for c in convs[:3]:
            try:
                n = sum(1 for _ in open(c, encoding="utf-8"))
            except Exception:
                n = "?"
            print(f"  - {c}  ({n}줄)")
    else:
        print("(아직 대화 기록 없음 — 첫 세션이거나 conversations/ 비어있음)")

if __name__ == "__main__":
    main()
