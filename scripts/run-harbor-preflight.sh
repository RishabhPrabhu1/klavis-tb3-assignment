#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TASK_DIR="$ROOT_DIR/$TASK_REL"
EXPECTED_SHA=${EXPECTED_SHA:-}
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-}
RUNS_ROOT=${RUNS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-preflight-runs"}
PREFLIGHT_ONLY=${PREFLIGHT_ONLY:-0}

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

[[ "$PREFLIGHT_ONLY" == "1" ]] || fail "this helper is zero-frontier preflight only; use scripts/run-candidate-trial.sh for model trials"
command -v git >/dev/null 2>&1 || fail "git is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"
command -v docker >/dev/null 2>&1 || fail "Docker is required"
command -v harbor >/dev/null 2>&1 || fail "Harbor is required; install Harbor 0.14.0"

REPO_SHA=$(git -C "$ROOT_DIR" rev-parse HEAD)
TASK_TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
SHORT_SHA=${REPO_SHA:0:12}

if [[ -n "$EXPECTED_SHA" && "$REPO_SHA" != "$EXPECTED_SHA" ]]; then
  fail "expected repository SHA $EXPECTED_SHA, found $REPO_SHA"
fi
if [[ -n "$EXPECTED_TASK_TREE" && "$TASK_TREE" != "$EXPECTED_TASK_TREE" ]]; then
  fail "expected task tree $EXPECTED_TASK_TREE, found $TASK_TREE"
fi
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

HARBOR_VERSION=$(harbor --version 2>&1 || true)
[[ "$HARBOR_VERSION" == *"0.14.0"* ]] || fail "preflight must use Harbor 0.14.0; found: $HARBOR_VERSION"
docker info >/dev/null 2>&1 || fail "Docker daemon is not available"

STAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_DIR="$RUNS_ROOT/${STAMP}-${SHORT_SHA}"
TASK_COPY="$RUN_DIR/task"
mkdir -p "$RUN_DIR"
cp -R "$TASK_DIR" "$TASK_COPY"

python3 - "$RUN_DIR/metadata.json" "$REPO_SHA" "$TASK_TREE" "$HARBOR_VERSION" <<'PY'
import json
import sys
from pathlib import Path
path, repo_sha, task_tree, harbor_version = sys.argv[1:]
Path(path).write_text(json.dumps({
    "repository_sha": repo_sha,
    "task_tree": task_tree,
    "environment": "docker",
    "harbor_version": harbor_version,
    "preflight_only": True,
    "frontier_model_calls": 0,
}, indent=2) + "\n", encoding="utf-8")
PY

cat <<EOF
Zero-frontier Harbor preflight

Repository SHA:  $REPO_SHA
Task tree:       $TASK_TREE
Harbor:          $HARBOR_VERSION
Output:          $RUN_DIR

This helper launches Oracle and NOP only. It does not invoke frontier models or harbor analyze.
EOF

run_reference_agent() {
  local agent=$1
  local expected=$2
  local output="$RUN_DIR/harbor-$agent"
  local console="$RUN_DIR/$agent-console.log"
  mkdir -p "$output"
  set +e
  harbor run \
    -p "$TASK_COPY" \
    --agent "$agent" \
    --env docker \
    --yes \
    -o "$output" \
    --job-name "preflight-${agent}-${SHORT_SHA}" \
    2>&1 | tee "$console"
  local status=${PIPESTATUS[0]}
  set -e
  [[ $status -eq 0 ]] || fail "$agent preflight exited with status $status"

  local reward
  reward=$(python3 - "$console" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
values = re.findall(r"Mean[:\s]+([0-9]+(?:\.[0-9]+)?)", text)
if not values:
    raise SystemExit(2)
print(values[-1])
PY
  ) || fail "could not parse $agent reward"

  python3 - "$agent" "$reward" "$expected" <<'PY'
import sys
agent, raw, expected = sys.argv[1:]
reward = float(raw)
wanted = float(expected)
if reward != wanted:
    raise SystemExit(f"{agent} reward must be {wanted}, got {reward}")
print(f"{agent} reward: {reward:.3f}")
PY
}

run_reference_agent oracle 1
run_reference_agent nop 0

cat > "$RUN_DIR/PREFLIGHT-PASSED.txt" <<EOF
repository_sha=$REPO_SHA
task_tree=$TASK_TREE
harbor=$HARBOR_VERSION
oracle_reward=1
nop_reward=0
sol_calls=0
EOF

printf '\nZero-frontier preflight passed. Evidence directory: %s\n' "$RUN_DIR"
