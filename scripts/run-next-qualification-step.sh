#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# Single authoritative qualification entry point. This avoids maintaining a
# second marker schema or stale verifier-count assumptions in a shortcut script.
exec bash "$ROOT_DIR/scripts/run-final-tree-deadline-qualification.sh"
