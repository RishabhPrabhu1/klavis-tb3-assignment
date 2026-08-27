#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUNNER="$ROOT_DIR/scripts/run-candidate-trial.sh"
FROZEN_TASK_TREE="fc064cac2fb1241b68a98475dbc8ea04fbe579cc"
N_ATTEMPTS=${N_ATTEMPTS:-3}
AGENTS=${AGENTS:-codex}
CONFIRM_FROZEN=${CONFIRM_FROZEN:-0}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/standard"}
[[ "$N_ATTEMPTS" =~ ^[1-9][0-9]*$ ]] && (( N_ATTEMPTS <= 10 )) || { echo "N_ATTEMPTS must be 1..10" >&2; exit 2; }
[[ "$AGENTS" == codex || "$AGENTS" == claude || "$AGENTS" == both ]] || { echo "AGENTS must be codex, claude, or both" >&2; exit 2; }
[[ "$CONFIRM_FROZEN" == 1 ]] || { echo "Final standard trials require CONFIRM_FROZEN=1 after reviewer approval of a genuine task-caused model failure." >&2; exit 2; }
if [[ -n "${EXPECTED_TASK_TREE:-}" && "$EXPECTED_TASK_TREE" != "$FROZEN_TASK_TREE" ]]; then echo "Wrapper frozen to $FROZEN_TASK_TREE" >&2; exit 2; fi
run_agent(){ local agent=$1 label=$2; for attempt in $(seq 1 "$N_ATTEMPTS"); do printf '\n=== %s standard trial %s/%s ===\n' "$label" "$attempt" "$N_ATTEMPTS"; AGENT="$agent" MODE=standard EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" RUNS_ROOT="$RUNS_ROOT" "$RUNNER"; done; }
case "$AGENTS" in codex) run_agent codex "Codex GPT-5.6 Sol/xhigh";; claude) run_agent claude "Claude Code Opus 5/max";; both) run_agent codex "Codex GPT-5.6 Sol/xhigh"; run_agent claude "Claude Code Opus 5/max";; esac
printf '\nStandard matrix complete. Evidence root: %s\n' "$RUNS_ROOT"
