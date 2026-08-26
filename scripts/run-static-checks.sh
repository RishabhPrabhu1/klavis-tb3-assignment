#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TB3_REPO=${TB3_REPO:-}
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
CHECKS_DIR="${TB3_REPO}/scripts/checks"

if [[ -z "$TB3_REPO" ]]; then
  echo "Set TB3_REPO to a checkout of terminal-bench." >&2
  exit 2
fi
if [[ ! -d "$CHECKS_DIR" ]]; then
  echo "TB3_REPO does not contain scripts/checks/: $TB3_REPO" >&2
  exit 2
fi

check_root=$(mktemp -d "${TMPDIR:-/tmp}/tb3-static-task.XXXXXX")
check_task="$check_root/build-snapshot-publish"
trap 'rm -rf "$check_root"' EXIT
cp -R "$TASK_DIR" "$check_task"

checks=(
  check-canary.sh
  check-dockerfile-references.sh
  check-dockerfile-sanity.sh
  check-dockerfile-platform.sh
  check-task-absolute-path.sh
  check-test-file-references.sh
  check-test-sh-sanity.sh
  check-task-fields.sh
  check-task-timeout.sh
  check-instruction-suffix.sh
  check-gpu-types.sh
  check-allow-internet.sh
  check-no-allow-internet-true.sh
  check-task-slug.sh
  check-task-package-name.sh
  check-separate-verifier.sh
  check-verifier-tooling-baked.sh
  check-trial-network-fetch.sh
  check-pip-pinning.sh
  check-pytest-version.sh
  check-nproc.sh
  check-compose-host-binds.sh
)

for name in "${checks[@]}"; do
  check="$CHECKS_DIR/$name"
  [[ -f "$check" ]] || {
    echo "live TB3 check is missing: $check" >&2
    exit 2
  }
  echo "==> $name"
  bash "$check" "$check_task"
done
