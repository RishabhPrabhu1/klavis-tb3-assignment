#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/hermetic-build-cache"
TEST_PYTHON=${TEST_PYTHON:-python3}

if ! "$TEST_PYTHON" -c 'import pytest' >/dev/null 2>&1; then
  echo "pytest is not available in TEST_PYTHON=$TEST_PYTHON" >&2
  echo "Install pytest==9.1.1 and pytest-json-ctrf==0.5.2 in an isolated environment." >&2
  exit 2
fi

correct_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-build-reference.XXXXXX")
trap 'find "$correct_env" -type f -name "*.pyc" -delete 2>/dev/null || true; find "$correct_env" -depth -type d -empty -delete 2>/dev/null || true' EXIT
cp -R "$TASK_DIR/environment/." "$correct_env/"
BUILD_SYS_ROOT="$correct_env/buildsys" "$TASK_DIR/solution/solve.sh"
TB3_AGENT_APP_ROOT="$correct_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests/test_build_cache.py"
