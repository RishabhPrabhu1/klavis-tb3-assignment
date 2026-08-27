#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FROZEN_TASK_TREE="bff3b135d88174ac463d6e35a6cc30c4066dd8ea"
CHEAT_EVIDENCE_ROOT=${CHEAT_EVIDENCE_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe"}
SENTINEL="$RUNS_ROOT/.attempted-${FROZEN_TASK_TREE}"

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

cd "$ROOT_DIR"

actual_tree=$(git rev-parse HEAD:tasks/build-snapshot-publish)
[[ "$actual_tree" == "$FROZEN_TASK_TREE" ]] || fail "expected task tree $FROZEN_TASK_TREE, found $actual_tree"
[[ -z "$(git status --porcelain -- tasks/build-snapshot-publish)" ]] || fail "task tree is dirty"

python3 - "$ROOT_DIR/results/preflight-status.json" "$FROZEN_TASK_TREE" <<'PY'
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
tree = sys.argv[2]
data = json.loads(path.read_text(encoding="utf-8"))
if data.get("task_tree") != tree:
    raise SystemExit(f"preflight tree mismatch: {data.get('task_tree')} != {tree}")
if data.get("qualified") is not True or data.get("preflight") != "passed":
    raise SystemExit("current task tree is not deterministically qualified")
print("Qualification record: PASS")
PY

command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"
[[ -f "$HOME/.codex/auth.json" ]] || fail "Codex auth.json is missing"

mkdir -p "$CHEAT_EVIDENCE_ROOT" "$RUNS_ROOT"
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$CHEAT_EVIDENCE_ROOT" >/dev/null

python3 - "$CHEAT_EVIDENCE_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser()
tree = sys.argv[2]
valid = []
for path in root.rglob("summary.json"):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        continue
    exc = data.get("result_exception_types") or []
    if (
        data.get("task_tree") == tree
        and data.get("mode") == "cheat"
        and data.get("agent") == "codex"
        and data.get("model") == "openai/gpt-5.6-sol"
        and data.get("reasoning_effort") == "xhigh"
        and data.get("qualification_valid") is False
        and data.get("execution_class") != "valid-completed-trial"
        and "NonZeroAgentExitCodeError" in exc
    ):
        valid.append(path)
if not valid:
    raise SystemExit("no audited same-tree invalid Codex /cheat exception was found")
print(f"Cheat exception prerequisite: {sorted(valid)[-1]}")
PY

if [[ -e "$SENTINEL" ]]; then
  fail "this one-off frontier probe has already been attempted; refusing a duplicate model launch. Sentinel: $SENTINEL"
fi

if python3 - "$RUNS_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser()
tree = sys.argv[2]
for path in root.rglob("summary.json"):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        continue
    if data.get("task_tree") == tree and data.get("mode") == "standard" and data.get("agent") == "codex":
        print(path)
        raise SystemExit(0)
raise SystemExit(1)
PY
then
  fail "a same-tree standard run already exists under $RUNS_ROOT; refusing a duplicate model launch"
fi

printf 'tree=%s\nexecution_commit=%s\nstarted_utc=%s\n' \
  "$FROZEN_TASK_TREE" "$(git rev-parse HEAD)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$SENTINEL"

set +e
ALLOW_CHEAT_SAFETY_BLOCK=1 \
CHEAT_EVIDENCE_ROOT="$CHEAT_EVIDENCE_ROOT" \
RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-standard-diagnostic-safe.sh"
runner_status=$?
set -e

set +e
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUNS_ROOT"
audit_status=$?
set -e

python3 - "$RUNS_ROOT" "$FROZEN_TASK_TREE" "$runner_status" "$audit_status" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser()
tree = sys.argv[2]
runner_status = int(sys.argv[3])
audit_status = int(sys.argv[4])

candidates = []
for path in root.rglob("summary.json"):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        continue
    if data.get("task_tree") == tree and data.get("mode") == "standard" and data.get("agent") == "codex":
        candidates.append((path.stat().st_mtime, path, data))

print("\n=== FRONTIER STEP REPORT ===")
print(f"runner_status={runner_status}")
print(f"audit_status={audit_status}")
if not candidates:
    print("result=NO_SUMMARY_FOUND")
    print(f"evidence_root={root}")
    raise SystemExit(0)

_, summary_path, data = max(candidates, key=lambda item: item[0])
print(f"run_directory={summary_path.parent}")
for key in (
    "execution_commit",
    "task_tree",
    "mode",
    "agent",
    "model",
    "reasoning_effort",
    "execution_class",
    "qualification_valid",
    "reward",
    "tests_passed",
    "tests_failed",
    "tests_skipped",
):
    print(f"{key}={data.get(key)!r}")
print(f"result_exception_types={data.get('result_exception_types')!r}")
print(f"summary_json={summary_path}")
for name in ("evidence-audit.json", "summary.md", "metadata.json", "harbor-console.log"):
    path = summary_path.parent / name
    if path.exists():
        print(f"{name.replace('-', '_').replace('.', '_')}={path}")
for pattern, label in (
    ("harbor-output/**/result.json", "result_json"),
    ("harbor-output/**/verifier/ctrf.json", "ctrf_json"),
    ("harbor-output/**/agent/trajectory.json", "trajectory_json"),
    ("harbor-output/**/agent/codex.txt", "codex_log"),
):
    matches = sorted(summary_path.parent.glob(pattern))
    if matches:
        print(f"{label}={matches[-1]}")
print("=== END FRONTIER STEP REPORT ===")
PY

exit "$runner_status"
