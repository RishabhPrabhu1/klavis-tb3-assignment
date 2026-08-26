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
  mutant_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-lifecycle-mutant-${name}.XXXXXX")
  chmod 755 "$mutant_env"
  cp -R "$TASK_DIR/environment/." "$mutant_env/"
  BUILD_SYS_ROOT="$mutant_env/buildsys" "$TASK_DIR/solution/solve.sh"

  python3 - "$mutant_env/buildsys/lifecycle.py" "$old" "$new" <<'PY'
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
  TB3_AGENT_APP_ROOT="$mutant_env" "$TEST_PYTHON" -m pytest -q "$TASK_DIR/tests/test_reclamation.py"
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    echo "FAIL: lifecycle mutation $name was accepted"
    rm -rf "$mutant_env"
    return 1
  fi
  if [[ $status -ne 1 ]]; then
    echo "FAIL: lifecycle mutation $name produced pytest infrastructure/collection status $status"
    rm -rf "$mutant_env"
    return 1
  fi
  echo "PASS: lifecycle mutation $name rejected"
  rm -rf "$mutant_env"
}

run_mutation \
  commit-seq-constant \
  'snapshot["commit_seq"] = _next_commit_seq(self)' \
  'snapshot["commit_seq"] = 1'

run_mutation \
  gc-never-delete-generations \
  'for token in sorted(set(initial["generations"]) - retained):' \
  'for token in []:'

run_mutation \
  gc-ignore-reader-pins \
  'retained = {token for token in scan["pinned"] if token in generations}' \
  'retained = set()'

run_mutation \
  gc-trust-stale-scan \
  'if _fingerprint(initial) != _fingerprint(final):' \
  'if False:'

run_mutation \
  gc-sweep-active-writer \
  'if final["writers"] == 0:' \
  'if True:'

run_mutation \
  gc-never-sweep-objects \
  'for key in sorted(initial["objects"] - reachable):' \
  'for key in []:'
