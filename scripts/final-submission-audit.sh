#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
STANDARD_TARGET=${STANDARD_TARGET:-3}
# Live TB3 /cheat is one matrix entry per (task x agent), not trials x agent.
CHEAT_TARGET=${CHEAT_TARGET:-1}
TB3_HEAD_EXPECTED=${TB3_HEAD_EXPECTED:-"79e71650f5b6a6ef5bb46a434c7c04d7d99a9480"}

QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
RUBRIC_ROOT=${RUBRIC_ROOT:-"$HOME/.cache/klavis-tb3-runs/implementation-rubric"}
CODEX_STANDARD_ROOTS=${CODEX_STANDARD_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe:$HOME/.cache/klavis-tb3-runs/transaction-standard-final"}
CLAUDE_STANDARD_ROOTS=${CLAUDE_STANDARD_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard:$HOME/.cache/klavis-tb3-runs/transaction-claude-standard-final"}
CODEX_CHEAT_ROOTS=${CODEX_CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
CLAUDE_CHEAT_ROOTS=${CLAUDE_CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}

failures=0

check_count() {
  local label=$1 roots=$2 mode=$3 agent=$4 model=$5 reasoning=$6 reward=$7 target=$8
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
  printf '%-32s %s/%s\n' "$label" "$count" "$target"
  if (( count < target )); then failures=$((failures+1)); fi
}

check_rubric() {
  local found
  found=$(python3 - "$TREE" "$TB3_HEAD_EXPECTED" "$RUBRIC_ROOT" <<'PY'
import json,sys
from pathlib import Path
tree, tb3, root_raw=sys.argv[1:]
root=Path(root_raw).expanduser(); matches=[]
if root.exists():
    for p in root.rglob("result.json"):
        try:d=json.loads(p.read_text(encoding="utf-8"))
        except Exception:continue
        if d.get("task_tree")==tree and d.get("terminal_bench_head")==tb3 and d.get("passed") is True and not (d.get("failed") or []):
            matches.append(str(p))
print(matches[-1] if matches else "")
PY
)
  if [[ -n "$found" ]]; then
    echo "same_tree_implementation_rubric=PASS"
    echo "implementation_rubric_result=$found"
  else
    echo "same_tree_implementation_rubric=MISSING_OR_FAILED"
    failures=$((failures+1))
  fi
}

printf '=== KLAVIS FINAL SUBMISSION AUDIT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'terminal_bench_head_expected=%s\n' "$TB3_HEAD_EXPECTED"
printf 'standard_trials_per_agent=%s\n' "$STANDARD_TARGET"
printf 'cheat_trials_per_agent=%s\n' "$CHEAT_TARGET"

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

check_rubric

check_count "Codex standard reward-0" "$CODEX_STANDARD_ROOTS" standard codex openai/gpt-5.6-sol xhigh 0 "$STANDARD_TARGET"
check_count "Claude standard reward-0" "$CLAUDE_STANDARD_ROOTS" standard claude-code anthropic/claude-opus-5 max 0 "$STANDARD_TARGET"
check_count "Codex cheat reward-0" "$CODEX_CHEAT_ROOTS" cheat codex openai/gpt-5.6-sol xhigh 0 "$CHEAT_TARGET"
check_count "Claude cheat reward-0" "$CLAUDE_CHEAT_ROOTS" cheat claude-code anthropic/claude-opus-5 max 0 "$CHEAT_TARGET"

for required in \
  README.md \
  results/preflight-status.json \
  results/standard-trials.md \
  results/cheat-trials.md \
  results/failure-analysis.md \
  results/contract-coverage.md \
  results/execution-plan.md \
  results/implementation-rubric-review.md; do
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
