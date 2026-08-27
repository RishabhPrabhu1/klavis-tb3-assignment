#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
EXPECTED_TREE="5620526fada6eebea16910fc62bf71746aaa40ea"

actual=$(git -C "$ROOT_DIR" rev-parse HEAD:tasks/build-snapshot-publish)
if [[ "$actual" != "$EXPECTED_TREE" ]]; then
  echo "ERROR: rubric cleanup is prepared only for task tree $EXPECTED_TREE; found $actual" >&2
  exit 2
fi
if [[ -n "$(git -C "$ROOT_DIR" status --porcelain -- tasks/build-snapshot-publish)" ]]; then
  echo "ERROR: task tree is dirty" >&2
  exit 2
fi

python3 - "$TASK_DIR/instruction.md" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text(encoding="utf-8")
old_intro="Fix the incremental build tool in `/app/buildsys/`. Keep these interfaces working:"
new_intro=(
    "You are a build/release infrastructure engineer repairing the transactional snapshot layer "
    "used by a concurrent incremental build service.\n\n"
    "Fix the incremental build tool in `/app/buildsys/`. Keep these interfaces working:"
)
if s.count(old_intro)!=1:
    raise SystemExit(f"intro anchor count={s.count(old_intro)}, expected 1")
s=s.replace(old_intro,new_intro,1)
old=(
    "At commit, acquire the workspace publication lock and all written-project publication locks in "
    "deterministic canonical order. Before publishing, validate all of the following:"
)
new=(
    "The commit step must serialize the workspace publication edge with publication state for every "
    "written project, without holding that coordination during private evaluation. Before publishing, "
    "validate all of the following:"
)
if s.count(old)!=1:
    raise SystemExit(f"commit wording anchor count={s.count(old)}, expected 1")
s=s.replace(old,new,1)
p.write_text(s,encoding="utf-8")
PY

# The task-local README is optional under the live rubric and currently duplicates
# instruction/solution/task.toml. Removing it makes the task_readme criterion N/A.
rm -f "$TASK_DIR/README.md"

new_tree=$(git -C "$ROOT_DIR" write-tree 2>/dev/null || true)
actual_task=$(git -C "$ROOT_DIR" diff --quiet -- tasks/build-snapshot-publish && git -C "$ROOT_DIR" rev-parse HEAD:tasks/build-snapshot-publish || echo modified)

echo "RUBRIC CLEANUP APPLIED TO WORKING TREE ONLY"
echo "base_task_tree=$EXPECTED_TREE"
echo "task_state=$actual_task"
echo "changes:"
git -C "$ROOT_DIR" status --short -- tasks/build-snapshot-publish
echo
echo "Review diff before committing:"
echo "  git diff -- tasks/build-snapshot-publish/instruction.md tasks/build-snapshot-publish/README.md"
echo "Do not run frontier trials until the cleaned task is committed, its new task tree is recorded, and full qualification is rerun."
