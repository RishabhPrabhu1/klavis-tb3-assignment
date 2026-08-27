#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
EXPECTED_TREE="fc064cac2fb1241b68a98475dbc8ea04fbe579cc"
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
CHEAT_ROOT=${CHEAT_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat"}
STANDARD_ROOT=${STANDARD_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe"}
CYCLE_ROOT=${CYCLE_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-frontier-cycle"}
QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt"
CYCLE_SENTINEL="$CYCLE_ROOT/.attempted-${TREE}"

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$TREE" == "$EXPECTED_TREE" ]] || fail "expected task tree $EXPECTED_TREE, found $TREE"
[[ -f "$QUAL_MARKER" ]] || fail "same-tree qualification marker missing: $QUAL_MARKER"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

# macOS ships Bash 3.2, which predates the BASHPID special variable used by
# the deadline runners for collision-free evidence/job names. Supplying an
# ordinary exported BASHPID on shells where it is absent preserves the same
# uniqueness purpose without changing task or model configuration.
if [[ -z "${BASHPID-}" ]]; then
  export BASHPID="$$"
fi

# The interrupted 2026-08-27 run wrote the frontier-cycle sentinel before
# run-candidate-trial.sh reached Harbor. A BASHPID expansion then failed, so
# there is no same-tree cheat or standard attempt to protect. More generally,
# remove a sentinel only when there is provably no same-tree model evidence,
# complete or incomplete, under either frontier evidence root.
if [[ -e "$CYCLE_SENTINEL" ]]; then
  evidence_state=$(python3 - "$CHEAT_ROOT" "$STANDARD_ROOT" "$TREE" <<'PY'
import json, sys
from pathlib import Path
roots=[Path(sys.argv[1]).expanduser(), Path(sys.argv[2]).expanduser()]
tree=sys.argv[3]
found=[]
for root in roots:
    if not root.exists():
        continue
    for d in root.iterdir():
        if not d.is_dir():
            continue
        summary=d / "summary.json"
        meta=d / "metadata.json"
        if summary.exists():
            try: data=json.loads(summary.read_text(encoding="utf-8"))
            except Exception: continue
            if data.get("task_tree")==tree:
                found.append(str(summary))
        elif meta.exists():
            try: data=json.loads(meta.read_text(encoding="utf-8"))
            except Exception: continue
            if data.get("task_tree")==tree:
                found.append(str(meta))
print("\n".join(found))
PY
)
  if [[ -n "$evidence_state" ]]; then
    echo "Existing same-tree model evidence found; preserving frontier sentinel:"
    echo "$evidence_state"
  else
    echo "Removing safe pre-launch frontier sentinel left by Bash 3.2 runner failure: $CYCLE_SENTINEL"
    rm -f "$CYCLE_SENTINEL"
  fi
fi

printf '\n=== MACOS DEADLINE RESUME ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'qualification_marker=%s\n' "$QUAL_MARKER"
printf 'bash_version=%s\n' "$BASH_VERSION"
printf 'portable_pid=%s\n' "$BASHPID"

exec bash "$ROOT_DIR/scripts/resume-deadline-cycle.sh"
