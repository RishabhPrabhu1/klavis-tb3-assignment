#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
TEST_PYTHON=${TEST_PYTHON:-python3}

if ! "$TEST_PYTHON" -c 'import pytest' >/dev/null 2>&1; then
  echo "pytest is not available in TEST_PYTHON=$TEST_PYTHON" >&2
  echo "Install pytest==9.1.1 and pytest-json-ctrf==0.5.2 in an isolated environment." >&2
  exit 2
fi

correct_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-build-reference.XXXXXX")
trap 'rm -rf "$correct_env"' EXIT
# When this helper is run as root, candidate executions intentionally drop to
# nobody just as they do in the separate verifier. Keep the transferred /app
# analogue traversable while leaving its contents controlled by the helper.
chmod 755 "$correct_env"
cp -R "$TASK_DIR/environment/." "$correct_env/"
BUILD_SYS_ROOT="$correct_env/buildsys" "$TASK_DIR/solution/solve.sh"
TB3_AGENT_APP_ROOT="$correct_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests"
