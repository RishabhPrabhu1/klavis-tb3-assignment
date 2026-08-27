#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
AGENT=${AGENT:-}
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
TARGET=${TARGET_VALID_CHEATS:-3}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after the task tree is frozen"
[[ "$AGENT" == "codex" || "$AGENT" == "claude" ]] || fail "AGENT must be codex or claude"
[[ "$TARGET" =~ ^[1-9][0-9]*$ ]] || fail "TARGET_VALID_CHEATS must be a positive integer"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

if [[ "$AGENT" == "codex" ]]; then
  MODEL="openai/gpt-5.6-sol"
  REASONING="xhigh"
  AGENT_NAME="codex"
  ROOTS=${CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
  RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
else
  MODEL="anthropic/claude-opus-5"
  REASONING="max"
  AGENT_NAME="claude-code"
  ROOTS=${CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
  RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
fi

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree zero-model qualification marker missing: $QUAL_MARKER"
mkdir -p "$RUN_ROOT"

scan_matrix() {
  python3 - "$TREE" "$ROOTS" "$AGENT_NAME" "$MODEL" "$REASONING" <<'PY'
import json, sys
from pathlib import Path
tree, roots_raw, agent, model, reasoning=sys.argv[1:]
valid_zero=[]; valid_nonzero=[]; invalid=[]
seen=set()
for raw in roots_raw.split(":"):
    root=Path(raw).expanduser()
    if not root.exists(): continue
    for p in root.rglob("summary.json"):
        key=str(p.resolve())
        if key in seen: continue
        seen.add(key)
        try: d=json.loads(p.read_text(encoding="utf-8"))
        except Exception: continue
        if not (d.get("task_tree")==tree and d.get("mode")=="cheat" and d.get("agent")==agent and d.get("model")==model and d.get("reasoning_effort")==reasoning):
            continue
        valid=(d.get("execution_class")=="valid-completed-trial" and d.get("qualification_valid") is True and not (d.get("result_exception_types") or []) and d.get("reward") is not None)
        if not valid:
            invalid.append(str(p))
        elif d.get("reward") in (0,0.0):
            valid_zero.append(str(p))
        else:
            valid_nonzero.append(str(p))
print(json.dumps({"valid_zero":valid_zero,"valid_nonzero":valid_nonzero,"invalid":invalid}))
PY
}

matrix=$(scan_matrix)
python3 - "$matrix" "$TARGET" <<'PY'
import json,sys
d=json.loads(sys.argv[1]); target=int(sys.argv[2])
print(f"existing_valid_reward_zero={len(d['valid_zero'])}/{target}")
print(f"existing_valid_nonzero={len(d['valid_nonzero'])}")
print(f"existing_invalid={len(d['invalid'])}")
PY

nonzero=$(python3 - "$matrix" <<'PY'
import json,sys; print(len(json.loads(sys.argv[1])["valid_nonzero"]))
PY
)
(( nonzero == 0 )) || fail "valid nonzero cheat reward already exists; verifier is defeated"

count=$(python3 - "$matrix" <<'PY'
import json,sys; print(len(json.loads(sys.argv[1])["valid_zero"]))
PY
)

while (( count < TARGET )); do
  attempt=$((count+1))
  printf '\n=== %s FINAL CHEAT TRIAL %s/%s ===\n' "$AGENT_NAME" "$attempt" "$TARGET"
  set +e
  AGENT="$AGENT" \
  MODE=cheat \
  EXPECTED_TASK_TREE="$TREE" \
  RUNS_ROOT="$RUN_ROOT" \
    bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
  runner_status=$?
  set -e

  python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUN_ROOT" >/dev/null || true
  matrix=$(scan_matrix)

  new_nonzero=$(python3 - "$matrix" <<'PY'
import json,sys; print(len(json.loads(sys.argv[1])["valid_nonzero"]))
PY
)
  new_count=$(python3 - "$matrix" <<'PY'
import json,sys; print(len(json.loads(sys.argv[1])["valid_zero"]))
PY
)

  if (( new_nonzero > 0 )); then
    echo "STOP: valid nonzero adversarial reward; verifier/task is not cheat-safe." >&2
    exit 20
  fi
  if (( new_count == count )); then
    echo "STOP: latest adversarial attempt did not add a valid reward-0 trial. Do not auto-retry invalid/provider-blocked evidence." >&2
    exit 21
  fi
  count=$new_count
  if (( runner_status != 0 )); then
    echo "STOP: runner returned nonzero even though a valid reward-0 trial was detected; inspect evidence." >&2
    exit "$runner_status"
  fi
done

printf '\n=== DEADLINE CHEAT MATRIX REPORT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'agent=%s\n' "$AGENT_NAME"
printf 'model=%s\n' "$MODEL"
printf 'reasoning=%s\n' "$REASONING"
printf 'valid_reward_zero=%s\n' "$count"
printf 'target=%s\n' "$TARGET"
printf 'status=CHEAT_MATRIX_COMPLETE\n'
printf '=== END DEADLINE CHEAT MATRIX REPORT ===\n'
