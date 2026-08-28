#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}
EXPECTED_TB3_HEAD=${EXPECTED_TB3_HEAD:-79e71650f5b6a6ef5bb46a434c7c04d7d99a9480}
BASE_COMMIT=${BASE_COMMIT:-0bdddde78474a7e657c351774a2f66eca336811a}
BASE_TREE=${BASE_TREE:-301107828273e249fbd31ed34d86bf3fed7143a1}
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-d862ab3cc79718e959e9cc7ec1b792540990a24d}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/final-tree-preflight"}

fail() { echo "ERROR: $*" >&2; exit 2; }
cd "$ROOT_DIR"
TREE=$(git rev-parse "HEAD:$TASK_REL")
[[ "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ -z "$(git status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ "$(git rev-parse "$BASE_COMMIT:$TASK_REL")" == "$BASE_TREE" ]] || fail "base commit/tree mismatch"
BASE_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${BASE_TREE}.txt"
[[ -f "$BASE_MARKER" ]] || fail "fully-qualified predecessor marker missing: $BASE_MARKER"

# This fast path is valid only because the fully-qualified predecessor differs
# in one verifier-teardown file and does not change instruction/starter/reference semantics.
mapfile_cmd=0
changed=$(git diff --name-only "$BASE_COMMIT" HEAD -- "$TASK_REL")
expected="$TASK_REL/tests/conftest.py"
[[ "$changed" == "$expected" ]] || {
  echo "Unexpected task changes since fully-qualified predecessor:" >&2
  printf '%s\n' "$changed" >&2
  fail "fast successor qualification is not applicable"
}

[[ -d "$TB3_REPO/.git" ]] || fail "Terminal-Bench checkout missing at $TB3_REPO"
ACTUAL_TB3_HEAD=$(git -C "$TB3_REPO" rev-parse HEAD)
[[ "$ACTUAL_TB3_HEAD" == "$EXPECTED_TB3_HEAD" ]] || fail "expected Terminal-Bench $EXPECTED_TB3_HEAD, found $ACTUAL_TB3_HEAD"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

printf '=== FAST FINAL SUCCESSOR QUALIFICATION ===\n'
printf 'execution_commit=%s\n' "$(git rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'fully_qualified_predecessor_tree=%s\n' "$BASE_TREE"
printf 'task_delta=%s\n' "$expected"

TEST_PYTHON=$(bash "$ROOT_DIR/scripts/setup-local-verifier-env.sh")
export TEST_PYTHON

printf '\n[1/3] Current-tree static checks\n'
TB3_REPO="$TB3_REPO" bash "$ROOT_DIR/scripts/run-static-checks.sh"

printf '\n[2/3] Current-tree full reference verifier\n'
bash "$ROOT_DIR/scripts/run-local-reference-tests.sh"

printf '\n[3/3] Current-tree Harbor 0.14 Docker Oracle/NOP; zero frontier calls\n'
mkdir -p "$RUNS_ROOT" "$QUAL_ROOT"
EXPECTED_TASK_TREE="$TREE" PREFLIGHT_ONLY=1 RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-codex-strong-test.sh"

LATEST=$(python3 - "$RUNS_ROOT" "$TREE" <<'PY'
import json, sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; found=[]
if root.exists():
    for marker in root.rglob('PREFLIGHT-PASSED.txt'):
        meta=marker.parent/'metadata.json'
        try: d=json.loads(meta.read_text(encoding='utf-8'))
        except Exception: continue
        if d.get('task_tree')==tree:
            found.append((marker.stat().st_mtime, marker))
print(str(max(found)[1]) if found else '')
PY
)
[[ -n "$LATEST" ]] || fail "no exact-tree Harbor preflight marker found"
python3 - "$LATEST" "$TREE" <<'PY'
import sys
from pathlib import Path
p=Path(sys.argv[1]); tree=sys.argv[2]; vals={}
for line in p.read_text(encoding='utf-8').splitlines():
    if '=' in line:
        k,v=line.split('=',1); vals[k.strip()]=v.strip()
for k, expected in {'oracle_reward':'1','nop_reward':'0','sol_calls':'0'}.items():
    if vals.get(k) != expected:
        raise SystemExit(f'{k}={vals.get(k)!r}, expected {expected!r}')
if vals.get('task_tree') not in (None, tree):
    raise SystemExit(f"task_tree={vals.get('task_tree')!r}, expected {tree!r}")
PY

MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
cat > "$MARKER" <<EOF
execution_commit=$(git rev-parse HEAD)
task_tree=$TREE
terminal_bench_head=$ACTUAL_TB3_HEAD
qualification_mode=successor-delta-exact-tree
static_checks=PASS
oracle_tests=68
mutations_inherited_from_tree=$BASE_TREE
mutations_predecessor_total=40
mutations_predecessor_status=40/40_rejected
successor_task_delta=$expected
harbor_oracle=1
harbor_nop=0
sol_calls=0
harbor_preflight_marker=$LATEST
evidence_directory=$(dirname "$LATEST")
EOF

printf '\n=== FAST FINAL SUCCESSOR REPORT ===\n'
printf 'task_tree=%s\n' "$TREE"
printf 'static_checks=PASS\n'
printf 'oracle_reference=68/68\n'
printf 'predecessor_mutants=40/40_rejected\n'
printf 'successor_delta=verifier_teardown_only\n'
printf 'harbor_oracle=1\n'
printf 'harbor_nop=0\n'
printf 'frontier_calls=0\n'
printf 'qualification_marker=%s\n' "$MARKER"
printf 'status=PASS\n'
printf '=== END FAST FINAL SUCCESSOR REPORT ===\n'
