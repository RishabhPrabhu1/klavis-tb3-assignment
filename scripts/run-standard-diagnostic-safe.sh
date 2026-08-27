#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FROZEN_TASK_TREE="17291a73dc954c66db0ef5cc6cf2f70fe1c85db4"
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/standard-diagnostic"}
CHEAT_EVIDENCE_ROOT=${CHEAT_EVIDENCE_ROOT:-"$HOME/.cache/klavis-tb3-runs/cheat"}
ALLOW_CHEAT_SAFETY_BLOCK=${ALLOW_CHEAT_SAFETY_BLOCK:-0}

if [[ "$ALLOW_CHEAT_SAFETY_BLOCK" != "1" ]]; then
  echo "Refusing diagnostic: set ALLOW_CHEAT_SAFETY_BLOCK=1 only when /cheat is outstanding because of an invalid provider safety block." >&2
  exit 2
fi

mkdir -p "$RUNS_ROOT" "$CHEAT_EVIDENCE_ROOT"
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$CHEAT_EVIDENCE_ROOT"

# Require evidence that the cheat gate is outstanding because an attempted
# Codex run ended with an agent exception. This does NOT convert that run into a
# pass; it only permits one ordinary diagnostic while cheat remains unresolved.
python3 - "$CHEAT_EVIDENCE_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json
import sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser()
tree = sys.argv[2]
blocked = []
for path in root.rglob("summary.json"):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        continue
    if (
        data.get("mode") == "cheat"
        and data.get("agent") == "codex"
        and data.get("model") == "openai/gpt-5.6-sol"
        and data.get("reasoning_effort") == "xhigh"
        and data.get("task_tree") == tree
        and data.get("execution_class") != "valid-completed-trial"
        and data.get("result_exception_types")
    ):
        blocked.append(path)
if not blocked:
    raise SystemExit("No audited invalid Codex /cheat exception evidence found; refusing bypass.")
print(f"Cheat remains INVALID/OUTSTANDING; diagnostic exception evidence: {sorted(blocked)[-1]}")
PY

set +e
AGENT=codex \
MODE=standard \
EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" \
RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
status=$?
set -e

python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUNS_ROOT"
exit "$status"
