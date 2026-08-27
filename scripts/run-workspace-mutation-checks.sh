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
  local relative_file=$2
  local old=$3
  local new=$4
  local mutant_env
  mutant_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-workspace-mutant-${name}.XXXXXX")
  chmod 755 "$mutant_env"
  cp -R "$TASK_DIR/environment/." "$mutant_env/"
  BUILD_SYS_ROOT="$mutant_env/buildsys" "$TASK_DIR/solution/solve.sh"

  python3 - "$mutant_env/buildsys/$relative_file" "$old" "$new" <<'PY'
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
    "$TASK_DIR/tests/test_workspace_snapshots.py" \
    "$TASK_DIR/tests/test_workspace_recovery_race.py"
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    echo "FAIL: workspace mutation $name was accepted"
    rm -rf "$mutant_env"
    return 1
  fi
  if [[ $status -ne 1 ]]; then
    echo "FAIL: workspace mutation $name produced pytest infrastructure/collection status $status"
    rm -rf "$mutant_env"
    return 1
  fi
  echo "PASS: workspace mutation $name rejected"
  rm -rf "$mutant_env"
}

run_mutation \
  workspace-replay-recaptures \
  workspace.py \
  $'            if record is not None:\n                return _record_result(record, digest)' \
  $'            if False and record is not None:\n                return _record_result(record, digest)'

run_mutation \
  workspace-allow-cross-plan-replay \
  workspace.py \
  $'    if record["plan_digest"] != plan_digest:\n        raise BuildError("workspace request id is already committed for a different plan")' \
  $'    if False:\n        raise BuildError("workspace request id is already committed for a different plan")'

run_mutation \
  workspace-global-request-claim \
  workspace.py \
  $'    return cache / "requests" / "claims" / f"{_request_key(request_id)}.lock"' \
  $'    return cache / "requests" / "claims" / "GLOBAL.lock"'

run_mutation \
  workspace-no-stable-cut-locks \
  workspace.py \
  $'                    stack.enter_context(_project_lock(project))' \
  $'                    pass'

run_mutation \
  workspace-postpublish-is-precommit \
  workspace.py \
  $'        _failpoint("workspace:after-publish")' \
  $'        _failpoint("workspace:after-claim")'

run_mutation \
  workspace-no-publication-reconcile \
  workspace.py \
  $'                    _reconcile_current_unlocked(cache)\n                    _swap_selector(cache, token)' \
  $'                    _swap_selector(cache, token)'

run_mutation \
  workspace-gc-ignore-reader-pins \
  workspace.py \
  $'            retained = {token for token in initial["pinned"] if token in generations}' \
  $'            retained = set()'

run_mutation \
  project-gc-ignore-workspace-references \
  lifecycle.py \
  $'                        for token in protected_project_generations_unlocked(root)' \
  $'                        for token in []'
