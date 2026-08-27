#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/cheat"}
AGENTS=${AGENTS:-codex}
mkdir -p "$RUNS_ROOT"

set +e
AGENTS="$AGENTS" RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-cheat-trials.sh"
status=$?
set -e

python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUNS_ROOT"
exit "$status"
