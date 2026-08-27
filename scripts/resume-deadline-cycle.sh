#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
CHEAT_ROOT=${CHEAT_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat"}
STANDARD_ROOT=${STANDARD_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe"}
CYCLE_ROOT=${CYCLE_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-frontier-cycle"}
QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

latest_summary() {
  local root=$1 mode=$2 agent=$3
  python3 - "$root" "$TREE" "$mode" "$agent" <<'PY'
import json, sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; mode=sys.argv[3]; agent=sys.argv[4]
found=[]
if root.exists():
    for path in root.rglob("summary.json"):
        try: data=json.loads(path.read_text(encoding="utf-8"))
        except Exception: continue
        if data.get("task_tree")==tree and data.get("mode")==mode and data.get("agent")==agent:
            found.append((path.stat().st_mtime,path))
print(str(max(found)[1]) if found else "")
PY
}

classify_summary() {
  local summary=$1
  python3 - "$summary" <<'PY'
import json, sys
from pathlib import Path
p=Path(sys.argv[1]); d=json.loads(p.read_text(encoding="utf-8"))
valid=(d.get("execution_class")=="valid-completed-trial" and d.get("qualification_valid") is True and not (d.get("result_exception_types") or []) and d.get("reward") is not None)
if not valid:
    kind="INVALID"
elif d.get("reward") in (0,0.0):
    kind="FAIL"
else:
    kind="SOLVE"
print(f"{kind}|reward={d.get('reward')!r}|passed={d.get('tests_passed', d.get('tests',{}).get('passed'))!r}|failed={d.get('tests_failed', d.get('tests',{}).get('failed'))!r}|exceptions={d.get('result_exception_types')!r}|summary={p}")
PY
}

printf '\n=== RESUME DEADLINE CYCLE ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"

# Gate 1: deterministic qualification. Reuse only a same-tree marker.
if [[ ! -f "$QUAL_MARKER" ]]; then
  echo "No same-tree qualification marker; running zero-model qualification first."
  bash "$ROOT_DIR/scripts/run-next-qualification-step.sh"
else
  echo "Qualification marker already exists: $QUAL_MARKER"
fi

# Gate 2: if a standard probe already completed, never launch another automatically.
standard_summary=$(latest_summary "$STANDARD_ROOT" standard codex)
if [[ -n "$standard_summary" ]]; then
  classification=$(classify_summary "$standard_summary")
  echo "Existing standard probe: $classification"
  case "$classification" in
    FAIL\|*)
      echo "STATUS=VALID_REWARD_ZERO_REVIEW_AND_FREEZE"
      echo "NEXT=If reviewer confirms this is a real task failure, run: CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh"
      exit 0
      ;;
    SOLVE\|*)
      echo "STATUS=VALID_SOLVE_REDESIGN_REQUIRED"
      exit 20
      ;;
    INVALID\|*)
      echo "STATUS=INVALID_STANDARD_DO_NOT_COUNT_OR_AUTO_RETRY"
      exit 21
      ;;
  esac
fi

# Gate 3: detect an interrupted in-progress standard directory before launching anything new.
incomplete_standard=$(python3 - "$STANDARD_ROOT" "$TREE" <<'PY'
import json, sys, time
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]
items=[]
if root.exists():
    for d in root.iterdir():
        if not d.is_dir() or (d/"summary.json").exists():
            continue
        meta=d/"metadata.json"
        if not meta.exists():
            continue
        try: m=json.loads(meta.read_text(encoding="utf-8"))
        except Exception: continue
        if m.get("task_tree")==tree and m.get("mode")=="standard" and m.get("agent")=="codex":
            items.append((d.stat().st_mtime,d))
print(str(max(items)[1]) if items else "")
PY
)
if [[ -n "$incomplete_standard" ]]; then
  echo "STATUS=INCOMPLETE_STANDARD_EVIDENCE"
  echo "run_directory=$incomplete_standard"
  echo "Refusing a duplicate model call. Inspect whether Harbor/Codex is still running; if not, classify this attempt before any rerun."
  exit 22
fi

# Gate 4: if no standard attempt exists yet, use the existing guarded frontier runner.
echo "No completed or incomplete same-tree standard probe found; continuing with guarded frontier cycle."
bash "$ROOT_DIR/scripts/run-fast-frontier-cycle.sh"
