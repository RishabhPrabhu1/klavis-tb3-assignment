#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
FROZEN_TASK_TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-"$FROZEN_TASK_TREE"}
[[ "$FROZEN_TASK_TREE" == "$EXPECTED_TASK_TREE" ]] || { echo "expected task tree $EXPECTED_TASK_TREE, found $FROZEN_TASK_TREE" >&2; exit 2; }
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/standard-diagnostic"}
CHEAT_EVIDENCE_ROOT=${CHEAT_EVIDENCE_ROOT:-"$HOME/.cache/klavis-tb3-runs/cheat"}
ALLOW_CHEAT_SAFETY_BLOCK=${ALLOW_CHEAT_SAFETY_BLOCK:-0}
[[ "$ALLOW_CHEAT_SAFETY_BLOCK" == "1" ]] || { echo "Refusing diagnostic: set ALLOW_CHEAT_SAFETY_BLOCK=1 only for an audited provider safety block." >&2; exit 2; }
mkdir -p "$RUNS_ROOT" "$CHEAT_EVIDENCE_ROOT"
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$CHEAT_EVIDENCE_ROOT"
python3 - "$CHEAT_EVIDENCE_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json,sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; blocked=[]
for path in root.rglob('summary.json'):
    try:data=json.loads(path.read_text())
    except Exception:continue
    if data.get('mode')=='cheat' and data.get('agent')=='codex' and data.get('model')=='openai/gpt-5.6-sol' and data.get('reasoning_effort')=='xhigh' and data.get('task_tree')==tree and data.get('execution_class')!='valid-completed-trial' and data.get('result_exception_types'): blocked.append(path)
if not blocked: raise SystemExit('No audited invalid Codex /cheat exception evidence found; refusing bypass.')
print(f'Cheat remains INVALID/OUTSTANDING; diagnostic exception evidence: {sorted(blocked)[-1]}')
PY
set +e
AGENT=codex MODE=standard EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" RUNS_ROOT="$RUNS_ROOT" bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
status=$?
set -e
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUNS_ROOT"
exit "$status"
