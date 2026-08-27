#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CHEAT_EVIDENCE_ROOT=${CHEAT_EVIDENCE_ROOT:-"$HOME/.cache/klavis-tb3-runs/cheat"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/standard-probe"}
mkdir -p "$CHEAT_EVIDENCE_ROOT" "$RUNS_ROOT"

# Correct any stale console-only classifications before the strong runner's
# cheat-evidence gate examines them.
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$CHEAT_EVIDENCE_ROOT"

set +e
CHEAT_EVIDENCE_ROOT="$CHEAT_EVIDENCE_ROOT" \
RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-codex-strong-test.sh"
status=$?
set -e

# If a trial actually ran, make result.json exception_info authoritative in its
# machine-readable summary. This is safe when the strong runner exits at a gate:
# the auditor simply finds nothing new to change.
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUNS_ROOT"
exit "$status"
