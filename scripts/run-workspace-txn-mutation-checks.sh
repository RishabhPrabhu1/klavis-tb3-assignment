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
  mutant_env=$(mktemp -d "${TMPDIR:-/tmp}/tb3-workspace-txn-mutant-${name}.XXXXXX")
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
    "$TASK_DIR/tests/test_workspace_transactions.py"
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    echo "FAIL: workspace transaction mutation $name was accepted"
    rm -rf "$mutant_env"
    return 1
  fi
  if [[ $status -ne 1 ]]; then
    echo "FAIL: workspace transaction mutation $name produced pytest infrastructure/collection status $status"
    rm -rf "$mutant_env"
    return 1
  fi
  echo "PASS: workspace transaction mutation $name rejected"
  rm -rf "$mutant_env"
}

run_mutation \
  txn-global-lock-during-stage \
  workspace_txn.py \
  $'                    prepared[name] = _prepare_member(project, spec["target"], attempt_root)\n                    _pausepoint(f"workspace-build:after-stage:{name}")' \
  $'                    with _workspace_lock(cache):\n                        prepared[name] = _prepare_member(project, spec["target"], attempt_root)\n                        _pausepoint(f"workspace-build:after-stage:{name}")'

run_mutation \
  txn-ignore-workspace-write-conflict \
  workspace_txn.py \
  $'                            if latest_token != base_write_tokens[name]:\n                                retry = True\n                                break' \
  $'                            if False:\n                                retry = True\n                                break'

run_mutation \
  txn-ignore-project-version \
  workspace_txn.py \
  $'                            if current_token != base_project_tokens[name]:\n                                retry = True\n                                break' \
  $'                            if False:\n                                retry = True\n                                break'

run_mutation \
  txn-ignore-source-revalidation \
  workspace_txn.py \
  $'                            if not _inputs_unchanged(project, prepared[name]):\n                                retry = True\n                                break' \
  $'                            if False:\n                                retry = True\n                                break'

run_mutation \
  txn-publish-stale-whole-workspace \
  workspace_txn.py \
  $'                        _latest_ws, latest_members = _workspace_members(cache)' \
  $'                        _latest_ws, latest_members = _workspace_members(cache)\n                        latest_members = json.loads(json.dumps(base_members))'

run_mutation \
  txn-postpublish-is-precommit \
  workspace_txn.py \
  $'                _failpoint("workspace-build:after-publish")' \
  $'                _failpoint("workspace-build:after-import")'

run_mutation \
  txn-publishes-project-current \
  workspace_txn.py \
  $'        os.replace(temporary, generation)\n        _fsync_dir(generations)' \
  $'        os.replace(temporary, generation)\n        selector_tmp = cache / f".TXN-CURRENT-{uuid.uuid4().hex}"\n        os.symlink(f"generations/{token}", selector_tmp)\n        os.replace(selector_tmp, cache / "CURRENT")\n        _fsync_dir(generations)'

run_mutation \
  txn-after-import-consumes-request \
  workspace_txn.py \
  $'                            _failpoint("workspace-build:after-import")' \
  $'                            _write_record(cache, request_id, digest, {"request_id": request_id, "snapshot": "not-committed", "attempts": attempt, "updated": updated, "members": latest_members})\n                            _failpoint("workspace-build:after-import")'
