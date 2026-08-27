#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-"$TREE"}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe"}

fail() { echo "ERROR: $*" >&2; exit 2; }
[[ "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
marker="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$marker" ]] || fail "same-tree qualification marker missing: $marker"

# Never auto-launch a second same-tree Sol standard attempt.
existing=$(python3 - "$RUNS_ROOT" "$TREE" <<'PY'
import json,sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; found=[]
if root.exists():
    for d in root.iterdir():
        if not d.is_dir(): continue
        summary=d/"summary.json"; meta=d/"metadata.json"
        if summary.exists():
            try:x=json.loads(summary.read_text(encoding="utf-8"))
            except Exception:continue
            if x.get("task_tree")==tree and x.get("mode")=="standard" and x.get("agent")=="codex": found.append(str(summary))
        elif meta.exists():
            try:x=json.loads(meta.read_text(encoding="utf-8"))
            except Exception:continue
            if x.get("task_tree")==tree and x.get("mode")=="standard" and x.get("agent")=="codex": found.append(str(meta))
print("\n".join(found))
PY
)
[[ -z "$existing" ]] || { echo "Existing/incomplete same-tree Sol evidence found; refusing duplicate:" >&2; echo "$existing" >&2; exit 3; }

mkdir -p "$RUNS_ROOT"
# macOS Bash 3.2 does not define BASHPID; candidate runner only needs uniqueness.
if [[ -z "${BASHPID-}" ]]; then export BASHPID="$$"; fi

set +e
AGENT=codex MODE=standard EXPECTED_TASK_TREE="$TREE" RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
status=$?
set -e
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUNS_ROOT" >/dev/null || true

latest=$(python3 - "$RUNS_ROOT" "$TREE" <<'PY'
import json,sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; found=[]
for p in root.rglob("summary.json"):
    try:d=json.loads(p.read_text(encoding="utf-8"))
    except Exception:continue
    if d.get("task_tree")==tree and d.get("mode")=="standard" and d.get("agent")=="codex": found.append((p.stat().st_mtime,p,d))
if not found: print("NO_SUMMARY")
else:
    _,p,d=max(found,key=lambda x:x[0])
    valid=d.get("execution_class")=="valid-completed-trial" and d.get("qualification_valid") is True and not (d.get("result_exception_types") or []) and d.get("reward") is not None
    kind="INVALID" if not valid else ("FAIL" if d.get("reward") in (0,0.0) else "SOLVE")
    print(f"{kind}|{p}|reward={d.get('reward')!r}|exceptions={d.get('result_exception_types')!r}")
PY
)
echo "$latest"
case "$latest" in
  FAIL\|*) echo "STATUS=VALID_REWARD_ZERO_REVIEW_AND_FREEZE"; exit 0 ;;
  SOLVE\|*) echo "STATUS=VALID_SOLVE_DO_NOT_FREEZE"; exit 20 ;;
  INVALID\|*|NO_SUMMARY) echo "STATUS=INVALID_DO_NOT_COUNT_OR_AUTO_RETRY"; exit 21 ;;
  *) echo "STATUS=UNKNOWN"; exit 22 ;;
esac
