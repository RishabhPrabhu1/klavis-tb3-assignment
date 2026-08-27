#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
TARGET=${TARGET_TRIALS:-3}

QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
CODEX_STANDARD_ROOTS=${CODEX_STANDARD_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe:$HOME/.cache/klavis-tb3-runs/transaction-standard-final"}
CLAUDE_STANDARD_ROOTS=${CLAUDE_STANDARD_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard"}
CODEX_CHEAT_ROOTS=${CODEX_CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
CLAUDE_CHEAT_ROOTS=${CLAUDE_CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}

failures=0

check_count() {
  local label=$1 roots=$2 mode=$3 agent=$4 model=$5 reasoning=$6 reward=$7
  local count
  count=$(python3 - "$TREE" "$roots" "$mode" "$agent" "$model" "$reasoning" "$reward" <<'PY'
import json, sys
from pathlib import Path
tree, roots_raw, mode, agent, model, reasoning, reward_raw = sys.argv[1:]
reward = float(reward_raw)
seen=set(); count=0
for raw in roots_raw.split(":"):
    root=Path(raw).expanduser()
    if not root.exists():
        continue
    for path in root.rglob("summary.json"):
        try: data=json.loads(path.read_text(encoding="utf-8"))
        except Exception: continue
        key=str(path.resolve())
        if key in seen: continue
        seen.add(key)
        tests=data.get("tests") if isinstance(data.get("tests"),dict) else {}
        valid=(
            data.get("task_tree")==tree
            and data.get("mode")==mode
            and data.get("agent")==agent
            and data.get("model")==model
            and data.get("reasoning_effort")==reasoning
            and data.get("execution_class")=="valid-completed-trial"
            and data.get("qualification_valid") is True
            and not (data.get("result_exception_types") or [])
            and data.get("reward") is not None
            and float(data.get("reward"))==reward
        )
        if valid:
            count += 1
print(count)
PY
)
  printf '%-32s %s/%s\n' "$label" "$count" "$TARGET"
  if (( count < TARGET )); then failures=$((failures+1)); fi
}

printf '=== KLAVIS FINAL SUBMISSION AUDIT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'target_trials_per_agent=%s\n' "$TARGET"

if [[ -n "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]]; then
  echo "task_tree_clean=NO"
  failures=$((failures+1))
else
  echo "task_tree_clean=YES"
fi

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
if [[ -f "$QUAL_MARKER" ]]; then
  echo "same_tree_zero_model_qualification=PASS"
else
  echo "same_tree_zero_model_qualification=MISSING"
  failures=$((failures+1))
fi

check_count "Codex standard reward-0" "$CODEX_STANDARD_ROOTS" standard codex openai/gpt-5.6-sol xhigh 0
check_count "Claude standard reward-0" "$CLAUDE_STANDARD_ROOTS" standard claude-code anthropic/claude-opus-5 max 0
check_count "Codex cheat reward-0" "$CODEX_CHEAT_ROOTS" cheat codex openai/gpt-5.6-sol xhigh 0
check_count "Claude cheat reward-0" "$CLAUDE_CHEAT_ROOTS" cheat claude-code anthropic/claude-opus-5 max 0

for required in \
  README.md \
  results/preflight-status.json \
  results/standard-trials.md \
  results/cheat-trials.md \
  results/failure-analysis.md \
  results/contract-coverage.md; do
  if [[ -f "$ROOT_DIR/$required" ]]; then
    printf 'document %-36s present\n' "$required"
  else
    printf 'document %-36s MISSING\n' "$required"
    failures=$((failures+1))
  fi
done

if (( failures == 0 )); then
  echo "FINAL_STATUS=READY_FOR_SUBMISSION"
  exit 0
fi

echo "FINAL_STATUS=NOT_READY"
echo "outstanding_checks=$failures"
exit 1
