#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
AGENT=${AGENT:-}
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
TARGET=${TARGET_CHEATS:-1}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
TB3_HEAD_EXPECTED=${TB3_HEAD_EXPECTED:-"79e71650f5b6a6ef5bb46a434c7c04d7d99a9480"}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$CONFIRM_FREEZE" == "1" ]] || fail "set CONFIRM_FREEZE=1 only after the task tree is frozen"
[[ "$AGENT" == "codex" || "$AGENT" == "claude" ]] || fail "AGENT must be codex or claude"
[[ "$TARGET" =~ ^[1-9][0-9]*$ ]] || fail "TARGET_CHEATS must be a positive integer"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

if [[ "$AGENT" == "codex" ]]; then
  MODEL="openai/gpt-5.6-sol"; REASONING="xhigh"; AGENT_NAME="codex"
  ROOTS=${CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
  RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
  [[ -f "$HOME/.codex/auth.json" ]] || fail "Codex auth.json is missing"
else
  MODEL="anthropic/claude-opus-5"; REASONING="max"; AGENT_NAME="claude-code"
  ROOTS=${CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
  RUN_ROOT=${RUN_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
  if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" && -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && ( -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ) && -z "${ANTHROPIC_API_KEY:-}" ]]; then
    fail "Claude authentication is missing: configure a supported Claude provider route first"
  fi
fi

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree zero-model qualification marker missing: $QUAL_MARKER"
mkdir -p "$RUN_ROOT"

scan_matrix() {
  python3 - "$TREE" "$ROOTS" "$AGENT_NAME" "$MODEL" "$REASONING" "$TB3_HEAD_EXPECTED" <<'PY'
import json,sys
from pathlib import Path
tree,roots_raw,agent,model,reasoning,tb3=sys.argv[1:]
zero=[]; nonzero=[]; unparsed=[]; incomplete=[]; provenance=[]; seen=set()
for raw in roots_raw.split(":"):
    root=Path(raw).expanduser()
    if not root.exists(): continue
    for d in root.iterdir():
        if not d.is_dir() or (d/"summary.json").exists(): continue
        meta=d/"metadata.json"
        if not meta.exists(): continue
        try:m=json.loads(meta.read_text(encoding="utf-8"))
        except Exception:continue
        if m.get("task_tree")==tree and m.get("mode")=="cheat" and m.get("agent")==agent:
            incomplete.append(str(d))
    for p in root.rglob("summary.json"):
        key=str(p.resolve())
        if key in seen: continue
        seen.add(key)
        try:d=json.loads(p.read_text(encoding="utf-8"))
        except Exception:continue
        if not (d.get("task_tree")==tree and d.get("mode")=="cheat" and d.get("agent")==agent and d.get("model")==model and d.get("reasoning_effort")==reasoning): continue
        if d.get("terminal_bench_head") != tb3:
            provenance.append(str(p)); continue
        status=d.get("harbor_exit_status"); reward=d.get("reward")
        if status not in (None,0) or reward in (0,0.0): zero.append(str(p))
        elif reward is None: unparsed.append(str(p))
        else: nonzero.append(str(p))
print(json.dumps({"zero":zero,"nonzero":nonzero,"unparsed":unparsed,"incomplete":incomplete,"provenance":provenance}))
PY
}

count_key() {
  python3 - "$1" "$2" <<'PY'
import json,sys; print(len(json.loads(sys.argv[1])[sys.argv[2]]))
PY
}

matrix=$(scan_matrix)
zero=$(count_key "$matrix" zero); nonzero=$(count_key "$matrix" nonzero)
unparsed=$(count_key "$matrix" unparsed); incomplete=$(count_key "$matrix" incomplete)
provenance=$(count_key "$matrix" provenance)
(( nonzero == 0 )) || fail "same-tree adversarial trial earned nonzero reward"
(( unparsed == 0 )) || fail "same-tree adversarial trial has an unparsed successful-run reward"
(( incomplete == 0 )) || fail "incomplete same-tree adversarial evidence exists"
(( provenance == 0 )) || fail "same-tree adversarial evidence uses a different Terminal-Bench revision"

while (( zero < TARGET )); do
  before=$zero
  printf '\n=== %s ADVERSARIAL TRIAL %s/%s ===\n' "$AGENT_NAME" "$((zero+1))" "$TARGET"
  set +e
  AGENT="$AGENT" MODE=cheat EXPECTED_TASK_TREE="$TREE" EXPECTED_TB3_HEAD="$TB3_HEAD_EXPECTED" RUNS_ROOT="$RUN_ROOT" \
    bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
  runner_status=$?
  set -e
  python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUN_ROOT" >/dev/null || true
  matrix=$(scan_matrix)
  zero=$(count_key "$matrix" zero); nonzero=$(count_key "$matrix" nonzero)
  unparsed=$(count_key "$matrix" unparsed); incomplete=$(count_key "$matrix" incomplete)
  provenance=$(count_key "$matrix" provenance)
  echo "runner_status=$runner_status"
  echo "reward_zero_now=$zero/$TARGET"
  (( nonzero == 0 )) || { echo "STOP: adversarial reward was nonzero." >&2; exit 20; }
  (( unparsed == 0 )) || { echo "STOP: successful adversarial reward was unparsed." >&2; exit 21; }
  (( incomplete == 0 )) || { echo "STOP: incomplete adversarial evidence." >&2; exit 22; }
  (( provenance == 0 )) || { echo "STOP: wrong Terminal-Bench provenance." >&2; exit 24; }
  (( zero > before )) || { echo "STOP: latest attempt did not produce a reward-0 result." >&2; exit 23; }
done

printf '\n=== ADVERSARIAL MATRIX REPORT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'agent=%s\nmodel=%s\nreasoning=%s\n' "$AGENT_NAME" "$MODEL" "$REASONING"
printf 'terminal_bench_head=%s\nreward_zero=%s\ntarget=%s\n' "$TB3_HEAD_EXPECTED" "$zero" "$TARGET"
printf 'status=CHEAT_MATRIX_COMPLETE\n'
printf '=== END ADVERSARIAL MATRIX REPORT ===\n'
