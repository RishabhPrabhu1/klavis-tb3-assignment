#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUNNER="$ROOT_DIR/scripts/run-candidate-trial.sh"
FROZEN_TASK_TREE="fc064cac2fb1241b68a98475dbc8ea04fbe579cc"
AGENTS=${AGENTS:-codex}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/cheat"}

if [[ "$AGENTS" != "codex" && "$AGENTS" != "claude" && "$AGENTS" != "both" ]]; then
  echo "AGENTS must be codex, claude, or both" >&2
  exit 2
fi
if [[ -n "${EXPECTED_TASK_TREE:-}" && "$EXPECTED_TASK_TREE" != "$FROZEN_TASK_TREE" ]]; then
  echo "This adversarial wrapper is frozen to task tree $FROZEN_TASK_TREE" >&2
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
  printf '\n=== %s adversarial trial ===\n' "$label"
  AGENT="$agent" MODE=cheat EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" RUNS_ROOT="$RUNS_ROOT" "$RUNNER"
}

case "$AGENTS" in
  codex) run_agent codex "Codex GPT-5.6 Sol/xhigh" ;;
  claude) run_agent claude "Claude Code Opus 5/max" ;;
  both) run_agent codex "Codex GPT-5.6 Sol/xhigh"; run_agent claude "Claude Code Opus 5/max" ;;
esac

printf '\nAdversarial matrix complete. Evidence root: %s\n' "$RUNS_ROOT"
