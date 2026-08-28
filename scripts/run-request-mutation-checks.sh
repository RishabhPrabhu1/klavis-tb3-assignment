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
  local old=$2
  local new=$3
  local mutant_env
  mutant_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-request-mutant-${name}.XXXXXX")
  chmod 755 "$mutant_env"
  cp -R "$TASK_DIR/environment/." "$mutant_env/"
  BUILD_SYS_ROOT="$mutant_env/buildsys" "$TASK_DIR/solution/solve.sh"

  python3 - "$mutant_env/buildsys/request_protocol.py" "$old" "$new" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
old, new = sys.argv[2], sys.argv[3]
source = path.read_text()
if source.count(old) != 1:
    raise SystemExit(f"mutation pattern count was {source.count(old)}, expected 1: {old!r}")
path.write_text(source.replace(old, new))
PY

  set +e
  TB3_AGENT_APP_ROOT="$mutant_env" "$TEST_PYTHON" -m pytest -q \
    "$TASK_DIR/tests/test_exactly_once_requests.py"
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    echo "FAIL: request mutation $name was accepted"
    rm -rf "$mutant_env"
    return 1
  fi
  if [[ $status -ne 1 ]]; then
    echo "FAIL: request mutation $name produced pytest infrastructure/collection status $status"
    rm -rf "$mutant_env"
    return 1
  fi
  echo "PASS: request mutation $name rejected"
  rm -rf "$mutant_env"
}

run_mutation \
  replay-recommits \
  $'            if record is not None:\n                return _record_result(record, target)' \
  $'            if False and record is not None:\n                return _record_result(record, target)'

run_mutation \
  allow-cross-target-replay \
  $'    if record["target"] != target:\n        raise BuildError("request id is already committed for a different target")' \
  $'    if False:\n        raise BuildError("request id is already committed for a different target")'

run_mutation \
  global-request-claim \
  $'    return cache / "requests" / "claims" / f"{_request_key(request_id)}.lock"' \
  $'    return cache / "requests" / "claims" / "GLOBAL.lock"'

run_mutation \
  post-publish-is-precommit \
  $'        _failpoint("request:after-publish")' \
  $'        _failpoint("request:after-claim")'

run_mutation \
  invocation-start-only-recovery \
  $'    def merge_with_request_recovery(self: Builder) -> None:\n        # Builder invokes this while holding COMMIT.lock. Before a publication\n        # can move the old current generation into history, materialize any\n        # committed request result that was stranded by a post-publish crash.\n        _reconcile_current_unlocked(self.cache)\n        original_merge(self)' \
  $'    def merge_with_request_recovery(self: Builder) -> None:\n        original_merge(self)'
