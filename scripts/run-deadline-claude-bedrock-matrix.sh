#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
STANDARD_TARGET=${STANDARD_TARGET:-3}
CHEAT_TARGET=${CHEAT_TARGET:-1}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
STANDARD_ROOT=${STANDARD_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard"}
CHEAT_ROOT=${CHEAT_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}

fail() { echo "ERROR: $*" >&2; exit 2; }
[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after the current task tree is frozen"
[[ "$STANDARD_TARGET" =~ ^[1-9][0-9]*$ ]] || fail "STANDARD_TARGET must be a positive integer"
[[ "$CHEAT_TARGET" =~ ^[1-9][0-9]*$ ]] || fail "CHEAT_TARGET must be a positive integer"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ -f "$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt" ]] || fail "same-tree qualification marker missing"
[[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "1" ]] || fail "set CLAUDE_CODE_USE_BEDROCK=1"
if [[ -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && -z "${AWS_ACCESS_KEY_ID:-}" && -z "${AWS_PROFILE:-}" ]]; then
  fail "Bedrock credentials are not configured"
fi
mkdir -p "$STANDARD_ROOT" "$CHEAT_ROOT"

scan() {
  local root=$1 mode=$2
  python3 - "$root" "$TREE" "$mode" <<'PY'
import json,sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; mode=sys.argv[3]
zero=[]; nonzero=[]; invalid=[]
if root.exists():
    for p in root.rglob("summary.json"):
        try:d=json.loads(p.read_text(encoding="utf-8"))
        except Exception:continue
        if not (d.get("task_tree")==tree and d.get("mode")==mode and d.get("agent")=="claude-code" and d.get("model")=="anthropic/claude-opus-5" and d.get("reasoning_effort")=="max"):
            continue
        valid=(d.get("execution_class")=="valid-completed-trial" and d.get("qualification_valid") is True and not (d.get("result_exception_types") or []) and d.get("reward") is not None)
        if not valid: invalid.append(str(p))
        elif d.get("reward") in (0,0.0): zero.append(str(p))
        else: nonzero.append(str(p))
print(json.dumps({"zero":zero,"nonzero":nonzero,"invalid":invalid}))
PY
}

count_key() {
  python3 - "$1" "$2" <<'PY'
import json,sys
print(len(json.loads(sys.argv[1])[sys.argv[2]]))
PY
}

run_phase() {
  local mode=$1 root=$2 label=$3 target=$4
  local state zero nonzero before
  state=$(scan "$root" "$mode")
  zero=$(count_key "$state" zero)
  nonzero=$(count_key "$state" nonzero)
  (( nonzero == 0 )) || fail "$label already has a valid nonzero reward; frozen task is not acceptable"
  printf '%s existing valid reward-0: %s/%s\n' "$label" "$zero" "$target"

  while (( zero < target )); do
    before=$zero
    printf '\n=== CLAUDE BEDROCK %s TRIAL %s/%s ===\n' "$label" "$((zero+1))" "$target"
    set +e
    MODE="$mode" EXPECTED_TASK_TREE="$TREE" RUNS_ROOT="$root" \
      bash "$ROOT_DIR/scripts/run-claude-bedrock-trial.sh"
    runner_status=$?
    set -e

    state=$(scan "$root" "$mode")
    zero=$(count_key "$state" zero)
    nonzero=$(count_key "$state" nonzero)
    (( nonzero == 0 )) || {
      echo "STOP: Claude produced a valid nonzero reward during $label." >&2
      exit 20
    }
    if (( zero == before )); then
      echo "STOP: latest Claude $label attempt was invalid or did not add a valid reward-0 result. Do not auto-retry." >&2
      exit 21
    fi
    if (( runner_status != 0 )); then
      echo "STOP: runner returned nonzero despite adding a valid result; inspect evidence." >&2
      exit "$runner_status"
    fi
  done
}

# Live TB3: three standard trials per agent, but /cheat has no trial matrix and runs once per agent.
run_phase standard "$STANDARD_ROOT" "STANDARD" "$STANDARD_TARGET"
run_phase cheat "$CHEAT_ROOT" "CHEAT" "$CHEAT_TARGET"

printf '\n=== CLAUDE BEDROCK DEADLINE MATRIX REPORT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'standard_valid_reward_zero=%s/%s\n' "$(count_key "$(scan "$STANDARD_ROOT" standard)" zero)" "$STANDARD_TARGET"
printf 'cheat_valid_reward_zero=%s/%s\n' "$(count_key "$(scan "$CHEAT_ROOT" cheat)" zero)" "$CHEAT_TARGET"
printf 'standard_root=%s\n' "$STANDARD_ROOT"
printf 'cheat_root=%s\n' "$CHEAT_ROOT"
printf 'status=CLAUDE_MATRIX_COMPLETE\n'
printf '=== END CLAUDE BEDROCK DEADLINE MATRIX REPORT ===\n'
