#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
TB3_HEAD_EXPECTED=${TB3_HEAD_EXPECTED:-"79e71650f5b6a6ef5bb46a434c7c04d7d99a9480"}
STANDARD_TARGET=${STANDARD_TARGET:-3}
CHEAT_TARGET=${CHEAT_TARGET:-1}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
RUBRIC_ROOT=${RUBRIC_ROOT:-"$HOME/.cache/klavis-tb3-runs/implementation-rubric"}
CODEX_STANDARD_ROOTS=${CODEX_STANDARD_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe:$HOME/.cache/klavis-tb3-runs/transaction-standard-final"}
CLAUDE_STANDARD_ROOTS=${CLAUDE_STANDARD_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-standard:$HOME/.cache/klavis-tb3-runs/transaction-claude-standard-final"}
CODEX_CHEAT_ROOTS=${CODEX_CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final"}
CLAUDE_CHEAT_ROOTS=${CLAUDE_CHEAT_ROOTS:-"$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat"}
failures=0

count_standard() {
  python3 - "$TREE" "$1" "$2" "$3" "$4" <<'PY'
import json,sys
from pathlib import Path
tree,roots_raw,agent,model,reasoning=sys.argv[1:]
seen=set(); count=0
for raw in roots_raw.split(":"):
    root=Path(raw).expanduser()
    if not root.exists(): continue
    for p in root.rglob("summary.json"):
        key=str(p.resolve())
        if key in seen: continue
        seen.add(key)
        try:d=json.loads(p.read_text(encoding="utf-8"))
        except Exception:continue
        if (d.get("task_tree")==tree and d.get("mode")=="standard" and d.get("agent")==agent
            and d.get("model")==model and d.get("reasoning_effort")==reasoning
            and d.get("evidence_audited") is True and d.get("execution_class")=="valid-completed-trial"
            and d.get("qualification_valid") is True and not (d.get("result_exception_types") or [])
            and d.get("reward") in (0,0.0)):
            count+=1
print(count)
PY
}

count_cheat_zero() {
  python3 - "$TREE" "$1" "$2" "$3" "$4" "$TB3_HEAD_EXPECTED" <<'PY'
import json,sys
from pathlib import Path
tree,roots_raw,agent,model,reasoning,tb3=sys.argv[1:]
seen=set(); zero=0; bad=0
for raw in roots_raw.split(":"):
    root=Path(raw).expanduser()
    if not root.exists(): continue
    for p in root.rglob("summary.json"):
        key=str(p.resolve())
        if key in seen: continue
        seen.add(key)
        try:d=json.loads(p.read_text(encoding="utf-8"))
        except Exception:continue
        if not (d.get("task_tree")==tree and d.get("mode")=="cheat" and d.get("agent")==agent
                and d.get("model")==model and d.get("reasoning_effort")==reasoning): continue
        if d.get("terminal_bench_head") != tb3:
            bad+=1; continue
        status=d.get("harbor_exit_status"); reward=d.get("reward")
        if status not in (None,0) or reward in (0,0.0): zero+=1
        else: bad+=1
print(f"{zero} {bad}")
PY
}

printf '=== KLAVIS FINAL SUBMISSION AUDIT ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'terminal_bench_head_expected=%s\n' "$TB3_HEAD_EXPECTED"

if python3 "$ROOT_DIR/scripts/submission-consistency-audit.py"; then
  echo "repository_consistency=PASS"
else
  echo "repository_consistency=FAIL"; failures=$((failures+1))
fi

if [[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]]; then
  echo "task_tree_clean=YES"
else
  echo "task_tree_clean=NO"; failures=$((failures+1))
fi

QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
if [[ -f "$QUAL_MARKER" ]] && python3 - "$QUAL_MARKER" "$TREE" "$TB3_HEAD_EXPECTED" <<'PY'
import sys
from pathlib import Path
p=Path(sys.argv[1]); tree=sys.argv[2]; tb3=sys.argv[3]; vals={}
for line in p.read_text(encoding="utf-8").splitlines():
    if "=" in line:
        k,v=line.split("=",1); vals[k.strip()]=v.strip()
expected={"task_tree":tree,"terminal_bench_head":tb3,"static_checks":"PASS","harbor_oracle":"1","harbor_nop":"0","sol_calls":"0"}
for k,v in expected.items():
    if vals.get(k)!=v: raise SystemExit(f"{k} mismatch")
if int(vals.get("oracle_tests","0")) < 68: raise SystemExit("oracle_tests < 68")
PY
then
  echo "same_tree_zero_model_qualification=PASS"
else
  echo "same_tree_zero_model_qualification=MISSING_OR_INVALID"; failures=$((failures+1))
fi

rubric=$(python3 - "$TREE" "$TB3_HEAD_EXPECTED" "$RUBRIC_ROOT" <<'PY'
import json,sys
from pathlib import Path
tree,tb3,raw=sys.argv[1:]; root=Path(raw).expanduser(); ok=False
if root.exists():
    for p in root.rglob("result.json"):
        try:d=json.loads(p.read_text(encoding="utf-8"))
        except Exception:continue
        if d.get("task_tree")==tree and d.get("terminal_bench_head")==tb3 and d.get("passed") is True and not (d.get("failed") or []): ok=True
print("PASS" if ok else "MISSING_OR_FAILED")
PY
)
echo "same_tree_implementation_rubric=$rubric"
[[ "$rubric" == "PASS" ]] || failures=$((failures+1))

codex_standard=$(count_standard "$CODEX_STANDARD_ROOTS" codex openai/gpt-5.6-sol xhigh)
claude_standard=$(count_standard "$CLAUDE_STANDARD_ROOTS" claude-code anthropic/claude-opus-5 max)
printf 'Codex standard reward-0          %s/%s\n' "$codex_standard" "$STANDARD_TARGET"
printf 'Claude standard reward-0         %s/%s\n' "$claude_standard" "$STANDARD_TARGET"
(( codex_standard >= STANDARD_TARGET )) || failures=$((failures+1))
(( claude_standard >= STANDARD_TARGET )) || failures=$((failures+1))

read -r codex_cheat codex_cheat_bad <<<"$(count_cheat_zero "$CODEX_CHEAT_ROOTS" codex openai/gpt-5.6-sol xhigh)"
read -r claude_cheat claude_cheat_bad <<<"$(count_cheat_zero "$CLAUDE_CHEAT_ROOTS" claude-code anthropic/claude-opus-5 max)"
printf 'Codex cheat reward-0             %s/%s (bad=%s)\n' "$codex_cheat" "$CHEAT_TARGET" "$codex_cheat_bad"
printf 'Claude cheat reward-0            %s/%s (bad=%s)\n' "$claude_cheat" "$CHEAT_TARGET" "$claude_cheat_bad"
(( codex_cheat >= CHEAT_TARGET && codex_cheat_bad == 0 )) || failures=$((failures+1))
(( claude_cheat >= CHEAT_TARGET && claude_cheat_bad == 0 )) || failures=$((failures+1))

for required in \
  README.md \
  results/preflight-status.json \
  results/validation.md \
  results/standard-trials.md \
  results/cheat-trials.md \
  results/failure-analysis.md \
  results/contract-coverage.md \
  results/environment.md \
  results/implementation-rubric-review.md; do
  if [[ -f "$ROOT_DIR/$required" ]]; then
    printf 'document %-38s present\n' "$required"
  else
    printf 'document %-38s MISSING\n' "$required"; failures=$((failures+1))
  fi
done

if (( failures == 0 )); then
  echo "FINAL_STATUS=READY_FOR_SUBMISSION"
  exit 0
fi

echo "FINAL_STATUS=NOT_READY"
echo "outstanding_checks=$failures"
exit 1
