#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
TEST_PYTHON=${TEST_PYTHON:-python3}

if ! "$TEST_PYTHON" -c 'import pytest' >/dev/null 2>&1; then
  echo "pytest is not available in TEST_PYTHON=$TEST_PYTHON" >&2
  exit 2
fi

run_mutation() {
  local name=$1
  local mode=$2
  local mutant_env
  mutant_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-snapshot-mutant-${name}.XXXXXX")
  cp -R "$TASK_DIR/environment/." "$mutant_env/"

  if [[ "$mode" != "starter" ]]; then
    BUILD_SYS_ROOT="$mutant_env/buildsys" "$TASK_DIR/solution/solve.sh"
  fi

  case "$mode" in
    always-rebuild)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = "            if self._cache_is_valid(record, key):\n"
new = "            if False:\n"
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
    ignore-upstream)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '"upstream": upstream'
new = '"upstream": {}'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
    ignore-definition)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '"definition": definition'
new = '"definition": {}'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
    trust-object)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '            return _digest(self._read_object(object_key)) == expected\n'
new = '            return True\n'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
    publish-in-place)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '        _atomic_write(self.stage / output, data)\n'
new = '        _atomic_write(self.project / output, data)\n'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
    no-selector)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '        os.replace(temporary, self.selector)\n'
new = '            os.replace(temporary, self.cache / "IGNORED_SELECTOR")\n'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
  esac

  if TB3_AGENT_APP_ROOT="$mutant_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests/test_build_cache.py"; then
    echo "FAIL: mutation $name was accepted"
    return 1
  fi
  echo "PASS: mutation $name rejected"
}

run_mutation starter starter
run_mutation always-rebuild always-rebuild
run_mutation ignore-upstream ignore-upstream
run_mutation ignore-definition ignore-definition
run_mutation trust-object trust-object
run_mutation publish-in-place publish-in-place
run_mutation no-selector no-selector
