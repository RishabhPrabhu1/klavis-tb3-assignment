#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# Live TB3 /cheat has no trial matrix dimension: one invocation per configured agent.
TARGET_VALID_CHEATS=1 exec bash "$ROOT_DIR/scripts/run-deadline-cheat-matrix.sh"
