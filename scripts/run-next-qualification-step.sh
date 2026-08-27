#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FROZEN_TASK_TREE="bff3b135d88174ac463d6e35a6cc30c4066dd8ea"
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}

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

printf '\n=== LOCAL DETERMINISTIC QUALIFICATION ===\n'
TB3_REPO="$TB3_REPO" \
EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" \
  bash "$ROOT_DIR/scripts/run-corrected-tree-local-qualification.sh"

printf '\n=== HARBOR ZERO-SOL PREFLIGHT ===\n'
mkdir -p "$RUNS_ROOT"
EXPECTED_TASK_TREE="$FROZEN_TASK_TREE" \
PREFLIGHT_ONLY=1 \
RUNS_ROOT="$RUNS_ROOT" \
  bash "$ROOT_DIR/scripts/run-codex-strong-test.sh"

latest=$(find "$RUNS_ROOT" -mindepth 1 -maxdepth 1 -type d -print | sort | tail -n 1)
[[ -n "$latest" ]] || fail "no Harbor preflight evidence directory found"
[[ -f "$latest/PREFLIGHT-PASSED.txt" ]] || fail "Harbor preflight did not produce PREFLIGHT-PASSED.txt"

python3 - "$latest/PREFLIGHT-PASSED.txt" <<'PY'
import sys
from pathlib import Path
path = Path(sys.argv[1])
values = {}
for line in path.read_text(encoding="utf-8").splitlines():
    if "=" in line:
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
required = {"oracle_reward": "1", "nop_reward": "0", "sol_calls": "0"}
for key, expected in required.items():
    actual = values.get(key)
    if actual != expected:
        raise SystemExit(f"preflight value mismatch: {key}={actual!r}, expected {expected!r}")
print("Harbor zero-Sol evidence: PASS")
PY

printf '\n=== QUALIFICATION STEP REPORT ===\n'
printf 'execution_commit=%s\n' "$(git rev-parse HEAD)"
printf 'task_tree=%s\n' "$FROZEN_TASK_TREE"
printf 'terminal_bench_head=%s\n' "$(git -C "$TB3_REPO" rev-parse HEAD 2>/dev/null || echo unknown)"
printf 'local_qualification=PASS\n'
printf 'expected_oracle_tests=66\n'
printf 'expected_mutations_core=14\n'
printf 'expected_mutations_lifecycle=6\n'
printf 'expected_mutations_request=5\n'
printf 'expected_mutations_workspace_snapshot=7\n'
printf 'expected_mutations_workspace_transaction=8\n'
printf 'expected_mutations_total=40\n'
printf 'harbor_oracle=1\n'
printf 'harbor_nop=0\n'
printf 'sol_calls=0\n'
printf 'evidence_directory=%s\n' "$latest"
printf '=== END QUALIFICATION STEP REPORT ===\n'
