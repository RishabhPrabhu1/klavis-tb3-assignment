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

# Keep the normative instruction outcome-oriented. The verifier observes the
# required serialization/progress properties, not a particular lock API or file.
python3 - "$TASK_DIR/instruction.md" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text(encoding="utf-8")
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

# The live static checks require README.md and these four headings, while the
# implementation rubric rejects a README that duplicates instruction/solution/
# metadata. Keep only reviewer-facing design/maintenance context here.
cat > "$TASK_DIR/README.md" <<'EOF'
# Build Snapshot Publication — reviewer notes

The normative agent contract is `instruction.md`. High-level difficulty,
solution, and verification summaries are in `task.toml`. This README records
only development context useful to reviewers and future maintainers.

## Difficulty explanation

The task was intentionally calibrated around composition of familiar systems
mechanisms rather than hidden representation requirements. Deterministic
pause/fail hooks expose concurrency and crash boundaries without relying on
wall-clock races. Internal selector, journal, lock-file, lease, and staging
layouts are deliberately non-normative; reviewers should treat any test that
accidentally depends on one such representation as a verifier defect.

## Solution explanation

The reference implementation is one witness, not a prescribed architecture.
In particular, its concrete filesystem names and helper decomposition are not
part of the contract. The important maintenance rule is to preserve observable
atomicity, retry/replay, progress, pinning, and bounded-reclamation semantics
while allowing alternative correct implementations.

## Verification explanation

The verifier runs separately from the agent image and checks behavior through
process execution and committed artifacts. Development mutation suites are
negative controls for coverage and are not part of reward computation. Current
selection is resolved from documented generation metadata rather than a
candidate-specific selector pathname; transaction-private project history is
identified by the documented `workspace_transaction` metadata bit.

## Relevant experience

This task grew from software/cloud infrastructure work plus targeted study of
incremental builds, crash consistency, idempotency, optimistic concurrency,
snapshot publication, and safe reclamation. The design was iterated by fixing
specification/verifier defects when found rather than counting them as model
failures. No production build-system ownership is claimed.
EOF

# Align metadata with the live rubric's best-case expert estimate and its
# difficulty-explanation requirements for real-world role + fixture provenance.
python3 - "$TASK_DIR/task.toml" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text(encoding="utf-8")
old_est="expert_time_estimate_hours = 6.0"
new_est="expert_time_estimate_hours = 3.5"
if s.count(old_est)!=1:
    raise SystemExit(f"expert estimate anchor count={s.count(old_est)}, expected 1")
s=s.replace(old_est,new_est,1)

prefix='difficulty_explanation = "'
line=next((line for line in s.splitlines() if line.startswith(prefix)),None)
if line is None:
    raise SystemExit("difficulty_explanation line missing")
if "build/release infrastructure engineers" not in line:
    assert line.endswith('"')
    expanded=line[:-1] + (
        " This is the kind of work build/release infrastructure engineers or storage-systems engineers "
        "perform when hardening concurrent build orchestration and publication. The accompanying project "
        "and manifest inputs are synthetic, deliberately small fixtures that preserve realistic dependency "
        "and source-change relationships while keeping deterministic concurrency verification fast.\""
    )
    s=s.replace(line,expanded,1)
p.write_text(s,encoding="utf-8")
PY

echo "RUBRIC CLEANUP APPLIED TO WORKING TREE ONLY"
echo "base_task_tree=$EXPECTED_TREE"
echo "changes:"
git -C "$ROOT_DIR" status --short -- tasks/build-snapshot-publish
echo
echo "Review before committing:"
echo "  git diff -- tasks/build-snapshot-publish/instruction.md tasks/build-snapshot-publish/README.md tasks/build-snapshot-publish/task.toml"
echo "Do not run frontier trials until the cleaned task is committed, its new task tree is recorded, and full qualification is rerun."
