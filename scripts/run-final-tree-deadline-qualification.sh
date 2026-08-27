#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}
EXPECTED_TB3_HEAD=${EXPECTED_TB3_HEAD:-79e71650f5b6a6ef5bb46a434c7c04d7d99a9480}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/final-tree-preflight"}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
BASE_QUALIFIED_TREE=${BASE_QUALIFIED_TREE:-d7d7adf1384605832f5c8008fe5acafa6a5b1152}

fail() { echo "ERROR: $*" >&2; exit 2; }

cd "$ROOT_DIR"
TREE=$(git rev-parse "HEAD:$TASK_REL")
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-"$TREE"}
[[ "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ -z "$(git status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

[[ -d "$TB3_REPO/.git" ]] || fail "Terminal-Bench checkout missing at $TB3_REPO"
ACTUAL_TB3_HEAD=$(git -C "$TB3_REPO" rev-parse HEAD)
[[ "$ACTUAL_TB3_HEAD" == "$EXPECTED_TB3_HEAD" ]] || fail "expected Terminal-Bench $EXPECTED_TB3_HEAD, found $ACTUAL_TB3_HEAD"
command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

TEST_PYTHON=$(bash "$ROOT_DIR/scripts/setup-local-verifier-env.sh")
export TEST_PYTHON

printf '=== FINAL-TREE DEADLINE QUALIFICATION ===\n'
printf 'execution_commit=%s\n' "$(git rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'terminal_bench_head=%s\n' "$ACTUAL_TB3_HEAD"
printf 'test_python=%s\n' "$TEST_PYTHON"
printf 'unchanged_mutation_baseline_tree=%s\n' "$BASE_QUALIFIED_TREE"

printf '\n[1/5] Current TB3 static checks\n'
TB3_REPO="$TB3_REPO" bash "$ROOT_DIR/scripts/run-static-checks.sh"

printf '\n[2/5] Full exact-tree Oracle/reference verifier (66 tests expected)\n'
bash "$ROOT_DIR/scripts/run-local-reference-tests.sh"

printf '\n[3/5] Changed workspace-snapshot verifier mutation slice (7 mutants)\n'
# workspace_harness.py changed for verifier isolation, so rerun the workspace
# mutation family rather than inheriting those negative controls.
bash "$ROOT_DIR/scripts/run-workspace-mutation-checks.sh"

printf '\n[4/5] Changed workspace-transaction verifier mutation slice (8 mutants)\n'
# transaction harness/tests changed for representation-neutral replay and
# process isolation, so rerun all transaction mutants.
bash "$ROOT_DIR/scripts/run-workspace-txn-mutation-checks.sh"

printf '\n[5/5] Exact-tree Harbor 0.14 Docker Oracle/NOP; zero frontier calls\n'
mkdir -p "$RUNS_ROOT" "$QUAL_ROOT"
EXPECTED_TASK_TREE="$TREE" \
PREFLIGHT_ONLY=1 \
RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-codex-strong-test.sh"

LATEST=$(python3 - "$RUNS_ROOT" "$TREE" <<'PY'
import json, sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; found=[]
if root.exists():
    for marker in root.rglob('PREFLIGHT-PASSED.txt'):
        run=marker.parent
        meta=run/'metadata.json'
        try: d=json.loads(meta.read_text(encoding='utf-8'))
        except Exception: continue
        if d.get('task_tree')==tree:
            found.append((marker.stat().st_mtime, marker))
print(str(max(found)[1]) if found else '')
PY
)
[[ -n "$LATEST" ]] || fail "no exact-tree Harbor preflight marker found under $RUNS_ROOT"

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
print(f'Harbor exact-tree preflight verified: {p}')
PY

MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
cat > "$MARKER" <<EOF
execution_commit=$(git rev-parse HEAD)
task_tree=$TREE
terminal_bench_head=$ACTUAL_TB3_HEAD
qualification_mode=deadline-delta
static_checks=PASS
oracle_tests=66
changed_workspace_snapshot_mutants=7
changed_transaction_mutants=8
unchanged_mutation_baseline_tree=$BASE_QUALIFIED_TREE
harbor_oracle=1
harbor_nop=0
sol_calls=0
harbor_preflight_marker=$LATEST
evidence_directory=$(dirname "$LATEST")
EOF

printf '\n=== FINAL-TREE QUALIFICATION REPORT ===\n'
printf 'task_tree=%s\n' "$TREE"
printf 'static_checks=PASS\n'
printf 'oracle_reference=66/66\n'
printf 'changed_workspace_snapshot_mutants=7/7_rejected\n'
printf 'changed_transaction_mutants=8/8_rejected\n'
printf 'unchanged_mutation_families=core,lifecycle,project-request reused_from_%s\n' "$BASE_QUALIFIED_TREE"
printf 'harbor_oracle=1\n'
printf 'harbor_nop=0\n'
printf 'frontier_calls=0\n'
printf 'qualification_marker=%s\n' "$MARKER"
printf 'status=PASS\n'
printf '=== END FINAL-TREE QUALIFICATION REPORT ===\n'
