#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
AGENT=${AGENT:-}
MODE=${MODE:-standard}
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
TARGET=${TARGET_VALID_ZEROES:-3}
MAX_PARALLEL=${MAX_PARALLEL:-2}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
TB3_HEAD_EXPECTED=${TB3_HEAD_EXPECTED:-"79e71650f5b6a6ef5bb46a434c7c04d7d99a9480"}

fail() { echo "ERROR: $*" >&2; exit 2; }
unique_id() { python3 - <<'PY'
import uuid
print(uuid.uuid4().hex[:12])
PY
}

[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after reviewer approval that this exact task tree is frozen"
[[ "$AGENT" == "codex" || "$AGENT" == "claude" ]] || fail "AGENT must be codex or claude"
[[ "$MODE" == "standard" || "$MODE" == "cheat" ]] || fail "MODE must be standard or cheat"
[[ "$TARGET" =~ ^[1-9][0-9]*$ ]] || fail "TARGET_VALID_ZEROES must be a positive integer"
[[ "$MAX_PARALLEL" =~ ^[1-3]$ ]] || fail "MAX_PARALLEL must be 1, 2, or 3"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required for candidate trials"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree zero-model qualification marker missing: $QUAL_MARKER"

if [[ "$AGENT" == "codex" ]]; then
  AGENT_NAME="codex"
  MODEL="openai/gpt-5.6-sol"
  REASONING="xhigh"
  [[ -f "$HOME/.codex/auth.json" ]] || fail "Codex auth.json is missing"
  if [[ "$MODE" == "standard" ]]; then
    ROOTS=${MATRIX_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe:$HOME/.cache/klavis-tb3-runs/transaction-standard-final"}
    RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-final"}
  else
    ROOTS=${MATRIX_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
    RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
  fi
else
  AGENT_NAME="claude-code"
  MODEL="anthropic/claude-opus-5"
  REASONING="max"
  if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" && -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && ( -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ) && -z "${ANTHROPIC_API_KEY:-}" ]]; then
    fail "Claude auth missing: configure OAuth, Bedrock, or Anthropic API credentials first"
  fi
  if [[ "$MODE" == "standard" ]]; then
    ROOTS=${MATRIX_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard:$HOME/.cache/klavis-tb3-runs/transaction-claude-standard-final"}
    RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard-final"}
  else
    ROOTS=${MATRIX_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
    RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
  fi
fi
mkdir -p "$RUN_ROOT"

scan_matrix() {
  python3 - "$TREE" "$ROOTS" "$MODE" "$AGENT_NAME" "$MODEL" "$REASONING" <<'PY'
import json, sys
from pathlib import Path
tree, roots_raw, mode, agent, model, reasoning = sys.argv[1:]
zero=[]; nonzero=[]; invalid=[]; incomplete=[]
seen=set()
for raw in roots_raw.split(":"):
    root=Path(raw).expanduser()
    if not root.exists(): continue
    for d in root.iterdir():
        if not d.is_dir() or (d/"summary.json").exists(): continue
        meta=d/"metadata.json"
        if not meta.exists(): continue
        try: m=json.loads(meta.read_text(encoding="utf-8"))
        except Exception: continue
        if m.get("task_tree")==tree and m.get("mode")==mode and m.get("agent")==agent:
            incomplete.append(str(d))
    for p in root.rglob("summary.json"):
        key=str(p.resolve())
        if key in seen: continue
        seen.add(key)
        try: d=json.loads(p.read_text(encoding="utf-8"))
        except Exception: continue
        if not (d.get("task_tree")==tree and d.get("mode")==mode and d.get("agent")==agent and d.get("model")==model and d.get("reasoning_effort")==reasoning):
            continue
        valid=(d.get("execution_class")=="valid-completed-trial" and d.get("qualification_valid") is True and not (d.get("result_exception_types") or []) and d.get("reward") is not None)
        if not valid: invalid.append(str(p))
        elif d.get("reward") in (0,0.0): zero.append(str(p))
        else: nonzero.append(str(p))
print(json.dumps({"zero":zero,"nonzero":nonzero,"invalid":invalid,"incomplete":incomplete}))
PY
}

count_key() {
  python3 - "$1" "$2" <<'PY'
import json,sys
print(len(json.loads(sys.argv[1])[sys.argv[2]]))
PY
}

state=$(scan_matrix)
zero=$(count_key "$state" zero)
nonzero=$(count_key "$state" nonzero)
incomplete=$(count_key "$state" incomplete)

printf 'Existing %s/%s valid reward-0: %s/%s\n' "$AGENT_NAME" "$MODE" "$zero" "$TARGET"
(( nonzero == 0 )) || fail "valid nonzero same-tree result already exists; frozen candidate is invalid"
(( incomplete == 0 )) || fail "incomplete same-tree evidence exists; inspect/resume it before launching parallel trials"

while (( zero < TARGET )); do
  missing=$((TARGET-zero))
  batch=$missing
  (( batch > MAX_PARALLEL )) && batch=$MAX_PARALLEL
  before_zero=$zero
  before_invalid=$(count_key "$state" invalid)

  printf '\n=== PARALLEL %s %s BATCH: %s trial(s), %s/%s already valid ===\n' \
    "$AGENT_NAME" "$MODE" "$batch" "$zero" "$TARGET"

  batch_dir="$RUN_ROOT/.parallel-launch-$(date -u +%Y%m%dT%H%M%SZ)-$(unique_id)"
  mkdir -p "$batch_dir"
  pids=()
  for i in $(seq 1 "$batch"); do
    (
      export AGENT MODE
      export EXPECTED_TASK_TREE="$TREE"
      export RUNS_ROOT="$RUN_ROOT"
      # macOS ships Bash 3.2, which has no BASHPID. The candidate runner only
      # needs this value for unique evidence/job names, so provide a UUID-derived
      # value per child process to avoid same-second collisions.
      export BASHPID="$(unique_id)"
      if [[ "$MODE" == "cheat" ]]; then
        export EXPECTED_TB3_HEAD="$TB3_HEAD_EXPECTED"
      fi
      bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
    ) >"$batch_dir/trial-$i.log" 2>&1 &
    pids+=("$!")
  done

  statuses=()
  for pid in "${pids[@]}"; do
    set +e
    wait "$pid"
    statuses+=("$?")
    set -e
  done

  python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUN_ROOT" >/dev/null 2>&1 || true
  state=$(scan_matrix)
  zero=$(count_key "$state" zero)
  nonzero=$(count_key "$state" nonzero)
  invalid=$(count_key "$state" invalid)
  incomplete=$(count_key "$state" incomplete)

  echo "batch_logs=$batch_dir"
  echo "runner_statuses=${statuses[*]}"
  echo "valid_reward_zero_now=$zero/$TARGET"
  echo "invalid_now=$invalid"
  echo "incomplete_now=$incomplete"

  (( nonzero == 0 )) || { echo "STOP: a valid nonzero result was produced." >&2; exit 20; }
  (( incomplete == 0 )) || { echo "STOP: batch left incomplete evidence." >&2; exit 21; }
  if (( zero - before_zero != batch )); then
    echo "STOP: not every launched trial added a valid reward-0 result; do not auto-retry." >&2
    exit 22
  fi
  if (( invalid > before_invalid )); then
    echo "STOP: batch added invalid execution evidence; do not auto-retry." >&2
    exit 23
  fi
done

printf '\n=== PARALLEL FINAL MATRIX REPORT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'agent=%s\n' "$AGENT_NAME"
printf 'model=%s\n' "$MODEL"
printf 'reasoning=%s\n' "$REASONING"
printf 'mode=%s\n' "$MODE"
printf 'valid_reward_zero=%s\n' "$zero"
printf 'target=%s\n' "$TARGET"
printf 'max_parallel=%s\n' "$MAX_PARALLEL"
if [[ "$MODE" == "cheat" ]]; then printf 'terminal_bench_head=%s\n' "$TB3_HEAD_EXPECTED"; fi
printf 'status=MATRIX_COMPLETE\n'
printf '=== END PARALLEL FINAL MATRIX REPORT ===\n'
