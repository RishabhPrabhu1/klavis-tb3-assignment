#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-"$TREE"}
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
TB3_HEAD_EXPECTED=${TB3_HEAD_EXPECTED:-79e71650f5b6a6ef5bb46a434c7c04d7d99a9480}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after the first exact-tree Sol probe is reviewed as a genuine model failure"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ -f "$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt" ]] || fail "same-tree qualification marker missing"

# Require the reviewed first Sol failure before launching the deadline batch.
count_probe=$(python3 - "$TREE" <<'PY'
import json,sys
from pathlib import Path
tree=sys.argv[1]; root=Path.home()/'.cache/klavis-tb3-runs/transaction-standard-probe'; n=0
if root.exists():
    for p in root.rglob('summary.json'):
        try:d=json.loads(p.read_text(encoding='utf-8'))
        except Exception:continue
        if (d.get('task_tree')==tree and d.get('mode')=='standard' and d.get('agent')=='codex'
            and d.get('model')=='openai/gpt-5.6-sol' and d.get('reasoning_effort')=='xhigh'
            and d.get('execution_class')=='valid-completed-trial' and d.get('qualification_valid') is True
            and not (d.get('result_exception_types') or []) and d.get('reward') in (0,0.0)):
            n+=1
print(n)
PY
)
(( count_probe >= 1 )) || fail "no valid exact-tree Sol/xhigh reward-0 probe found; do not freeze"

printf '=== FOUR-HOUR CODEX FINISH ===\n'
printf 'task_tree=%s\n' "$TREE"
printf 'reviewed_probe_failures=%s\n' "$count_probe"
printf 'strategy=remaining Sol standards in parallel + Codex cheat concurrently\n'

log_root="$HOME/.cache/klavis-tb3-runs/four-hour-finish-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$log_root"

# The standard matrix sees the existing probe and launches exactly the missing
# trials, up to two in parallel. The cheat tree is independent evidence and can
# run concurrently without modifying tasks/.
(
  CONFIRM_FREEZE=1 \
  AGENT=codex MODE=standard TARGET_VALID_ZEROES=3 MAX_PARALLEL=2 \
  bash "$ROOT_DIR/scripts/run-parallel-final-matrix.sh"
) >"$log_root/codex-standard.log" 2>&1 &
standard_pid=$!

(
  CONFIRM_FREEZE=1 \
  AGENT=codex TARGET_CHEATS=1 TB3_HEAD_EXPECTED="$TB3_HEAD_EXPECTED" \
  bash "$ROOT_DIR/scripts/run-deadline-cheat-matrix.sh"
) >"$log_root/codex-cheat.log" 2>&1 &
cheat_pid=$!

set +e
wait "$standard_pid"; standard_status=$?
wait "$cheat_pid"; cheat_status=$?
set -e

printf '\nstandard_status=%s\n' "$standard_status"
printf 'cheat_status=%s\n' "$cheat_status"
printf 'logs=%s\n' "$log_root"

if (( standard_status != 0 )); then
  echo 'CODEX_FINISH_STATUS=STANDARD_STOPPED'
  tail -n 80 "$log_root/codex-standard.log" || true
  exit "$standard_status"
fi
if (( cheat_status != 0 )); then
  echo 'CODEX_FINISH_STATUS=CHEAT_STOPPED'
  tail -n 80 "$log_root/codex-cheat.log" || true
  exit "$cheat_status"
fi

printf '\n--- standard tail ---\n'
tail -n 40 "$log_root/codex-standard.log" || true
printf '\n--- cheat tail ---\n'
tail -n 40 "$log_root/codex-cheat.log" || true

set +e
bash "$ROOT_DIR/scripts/final-submission-audit.sh"
audit_status=$?
set -e
if (( audit_status == 0 )); then
  echo 'CODEX_FINISH_STATUS=FINAL_AUDIT_READY'
else
  echo 'CODEX_FINISH_STATUS=CODEX_COMPLETE_OTHER_GATES_REMAIN'
fi
exit 0
