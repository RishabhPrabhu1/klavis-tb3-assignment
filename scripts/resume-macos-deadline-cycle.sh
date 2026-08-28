#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"

fail() { echo "ERROR: $*" >&2; exit 2; }
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

# macOS Bash 3.2 has no BASHPID special variable. The downstream runners use
# it only for collision-resistant local evidence/job names.
if [[ -z "${BASHPID-}" ]]; then
  export BASHPID="$$"
fi

printf '\n=== MACOS DEADLINE RESUME ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'qualification_marker=%s\n' "$QUAL_MARKER"
printf 'qualification=%s\n' "$([[ -f "$QUAL_MARKER" ]] && echo PRESENT || echo MISSING)"
printf 'bash_version=%s\n' "$BASH_VERSION"
printf 'portable_pid=%s\n' "$BASHPID"

exec bash "$ROOT_DIR/scripts/resume-deadline-cycle.sh"
