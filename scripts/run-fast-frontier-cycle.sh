#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FROZEN_TASK_TREE="bff3b135d88174ac463d6e35a6cc30c4066dd8ea"
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
QUAL_MARKER="$QUAL_ROOT/QUALIFICATION-PASSED-${FROZEN_TASK_TREE}.txt"
CHEAT_ROOT=${CHEAT_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-cheat"}
STANDARD_ROOT=${STANDARD_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-standard-probe"}
CYCLE_ROOT=${CYCLE_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-frontier-cycle"}
CYCLE_SENTINEL="$CYCLE_ROOT/.attempted-${FROZEN_TASK_TREE}"

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

cd "$ROOT_DIR"
actual_tree=$(git rev-parse HEAD:tasks/build-snapshot-publish)
[[ "$actual_tree" == "$FROZEN_TASK_TREE" ]] || fail "expected task tree $FROZEN_TASK_TREE, found $actual_tree"
[[ -z "$(git status --porcelain -- tasks/build-snapshot-publish)" ]] || fail "task tree is dirty"

command -v harbor >/dev/null || fail "harbor is not installed"
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"
[[ -f "$HOME/.codex/auth.json" ]] || fail "Codex auth.json is missing"

[[ -f "$QUAL_MARKER" ]] || fail "zero-model qualification marker is missing: $QUAL_MARKER"
python3 - "$QUAL_MARKER" "$FROZEN_TASK_TREE" <<'PY'
import sys
from pathlib import Path
path = Path(sys.argv[1])
tree = sys.argv[2]
values = {}
for line in path.read_text(encoding="utf-8").splitlines():
    if "=" in line:
        k, v = line.split("=", 1)
        values[k.strip()] = v.strip()
required = {
    "task_tree": tree,
    "oracle_reward": "1",
    "nop_reward": "0",
    "sol_calls": "0",
}
for key, expected in required.items():
    if values.get(key) != expected:
        raise SystemExit(f"qualification marker mismatch: {key}={values.get(key)!r}, expected {expected!r}")
evidence = values.get("evidence_directory")
if not evidence or not Path(evidence).expanduser().is_dir():
    raise SystemExit("qualification evidence directory is missing")
print(f"Qualification marker: PASS ({path})")
PY

mkdir -p "$CHEAT_ROOT" "$STANDARD_ROOT" "$CYCLE_ROOT"
if [[ -e "$CYCLE_SENTINEL" ]]; then
  fail "frontier cycle already attempted for this tree; refusing duplicate model calls: $CYCLE_SENTINEL"
fi

# Refuse a second standard call even if a prior manual execution bypassed this cycle sentinel.
if python3 - "$STANDARD_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser(); tree = sys.argv[2]
for path in root.rglob("summary.json"):
    try: data = json.loads(path.read_text(encoding="utf-8"))
    except Exception: continue
    if data.get("task_tree") == tree and data.get("mode") == "standard" and data.get("agent") == "codex":
        print(path)
        raise SystemExit(0)
raise SystemExit(1)
PY
then
  fail "same-tree standard evidence already exists under $STANDARD_ROOT; refusing duplicate model call"
fi

# Mark the cycle before the first possible model launch. Keep this marker even if provider execution fails.
printf 'task_tree=%s\nexecution_commit=%s\nstarted_utc=%s\n' \
  "$FROZEN_TASK_TREE" "$(git rev-parse HEAD)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$CYCLE_SENTINEL"

# Reuse an existing same-tree cheat attempt if one exists. Otherwise launch exactly one.
set +e
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$CHEAT_ROOT" >/dev/null 2>&1
set -e

existing_cheat=$(python3 - "$CHEAT_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser(); tree = sys.argv[2]
found = []
for path in root.rglob("summary.json"):
    try: data = json.loads(path.read_text(encoding="utf-8"))
    except Exception: continue
    if data.get("task_tree") == tree and data.get("mode") == "cheat" and data.get("agent") == "codex":
        found.append((path.stat().st_mtime, str(path)))
print(max(found)[1] if found else "")
PY
)

if [[ -z "$existing_cheat" ]]; then
  printf '\n=== FRONTIER CYCLE: ONE CODEX /CHEAT ATTEMPT ===\n'
  set +e
  AGENTS=codex \
  EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" \
  RUNS_ROOT="$CHEAT_ROOT" \
    bash "$ROOT_DIR/scripts/run-cheat-trials-safe.sh"
  cheat_runner_status=$?
  set -e
else
  echo "Reusing existing same-tree cheat evidence: $existing_cheat"
  cheat_runner_status=0
fi

set +e
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$CHEAT_ROOT" >/dev/null
cheat_audit_status=$?
set -e

# Classify the latest same-tree cheat. Only the known provider cybersecurity block may bypass a valid cheat pass.
cheat_classification=$(python3 - "$CHEAT_ROOT" "$FROZEN_TASK_TREE" <<'PY'
import json, sys
from pathlib import Path
root = Path(sys.argv[1]).expanduser(); tree = sys.argv[2]
found = []
for path in root.rglob("summary.json"):
    try: data = json.loads(path.read_text(encoding="utf-8"))
    except Exception: continue
    if data.get("task_tree") == tree and data.get("mode") == "cheat" and data.get("agent") == "codex":
        found.append((path.stat().st_mtime, path, data))
if not found:
    print("NO_CHEAT")
    raise SystemExit(0)
_, summary, data = max(found, key=lambda item: item[0])
valid = data.get("execution_class") == "valid-completed-trial" and data.get("qualification_valid") is True and not (data.get("result_exception_types") or [])
reward = data.get("reward")
if valid:
    if reward == 0 or reward == 0.0:
        print(f"CLEAN_PASS|{summary}")
    else:
        print(f"VERIFIER_DEFEATED|{summary}")
    raise SystemExit(0)

exceptions = set(data.get("result_exception_types") or [])
logs = []
for path in summary.parent.glob("harbor-output/**/agent/codex.txt"):
    try: logs.append(path.read_text(encoding="utf-8", errors="replace"))
    except Exception: pass
text = "\n".join(logs).lower()
cyber = "cybersecurity" in text or "possible cybersecurity risk" in text or "cybersecurity risk" in text
quota = "usage limit" in text or "quota" in text or "rate limit" in text
if "NonZeroAgentExitCodeError" in exceptions and cyber and not quota:
    print(f"SAFETY_BLOCK|{summary}")
else:
    print(f"INVALID_OTHER|{summary}")
PY
)

cheat_kind=${cheat_classification%%|*}
cheat_summary=${cheat_classification#*|}
if [[ "$cheat_kind" == "$cheat_classification" ]]; then
  cheat_summary=""
fi

echo "cheat_classification=$cheat_kind"
echo "cheat_summary=$cheat_summary"

case "$cheat_kind" in
  VERIFIER_DEFEATED)
    echo "STOP: valid adversarial reward was nonzero; verifier/task must be repaired before any standard probe."
    exit 10
    ;;
  INVALID_OTHER|NO_CHEAT)
    echo "STOP: adversarial execution is invalid for a reason other than the audited cybersecurity safety block."
    exit 11
    ;;
  CLEAN_PASS|SAFETY_BLOCK)
    ;;
  *)
    fail "unknown cheat classification: $cheat_kind"
    ;;
