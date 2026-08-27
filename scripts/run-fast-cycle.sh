#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

printf '\n############################################################\n'
printf '# KLAVIS TB3 FAST CYCLE: ZERO-MODEL QUALIFICATION\n'
printf '############################################################\n'
bash "$ROOT_DIR/scripts/run-next-qualification-step.sh"

printf '\n############################################################\n'
printf '# KLAVIS TB3 FAST CYCLE: GUARDED FRONTIER MEASUREMENT\n'
printf '############################################################\n'
bash "$ROOT_DIR/scripts/run-fast-frontier-cycle.sh"
