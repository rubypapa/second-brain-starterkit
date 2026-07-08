# 이 프로젝트의 Claude Code 대화 기록(.jsonl)을 사람이 읽을 수 있는 텍스트로 아카이빙한다.
# 결과 = conversations/<세션id>.txt. AI가 세션 시작 때 이걸 통독해서 과거를 이어간다.
# 사용법: python tools/extract_conversation.py   (프로젝트 폴더에서 실행)
import os, sys, json, glob, re

def find_log_dir():
    """~/.claude/projects/ 에서 현재 프로젝트의 대화 로그 폴더를 찾는다."""
    home = os.path.expanduser("~")
    base = os.path.join(home, ".claude", "projects")
    if not os.path.isdir(base):
        return None
    cwd = os.getcwd()
    folder = os.path.basename(cwd.rstrip("/\\"))
    # Claude Code는 프로젝트 경로를 인코딩해 폴더명으로 쓴다. 폴더 basename이 포함된 걸 찾는다.
    cands = [d for d in glob.glob(os.path.join(base, "*")) if os.path.isdir(d)]
    match = [d for d in cands if folder and folder in os.path.basename(d)]
    if match:
        # 여러 개면 가장 최근 수정
        return max(match, key=lambda d: os.path.getmtime(d))
    return None

def extract(jsonl_path, out_path):
    lines_out = []
    with open(jsonl_path, "r", encoding="utf-8") as f:
        for line in f:
            try:
                obj = json.loads(line)
            except Exception:
                continue
            role = obj.get("type") or obj.get("role")
            msg = obj.get("message", obj)
            content = msg.get("content") if isinstance(msg, dict) else None
            text = ""
            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                for c in content:
                    if isinstance(c, dict) and c.get("type") == "text":
                        text += c.get("text", "")
            if text.strip():
                who = "사용자" if role in ("user", "human") else "Claude"
                lines_out.append(f"=== [{who}] ===\n{text.strip()}\n")
    if lines_out:
        with open(out_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines_out))
        return True
    return False

def main():
    log_dir = find_log_dir()
    outdir = os.path.join(os.getcwd(), "conversations")
    os.makedirs(outdir, exist_ok=True)
    if not log_dir:
        print("[extract] Claude Code 대화 로그 폴더를 못 찾음(~/.claude/projects). 건너뜀.")
        return
    n = 0
    for jf in glob.glob(os.path.join(log_dir, "*.jsonl")):
        sid = os.path.splitext(os.path.basename(jf))[0]
        if extract(jf, os.path.join(outdir, sid + ".txt")):
            n += 1
    print(f"[extract] 대화 {n}건 아카이빙 → conversations/")

if __name__ == "__main__":
    main()
