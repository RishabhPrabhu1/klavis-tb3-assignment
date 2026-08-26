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
    retain-unreached-outputs)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '        (self.stage / "records").mkdir()\n'
new = old + '''        if self.current is not None:\n            current_out = self.current / "out"\n            if current_out.is_dir():\n                shutil.copytree(current_out, self.stage / "out", dirs_exist_ok=True)\n'''
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
    aborted-cache-reusable)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old_read = '''    def _read_record(self, name: str) -> dict[str, Any] | None:\n        if self.current is None:\n            return None\n        try:\n            record = json.loads(self._record_path(self.current, name).read_text())\n        except (OSError, ValueError):\n            return None\n        return record if isinstance(record, dict) and isinstance(record.get("dependencies"), list) else None\n'''
new_read = '''    def _read_record(self, name: str) -> dict[str, Any] | None:\n        persistent = self._record_path(self.cache, name)\n        if persistent.is_file():\n            source_path = persistent\n        elif self.current is not None:\n            source_path = self._record_path(self.current, name)\n        else:\n            return None\n        try:\n            record = json.loads(source_path.read_text())\n        except (OSError, ValueError):\n            return None\n        return record if isinstance(record, dict) and isinstance(record.get("dependencies"), list) else None\n'''
old_write = '        _atomic_write(self._record_path(self.stage, name), _json_bytes(record) + b"\\n")\n'
new_write = old_write + '        _atomic_write(self._record_path(self.cache, name), _json_bytes(record) + b"\\n")\n'
assert source.count(old_read) == 1
assert source.count(old_write) == 1
source = source.replace(old_read, new_read).replace(old_write, new_write)
path.write_text(source)
PY
      ;;
    stale-base-commit)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old_stage = '        (self.stage / "records").mkdir()\n'
new_stage = old_stage + '''        if self.current is not None:\n            current_records = self.current / "records"\n            if current_records.is_dir():\n                shutil.copytree(current_records, self.stage / "records", dirs_exist_ok=True)\n'''
old_merge = '                        self._merge_latest_records()\n'
new_merge = '                        pass  # stale-base mutant intentionally skips commit-time merge\n'
assert source.count(old_stage) == 1
assert source.count(old_merge) == 1
source = source.replace(old_stage, new_stage).replace(old_merge, new_merge)
path.write_text(source)
PY
      ;;
    no-input-revalidation)
      python3 - "$mutant_env/buildsys/engine.py" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
source = path.read_text()
old = '                    if not self._inputs_unchanged():\n'
new = '                    if False:\n'
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

  set +e
  TB3_AGENT_APP_ROOT="$mutant_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests"
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    echo "FAIL: mutation $name was accepted"
    rm -rf "$mutant_env"
    return 1
  fi
  if [[ $status -ne 1 ]]; then
    echo "FAIL: mutation $name produced pytest infrastructure/collection status $status"
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
run_mutation retain-unreached-outputs retain-unreached-outputs
run_mutation publish-in-place publish-in-place
run_mutation no-selector no-selector
run_mutation aborted-cache-reusable aborted-cache-reusable
run_mutation stale-base-commit stale-base-commit
run_mutation no-input-revalidation no-input-revalidation
run_mutation failpoint-only-staging failpoint-only-staging
