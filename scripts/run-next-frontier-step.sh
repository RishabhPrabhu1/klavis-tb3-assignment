#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
TB3_HEAD_EXPECTED=${TB3_HEAD_EXPECTED:-79e71650f5b6a6ef5bb46a434c7c04d7d99a9480}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
RUBRIC_ROOT=${RUBRIC_ROOT:-"$HOME/.cache/klavis-tb3-runs/implementation-rubric"}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree qualification marker missing: $QUAL_MARKER"

python3 - "$QUAL_MARKER" "$TREE" "$TB3_HEAD_EXPECTED" <<'PY'
import sys
from pathlib import Path
path=Path(sys.argv[1]); tree=sys.argv[2]; tb3=sys.argv[3]
vals={}
for line in path.read_text(encoding='utf-8').splitlines():
    if '=' in line:
        k,v=line.split('=',1); vals[k.strip()]=v.strip()
required={
    'task_tree':tree,
    'terminal_bench_head':tb3,
    'static_checks':'PASS',
    'harbor_oracle':'1',
    'harbor_nop':'0',
    'sol_calls':'0',
}
wrong={k:(vals.get(k),v) for k,v in required.items() if vals.get(k)!=v}
try:
    oracle_tests=int(vals.get('oracle_tests','0'))
except ValueError:
    oracle_tests=0
if oracle_tests < 68:
    wrong['oracle_tests']=(vals.get('oracle_tests'),'>=68')
if wrong:
    raise SystemExit(f'qualification marker mismatch: {wrong}')
PY

RUBRIC_PASS=$(python3 - "$RUBRIC_ROOT" "$TREE" "$TB3_HEAD_EXPECTED" <<'PY'
import json,sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; tb3=sys.argv[3]; found=[]
if root.exists():
    for p in root.rglob('result.json'):
        try:d=json.loads(p.read_text(encoding='utf-8'))
        except Exception:continue
        if d.get('task_tree')==tree and d.get('terminal_bench_head')==tb3 and d.get('passed') is True and not (d.get('failed') or []):
            found.append((p.stat().st_mtime,p))
print(str(max(found)[1]) if found else '')
PY
)
[[ -n "$RUBRIC_PASS" ]] || fail "same-tree implementation-rubric PASS is missing; do not launch frontier models yet"

echo "qualification=PASS"
echo "implementation_rubric=PASS"
echo "implementation_rubric_result=$RUBRIC_PASS"
echo "task_tree=$TREE"

exec bash "$ROOT_DIR/scripts/run-one-qualified-sol-probe.sh"
