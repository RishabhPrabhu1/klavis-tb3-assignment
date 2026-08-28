#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# Compatibility wrapper retained for older local notes. The historical version
# was pinned to a superseded calibration tree. All frontier launches now flow
# through the exact-current-tree qualification + implementation-rubric gate.
echo "NOTE: run-fast-frontier-cycle.sh is a compatibility wrapper; using the guarded current-tree frontier entry point."
exec bash "$ROOT_DIR/scripts/run-next-frontier-step.sh"
