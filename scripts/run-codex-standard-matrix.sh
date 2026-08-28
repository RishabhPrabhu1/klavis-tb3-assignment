#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
PROBE_ROOT=${PROBE_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe"}
FINAL_ROOT=${FINAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-final"}
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
TARGET_VALID_FAILURES=${TARGET_VALID_FAILURES:-3}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after the current task tree is frozen and the first reward-0 failure is accepted"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ "$TARGET_VALID_FAILURES" =~ ^[1-9][0-9]*$ ]] || fail "TARGET_VALID_FAILURES must be a positive integer"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"
[[ -f "$HOME/.codex/auth.json" ]] || fail "Codex auth.json is missing"

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree zero-model qualification marker missing: $QUAL_MARKER"

mkdir -p "$PROBE_ROOT" "$FINAL_ROOT"
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$PROBE_ROOT" >/dev/null || true
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$FINAL_ROOT" >/dev/null || true

count_valid_failures() {
  python3 - "$TREE" "$PROBE_ROOT" "$FINAL_ROOT" <<'PY'
import json, sys
from pathlib import Path
tree = sys.argv[1]
roots = [Path(p).expanduser() for p in sys.argv[2:]]
seen = set(); count = 0
for root in roots:
    if not root.exists(): continue
    for path in root.rglob("summary.json"):
        try: data = json.loads(path.read_text(encoding="utf-8"))
        except Exception: continue
        key = str(path.resolve())
        if key in seen: continue
        seen.add(key)
        if (
            data.get("task_tree") == tree
            and data.get("mode") == "standard"
            and data.get("agent") == "codex"
            and data.get("model") == "openai/gpt-5.6-sol"
            and data.get("reasoning_effort") == "xhigh"
            and data.get("execution_class") == "valid-completed-trial"
            and data.get("qualification_valid") is True
            and not (data.get("result_exception_types") or [])
            and data.get("reward") in (0, 0.0)
        ):
            count += 1
print(count)
PY
}

initial=$(count_valid_failures)
(( initial >= 1 )) || fail "no valid same-tree Sol/xhigh reward-0 probe exists; do not freeze"
printf 'Existing valid same-tree Codex failures: %s/%s\n' "$initial" "$TARGET_VALID_FAILURES"

while true; do
  current=$(count_valid_failures)
  if (( current >= TARGET_VALID_FAILURES )); then break; fi
  attempt=$((current + 1))
  printf '\n=== CODEX STANDARD TRIAL %s/%s ===\n' "$attempt" "$TARGET_VALID_FAILURES"
  set +e
  AGENT=codex MODE=standard EXPECTED_TASK_TREE="$TREE" RUNS_ROOT="$FINAL_ROOT" \
    bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
  runner_status=$?
  set -e

  python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$FINAL_ROOT" >/dev/null || true

  classification=$(python3 - "$TREE" "$FINAL_ROOT" <<'PY'
import json, sys
from pathlib import Path
tree = sys.argv[1]; root = Path(sys.argv[2]).expanduser(); found=[]
for path in root.rglob("summary.json"):
    try: data=json.loads(path.read_text(encoding="utf-8"))
    except Exception: continue
    if data.get("task_tree")==tree and data.get("mode")=="standard" and data.get("agent")=="codex":
        found.append((path.stat().st_mtime,path,data))
if not found:
    print("NO_SUMMARY")
else:
    _, path, data=max(found,key=lambda x:x[0])
    valid=(data.get("execution_class")=="valid-completed-trial" and data.get("qualification_valid") is True and not (data.get("result_exception_types") or []) and data.get("reward") is not None)
    if not valid: kind="INVALID"
    elif data.get("reward") in (0,0.0): kind="FAIL"
    else: kind="SOLVE"
    tests=data.get("tests") if isinstance(data.get("tests"), dict) else {}
    print(f"{kind}|{path}|reward={data.get('reward')!r}|passed={tests.get('passed')!r}|failed={tests.get('failed')!r}|exceptions={data.get('result_exception_types')!r}")
PY
  )
  echo "$classification"
  case "$classification" in
    FAIL\|*) ;;
    SOLVE\|*) echo "STOP: Sol solved the frozen candidate; matrix requirement is not met." >&2; exit 20 ;;
    INVALID\|*|NO_SUMMARY) echo "STOP: trial was invalid; do not count or auto-retry." >&2; exit 21 ;;
    *) echo "STOP: unknown trial classification: $classification" >&2; exit 22 ;;
  esac
  if (( runner_status != 0 )); then
    echo "STOP: runner returned nonzero despite audited result; inspect evidence." >&2
    exit "$runner_status"
  fi
done

printf '\n=== CODEX STANDARD MATRIX REPORT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'valid_sol_xhigh_failures=%s\n' "$(count_valid_failures)"
printf 'target=%s\n' "$TARGET_VALID_FAILURES"
printf 'probe_root=%s\n' "$PROBE_ROOT"
printf 'final_root=%s\n' "$FINAL_ROOT"
printf 'status=CODEX_MATRIX_COMPLETE\n'
printf '=== END CODEX STANDARD MATRIX REPORT ===\n'
