#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-"4eaf21ae9456395fb080be497852c0ff9623b8fa"}
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}

actual_tree=$(git -C "$ROOT_DIR" rev-parse HEAD:tasks/build-snapshot-publish)
if [[ "$actual_tree" != "$EXPECTED_TASK_TREE" ]]; then
  echo "ERROR: expected task tree $EXPECTED_TASK_TREE, found $actual_tree" >&2
  exit 2
fi
if [[ -n "$(git -C "$ROOT_DIR" status --porcelain -- tasks/build-snapshot-publish)" ]]; then
  echo "ERROR: task tree is dirty" >&2
  exit 2
fi

TEST_PYTHON=$(bash "$ROOT_DIR/scripts/setup-local-verifier-env.sh")
export TEST_PYTHON

echo "Using TEST_PYTHON=$TEST_PYTHON"

echo "==> static checks"
TB3_REPO="$TB3_REPO" bash "$ROOT_DIR/scripts/run-static-checks.sh"

echo "==> reference/oracle full verifier"
bash "$ROOT_DIR/scripts/run-local-reference-tests.sh"

echo "==> core mutation checks"
bash "$ROOT_DIR/scripts/run-mutation-checks.sh"

echo "==> lifecycle/GC mutation checks"
bash "$ROOT_DIR/scripts/run-lifecycle-mutation-checks.sh"

echo "LOCAL DETERMINISTIC QUALIFICATION PASSED"
echo "task_tree=$actual_tree"
echo "test_python=$TEST_PYTHON"
