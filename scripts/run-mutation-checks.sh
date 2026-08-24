#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/hermetic-build-cache"
TEST_PYTHON=${TEST_PYTHON:-python3}

if ! "$TEST_PYTHON" -c 'import pytest' >/dev/null 2>&1; then
  echo "pytest is not available in TEST_PYTHON=$TEST_PYTHON" >&2
  exit 2
fi

run_mutation() {
  local name=$1
  local mode=$2
  local mutant_env
  mutant_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-build-mutant-${name}.XXXXXX")
  cp -R "$TASK_DIR/environment/." "$mutant_env/"

  if [[ "$mode" != "starter" ]]; then
    BUILD_SYS_ROOT="$mutant_env/buildsys" "$TASK_DIR/solution/solve.sh"
  fi

  if [[ "$mode" == "always-rebuild" ]]; then
    python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = "            if self._cache_is_valid(record, candidate_key):\n"
new = "            if False:\n"
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
  elif [[ "$mode" == "ignore-upstream" ]]; then
    python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '            "upstream": upstream,\n'
new = '            "upstream": {},\n'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
  fi

  if TB3_AGENT_APP_ROOT="$mutant_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests/test_build_cache.py"; then
    echo "FAIL: mutation $name was accepted"
    return 1
  fi
  echo "PASS: mutation $name rejected"
}

run_mutation starter starter
run_mutation always-rebuild always-rebuild
run_mutation ignore-upstream ignore-upstream
