#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TB3_REPO=${TB3_REPO:-}
TASK_DIR="$ROOT_DIR/tasks/hermetic-build-cache"

if [[ -z "$TB3_REPO" ]]; then
  echo "Set TB3_REPO to a checkout of terminal-bench-3." >&2
  exit 2
fi
if [[ ! -d "$TB3_REPO/checks" ]]; then
  echo "TB3_REPO does not contain checks/: $TB3_REPO" >&2
  exit 2
fi

check_root=$(mktemp -d "${TMPDIR:-/tmp}/tb3-static-task.XXXXXX")
check_task="$check_root/hermetic-build-cache"
trap 'find "$check_root" -type f -name "*.pyc" -delete 2>/dev/null || true; find "$check_root" -depth -type d -empty -delete 2>/dev/null || true' EXIT
cp -R "$TASK_DIR" "$check_task"

for check in "$TB3_REPO"/checks/check-*.sh; do
  echo "==> $(basename "$check")"
  bash "$check" "$check_task"
done
