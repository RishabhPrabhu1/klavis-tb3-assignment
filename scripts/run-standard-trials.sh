#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUNNER="$ROOT_DIR/scripts/run-candidate-trial.sh"
FROZEN_TASK_TREE="d84a5bf3df6a2c3ed7a523c7fee072936f4029e4"
N_ATTEMPTS=${N_ATTEMPTS:-3}
AGENTS=${AGENTS:-both}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/standard"}

if ! [[ "$N_ATTEMPTS" =~ ^[1-9][0-9]*$ ]] || (( N_ATTEMPTS > 10 )); then
  echo "N_ATTEMPTS must be an integer from 1 to 10" >&2
  exit 2
fi
if [[ "$AGENTS" != "codex" && "$AGENTS" != "claude" && "$AGENTS" != "both" ]]; then
  echo "AGENTS must be codex, claude, or both" >&2
  exit 2
fi
if [[ -n "${EXPECTED_TASK_TREE:-}" && "$EXPECTED_TASK_TREE" != "$FROZEN_TASK_TREE" ]]; then
  echo "This final-trial wrapper is frozen to task tree $FROZEN_TASK_TREE" >&2
  echo "Requested EXPECTED_TASK_TREE=$EXPECTED_TASK_TREE" >&2
  exit 2
fi
if [[ ! -x "$RUNNER" ]]; then
  echo "Candidate runner is not executable: $RUNNER" >&2
  exit 2
fi

run_agent() {
  local agent=$1
  local label=$2
  local attempt
  for attempt in $(seq 1 "$N_ATTEMPTS"); do
    printf '\n=== %s standard trial %s/%s ===\n' "$label" "$attempt" "$N_ATTEMPTS"
    AGENT="$agent" \
    MODE=standard \
    EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" \
    RUNS_ROOT="$RUNS_ROOT" \
    "$RUNNER"
  done
}

case "$AGENTS" in
  codex)
    run_agent codex "Codex GPT-5.6 Sol/xhigh"
    ;;
  claude)
    run_agent claude "Claude Code Opus 5/max"
    ;;
  both)
    run_agent codex "Codex GPT-5.6 Sol/xhigh"
    run_agent claude "Claude Code Opus 5/max"
    ;;
esac

printf '\nStandard matrix complete. Evidence root: %s\n' "$RUNS_ROOT"