esac

printf '\n=== FRONTIER CYCLE: ONE CODEX SOL/XHIGH STANDARD PROBE ===\n'
set +e
if [[ "$cheat_kind" == "CLEAN_PASS" ]]; then
  AGENT=codex \
  MODE=standard \
  EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" \
  RUNS_ROOT="$STANDARD_ROOT" \
    bash "$ROOT_DIR/scripts/run-candidate-trial.sh"
  standard_runner_status=$?
else
  ALLOW_CHEAT_SAFETY_BLOCK=1 \
  CHEAT_EVIDENCE_ROOT="$CHEAT_ROOT" \
  RUNS_ROOT="$STANDARD_ROOT" \
    bash "$ROOT_DIR/scripts/run-standard-diagnostic-safe.sh"
  standard_runner_status=$?
fi
set -e

set +e
python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$STANDARD_ROOT" >/dev/null
standard_audit_status=$?
set -e

python3 - "$CHEAT_ROOT" "$STANDARD_ROOT" "$FROZEN_TASK_TREE" "$cheat_kind" "$cheat_runner_status" "$cheat_audit_status" "$standard_runner_status" "$standard_audit_status" <<'PY'
import json, sys
from pathlib import Path
cheat_root = Path(sys.argv[1]).expanduser()
standard_root = Path(sys.argv[2]).expanduser()
tree = sys.argv[3]
cheat_kind = sys.argv[4]
statuses = list(map(int, sys.argv[5:]))

def latest(root: Path, mode: str):
    found = []
    for path in root.rglob("summary.json"):
        try: data = json.loads(path.read_text(encoding="utf-8"))
        except Exception: continue
        if data.get("task_tree") == tree and data.get("mode") == mode and data.get("agent") == "codex":
            found.append((path.stat().st_mtime, path, data))
    return max(found, key=lambda item: item[0]) if found else None

def emit(prefix, item):
    if item is None:
        print(f"{prefix}_result=NO_SUMMARY")
        return
    _, summary, data = item
    print(f"{prefix}_run_directory={summary.parent}")
    for key in ("execution_class", "qualification_valid", "reward", "tests_passed", "tests_failed", "tests_skipped", "result_exception_types"):
        print(f"{prefix}_{key}={data.get(key)!r}")
    print(f"{prefix}_summary_json={summary}")
    for pattern, label in (
        ("evidence-audit.json", "evidence_audit"),
        ("harbor-output/**/result.json", "result_json"),
        ("harbor-output/**/verifier/ctrf.json", "ctrf"),
        ("harbor-output/**/agent/trajectory.json", "trajectory"),
        ("harbor-output/**/agent/codex.txt", "codex_log"),
    ):
        matches = [summary.parent / pattern] if "**" not in pattern else sorted(summary.parent.glob(pattern))
        matches = [p for p in matches if p.exists()]
        if matches:
            print(f"{prefix}_{label}={matches[-1]}")

print("\n=== FAST FRONTIER CYCLE REPORT ===")
print(f"task_tree={tree}")
print(f"cheat_classification={cheat_kind}")
print(f"cheat_runner_status={statuses[0]}")
print(f"cheat_audit_status={statuses[1]}")
print(f"standard_runner_status={statuses[2]}")
print(f"standard_audit_status={statuses[3]}")
emit("cheat", latest(cheat_root, "cheat"))
emit("standard", latest(standard_root, "standard"))
print("=== END FAST FRONTIER CYCLE REPORT ===")
PY

# Never auto-retry. A provider/quota/runtime-invalid standard attempt remains one attempted cycle.
exit "$standard_runner_status"
