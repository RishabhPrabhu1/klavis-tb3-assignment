#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
FINAL_ROOT=${FINAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard-final"}
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
TARGET_VALID_FAILURES=${TARGET_VALID_FAILURES:-3}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after the task tree is frozen"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ "$TARGET_VALID_FAILURES" =~ ^[1-9][0-9]*$ ]] || fail "TARGET_VALID_FAILURES must be a positive integer"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" && -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && ( -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ) && -z "${ANTHROPIC_API_KEY:-}" ]]; then
  fail "Claude auth missing: configure a supported Claude provider route first"
fi

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree zero-model qualification marker missing: $QUAL_MARKER"

mkdir -p "$FINAL_ROOT"
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$FINAL_ROOT" >/dev/null || true

count_valid_failures() {
  python3 - "$TREE" "$FINAL_ROOT" <<'PY'
import json, sys
from pathlib import Path
tree=sys.argv[1]; root=Path(sys.argv[2]).expanduser(); count=0
if root.exists():
    for path in root.rglob("summary.json"):
        try: data=json.loads(path.read_text(encoding="utf-8"))
        except Exception: continue
        if (
            data.get("task_tree")==tree
            and data.get("mode")=="standard"
            and data.get("agent")=="claude-code"
            and data.get("model")=="anthropic/claude-opus-5"
            and data.get("reasoning_effort")=="max"
            and data.get("execution_class")=="valid-completed-trial"
            and data.get("qualification_valid") is True
            and not (data.get("result_exception_types") or [])
            and data.get("reward") in (0,0.0)
        ):
            count += 1
print(count)
PY
}

while true; do
  current=$(count_valid_failures)
  if (( current >= TARGET_VALID_FAILURES )); then break; fi
  attempt=$((current + 1))
  printf '\n=== CLAUDE STANDARD TRIAL %s/%s ===\n' "$attempt" "$TARGET_VALID_FAILURES"
  set +e
  AGENT=claude MODE=standard EXPECTED_TASK_TREE="$TREE" RUNS_ROOT="$FINAL_ROOT" \
    bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
  runner_status=$?
  set -e

  python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$FINAL_ROOT" >/dev/null || true

  classification=$(python3 - "$TREE" "$FINAL_ROOT" <<'PY'
import json, sys
from pathlib import Path
tree=sys.argv[1]; root=Path(sys.argv[2]).expanduser(); found=[]
for path in root.rglob("summary.json"):
    try: data=json.loads(path.read_text(encoding="utf-8"))
    except Exception: continue
    if data.get("task_tree")==tree and data.get("mode")=="standard" and data.get("agent")=="claude-code":
        found.append((path.stat().st_mtime,path,data))
if not found:
    print("NO_SUMMARY")
else:
    _, path, data=max(found,key=lambda x:x[0])
    valid=(data.get("execution_class")=="valid-completed-trial" and data.get("qualification_valid") is True and not (data.get("result_exception_types") or []) and data.get("reward") is not None)
    if not valid: kind="INVALID"
    elif data.get("reward") in (0,0.0): kind="FAIL"
    else: kind="SOLVE"
    print(f"{kind}|{path}|reward={data.get('reward')!r}|passed={data.get('tests_passed')!r}|failed={data.get('tests_failed')!r}|exceptions={data.get('result_exception_types')!r}|auth={data.get('auth_kind')!r}")
PY
  )
  echo "$classification"
  case "$classification" in
    FAIL\|*) ;;
    SOLVE\|*) echo "STOP: Claude Opus 5 solved the frozen candidate; matrix requirement is not met." >&2; exit 20 ;;
    INVALID\|*|NO_SUMMARY) echo "STOP: Claude trial was invalid; do not count or auto-retry." >&2; exit 21 ;;
    *) echo "STOP: unknown Claude trial classification: $classification" >&2; exit 22 ;;
  esac
  if (( runner_status != 0 )); then
    echo "STOP: runner returned nonzero despite audited result; inspect evidence." >&2
    exit "$runner_status"
  fi
done

printf '\n=== CLAUDE STANDARD MATRIX REPORT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'valid_claude_opus5_max_failures=%s\n' "$(count_valid_failures)"
printf 'target=%s\n' "$TARGET_VALID_FAILURES"
printf 'final_root=%s\n' "$FINAL_ROOT"
printf 'status=CLAUDE_MATRIX_COMPLETE\n'
printf '=== END CLAUDE STANDARD MATRIX REPORT ===\n'
