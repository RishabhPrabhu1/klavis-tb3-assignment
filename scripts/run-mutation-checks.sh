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
  # A root-run preflight drops candidate executions to nobody. Keep this /app
  # analogue traversable so the local harness matches the verifier container.
  chmod 755 "$mutant_env"
  cp -R "$TASK_DIR/environment/." "$mutant_env/"

  case "$mode" in
    starter|failpoint-only-staging)
      ;;
    *)
      BUILD_SYS_ROOT="$mutant_env/buildsys" "$TASK_DIR/solution/solve.sh"
      ;;
  esac

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
new = '        os.replace(temporary, self.cache / "IGNORED_SELECTOR")\n'
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
    failpoint-only-staging)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '''    def _materialize(self, relative: str, data: bytes) -> None:\n        _atomic_write(self.project / _safe_relative(relative), data)\n'''
new = '''    def _materialize(self, relative: str, data: bytes) -> None:\n        if os.environ.get("BUILDSYS_FAILPOINT"):\n            destination = self.project / ".failpoint-stage" / _safe_relative(relative)\n        else:\n            destination = self.project / _safe_relative(relative)\n        _atomic_write(destination, data)\n'''
assert source.count(old) == 1
path.write_text(source.replace(old, new))
PY
      ;;
  esac

  if TB3_AGENT_APP_ROOT="$mutant_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests"; then
    echo "FAIL: mutation $name was accepted"
    rm -rf "$mutant_env"
    return 1
  fi
  echo "PASS: mutation $name rejected"
  rm -rf "$mutant_env"
}

run_mutation starter starter
run_mutation always-rebuild always-rebuild
run_mutation ignore-upstream ignore-upstream
run_mutation ignore-definition ignore-definition
run_mutation trust-object trust-object
run_mutation publish-in-place publish-in-place
run_mutation no-selector no-selector
run_mutation failpoint-only-staging failpoint-only-staging
