#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TASK_DIR="$ROOT_DIR/$TASK_REL"
EXPECTED_SHA=${EXPECTED_SHA:-}
RUNS_ROOT=${RUNS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-sol-runs"}
PREFLIGHT_ONLY=${PREFLIGHT_ONLY:-0}

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

command -v git >/dev/null 2>&1 || fail "git is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"
command -v docker >/dev/null 2>&1 || fail "Docker is required"
command -v harbor >/dev/null 2>&1 || fail "Harbor is required; install Harbor 0.14.0"
command -v codex >/dev/null 2>&1 || fail "Codex CLI is required and must already be signed in"

REPO_SHA=$(git -C "$ROOT_DIR" rev-parse HEAD)
TASK_TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
SHORT_SHA=${REPO_SHA:0:12}

if [[ -n "$EXPECTED_SHA" && "$REPO_SHA" != "$EXPECTED_SHA" ]]; then
  fail "expected repository SHA $EXPECTED_SHA, found $REPO_SHA"
fi

if [[ -n "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]]; then
  fail "task tree is dirty; commit or discard task changes before a frontier measurement"
fi

HARBOR_VERSION=$(harbor --version 2>&1 || true)
[[ "$HARBOR_VERSION" == *"0.14.0"* ]] || fail "frontier trial must use Harbor 0.14.0; found: $HARBOR_VERSION"

docker info >/dev/null 2>&1 || fail "Docker daemon is not available"
[[ -f "$HOME/.codex/auth.json" ]] || fail "Codex subscription auth not found at ~/.codex/auth.json; run 'codex login' first"

CODEX_VERSION=$(codex --version 2>&1 || true)
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_DIR="$RUNS_ROOT/${STAMP}-${SHORT_SHA}"
TASK_COPY="$RUN_DIR/task"
HARBOR_OUTPUT="$RUN_DIR/harbor-output"
JOB_NAME="sol-xhigh-${SHORT_SHA}"
mkdir -p "$RUN_DIR" "$HARBOR_OUTPUT"
cp -R "$TASK_DIR" "$TASK_COPY"

python3 - "$RUN_DIR/metadata.json" "$REPO_SHA" "$TASK_TREE" "$HARBOR_VERSION" "$CODEX_VERSION" "$PREFLIGHT_ONLY" <<'PY'
import json
import sys
from pathlib import Path

path, repo_sha, task_tree, harbor_version, codex_version, preflight_only = sys.argv[1:]
Path(path).write_text(json.dumps({
    "repository_sha": repo_sha,
    "task_tree": task_tree,
    "agent": "codex",
    "model": "openai/gpt-5.6-sol",
    "reasoning_effort": "xhigh",
    "environment": "docker",
    "harbor_version": harbor_version,
    "codex_version": codex_version,
    "auth": "CODEX_FORCE_AUTH_JSON=1",
    "attempts_requested": 0 if preflight_only == "1" else 1,
    "harbor_analyze": False,
    "preflight_only": preflight_only == "1",
}, indent=2) + "\n", encoding="utf-8")
PY

if [[ "$PREFLIGHT_ONLY" == "1" ]]; then
  cat <<EOF
Zero-Sol frontier preflight

Repository SHA:  $REPO_SHA
Task tree:       $TASK_TREE
Harbor:          $HARBOR_VERSION
Codex:           $CODEX_VERSION
Output:          $RUN_DIR

This mode does NOT launch Codex or GPT-5.6 Sol.
It validates the exact Harbor 0.14.0 + Docker task path with Oracle and NOP only.
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
  printf '\nZero-Sol preflight passed. Evidence directory: %s\n' "$RUN_DIR"
  exit 0
fi

cat > "$RUN_DIR/command.txt" <<EOF
harbor run \\
  -p "$TASK_COPY" \\
  --agent codex \\
  --model openai/gpt-5.6-sol \\
  --env docker \\
  --yes \\
  --ae CODEX_FORCE_AUTH_JSON=1 \\
  --ak reasoning_effort=xhigh \\
  -o "$HARBOR_OUTPUT" \\
  --job-name "$JOB_NAME"
EOF

cat <<EOF
Usage-efficient Sol frontier diagnostic

Repository SHA:  $REPO_SHA
Task tree:       $TASK_TREE
Harbor:          $HARBOR_VERSION
Codex:           $CODEX_VERSION
Output:          $RUN_DIR

Only the Harbor child agent below uses GPT-5.6 Sol/xhigh.
There is no outer Codex session and this script never invokes harbor analyze.
Exactly one Harbor task/agent trial is requested.

For a no-Sol infrastructure check first, run this script with PREFLIGHT_ONLY=1.
EOF

set +e
harbor run \
  -p "$TASK_COPY" \
  --agent codex \
  --model openai/gpt-5.6-sol \
  --env docker \
  --yes \
  --ae CODEX_FORCE_AUTH_JSON=1 \
  --ak reasoning_effort=xhigh \
  -o "$HARBOR_OUTPUT" \
  --job-name "$JOB_NAME" \
  2>&1 | tee "$RUN_DIR/harbor-console.log"
HARBOR_STATUS=${PIPESTATUS[0]}
set -e

python3 - "$RUN_DIR" "$HARBOR_STATUS" <<'PY'
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

run_dir = Path(sys.argv[1])
harbor_status = int(sys.argv[2])
console = (run_dir / "harbor-console.log").read_text(encoding="utf-8", errors="replace")
metadata = json.loads((run_dir / "metadata.json").read_text())

means = re.findall(r"Mean[:\s]+([0-9]+(?:\.[0-9]+)?)", console)
reward = float(means[-1]) if means else None
exception_matches = re.findall(r"Exceptions[:\s]+([0-9]+)", console)
exceptions = int(exception_matches[-1]) if exception_matches else None

result_files = sorted((run_dir / "harbor-output").rglob("result.json"))
ctrf_files = sorted((run_dir / "harbor-output").rglob("ctrf.json"))
stdout_files = sorted((run_dir / "harbor-output").rglob("test-stdout.txt"))

passed = failed = skipped = None
failed_tests: list[str] = []
for path in ctrf_files:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        continue
    summary = data.get("results", {}).get("summary", {})
    if isinstance(summary, dict):
        passed = summary.get("passed", passed)
        failed = summary.get("failed", failed)
        skipped = summary.get("skipped", skipped)
    tests = data.get("results", {}).get("tests", [])
    if isinstance(tests, list):
        for test in tests:
            if not isinstance(test, dict):
                continue
            status = str(test.get("status", "")).lower()
            if status in {"failed", "fail"}:
                name = test.get("name") or test.get("suite") or "unknown"
                failed_tests.append(str(name))

if not failed_tests:
    for path in stdout_files:
        text = path.read_text(encoding="utf-8", errors="replace")
        for line in text.splitlines():
            if line.startswith("FAILED "):
                failed_tests.append(line[7:].split(" - ", 1)[0].strip())

if harbor_status != 0:
    execution = "infrastructure-or-run-error"
elif reward is None:
    execution = "completed-but-reward-unparsed"
elif exceptions not in (None, 0):
    execution = "completed-with-exceptions"
else:
    execution = "valid-completed-trial"

summary = {
    **metadata,
    "harbor_exit_status": harbor_status,
    "reward": reward,
    "exceptions": exceptions,
    "execution_class": execution,
    "tests": {"passed": passed, "failed": failed, "skipped": skipped},
    "failed_tests": failed_tests,
    "result_files": [str(p) for p in result_files],
    "ctrf_files": [str(p) for p in ctrf_files],
    "test_stdout_files": [str(p) for p in stdout_files],
}
(run_dir / "summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

lines = [
    "# GPT-5.6 Sol / xhigh Frontier Trial",
    "",
    f"- Repository SHA: `{metadata['repository_sha']}`",
    f"- Task tree: `{metadata['task_tree']}`",
    "- Agent/model: `codex` / `openai/gpt-5.6-sol`",
    "- Reasoning: `xhigh`",
    "- Environment: `docker`",
    f"- Harbor: `{metadata['harbor_version']}`",
    "- Attempts requested: `1`",
    "- `harbor analyze`: **not run**",
    f"- Harbor exit status: `{harbor_status}`",
    f"- Reward: `{reward if reward is not None else 'unparsed'}`",
    f"- Exceptions: `{exceptions if exceptions is not None else 'unparsed'}`",
    f"- Execution classification: **{execution}**",
]
if any(v is not None for v in (passed, failed, skipped)):
    lines += ["", "## Verifier summary", "", f"- Passed: `{passed}`", f"- Failed: `{failed}`", f"- Skipped: `{skipped}`"]
if failed_tests:
    lines += ["", "## Failed tests", ""] + [f"- `{name}`" for name in failed_tests]
lines += [
    "",
    "## Evidence",
    "",
    f"- Harbor console: `{run_dir / 'harbor-console.log'}`",
    f"- Raw Harbor output: `{run_dir / 'harbor-output'}`",
    f"- Machine-readable summary: `{run_dir / 'summary.json'}`",
    "",
    "No LLM-based post-run analysis was performed by this runner.",
]
(run_dir / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
print("\n".join(lines))
PY

printf '\nEvidence directory: %s\n' "$RUN_DIR"
exit "$HARBOR_STATUS"
