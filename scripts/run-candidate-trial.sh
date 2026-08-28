#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TASK_DIR="$ROOT_DIR/$TASK_REL"

AGENT=${AGENT:-}
MODE=${MODE:-standard}
DRY_RUN=${DRY_RUN:-0}
EXPECTED_SHA=${EXPECTED_SHA:-}
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-}
EXPECTED_TB3_HEAD=${EXPECTED_TB3_HEAD:-}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs"}

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

[[ "$AGENT" == "codex" || "$AGENT" == "claude" ]] || fail "AGENT must be codex or claude"
[[ "$MODE" == "standard" || "$MODE" == "cheat" ]] || fail "MODE must be standard or cheat"
[[ "$DRY_RUN" == "0" || "$DRY_RUN" == "1" ]] || fail "DRY_RUN must be 0 or 1"

for command in git python3 docker harbor; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required"
done

REPO_SHA=$(git -C "$ROOT_DIR" rev-parse HEAD)
TASK_TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
SHORT_SHA=${REPO_SHA:0:12}
RUN_PID=${BASHPID:-$$}

if [[ -n "$EXPECTED_SHA" && "$REPO_SHA" != "$EXPECTED_SHA" ]]; then
  fail "expected repository SHA $EXPECTED_SHA, found $REPO_SHA"
fi
if [[ -n "$EXPECTED_TASK_TREE" && "$TASK_TREE" != "$EXPECTED_TASK_TREE" ]]; then
  fail "expected task tree $EXPECTED_TASK_TREE, found $TASK_TREE"
fi
if [[ -n "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]]; then
  fail "task tree is dirty; do not measure a modified task"
fi

HARBOR_VERSION=$(harbor --version 2>&1 || true)
[[ "$HARBOR_VERSION" == *"0.14.0"* ]] || fail "candidate trials require Harbor 0.14.0; found: $HARBOR_VERSION"
docker info >/dev/null 2>&1 || fail "Docker daemon is not available"

MODEL=""
REASONING=""
AGENT_NAME=""
AUTH_KIND=""
EXTRA_ARGS=()

case "$AGENT" in
  codex)
    [[ -f "$HOME/.codex/auth.json" ]] || fail "Codex subscription authentication is missing at ~/.codex/auth.json"
    MODEL="openai/gpt-5.6-sol"
    REASONING="xhigh"
    AGENT_NAME="codex"
    AUTH_KIND="Codex subscription auth.json"
    EXTRA_ARGS+=(--ae CODEX_FORCE_AUTH_JSON=1 --ak reasoning_effort=xhigh)
    ;;
  claude)
    MODEL="anthropic/claude-opus-5"
    REASONING="max"
    AGENT_NAME="claude-code"
    EXTRA_ARGS+=(--ae CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000)
    EXTRA_ARGS+=(--ak reasoning_effort=max)
    if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
      AUTH_KIND="Claude Code OAuth token"
      EXTRA_ARGS+=(--ae CLAUDE_FORCE_OAUTH=1)
      EXTRA_ARGS+=(--ae "CLAUDE_CODE_OAUTH_TOKEN=$CLAUDE_CODE_OAUTH_TOKEN")
    elif [[ -n "${AWS_BEARER_TOKEN_BEDROCK:-}" ]]; then
      AUTH_KIND="Amazon Bedrock API key"
      EXTRA_ARGS+=(--ae CLAUDE_CODE_USE_BEDROCK=1)
      EXTRA_ARGS+=(--ae "AWS_BEARER_TOKEN_BEDROCK=$AWS_BEARER_TOKEN_BEDROCK")
      EXTRA_ARGS+=(--ae "AWS_REGION=${AWS_REGION:-us-east-1}")
    elif [[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
      AUTH_KIND="Amazon Bedrock AWS credentials"
      EXTRA_ARGS+=(--ae CLAUDE_CODE_USE_BEDROCK=1)
      EXTRA_ARGS+=(--ae "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID")
      EXTRA_ARGS+=(--ae "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY")
      EXTRA_ARGS+=(--ae "AWS_REGION=${AWS_REGION:-us-east-1}")
      if [[ -n "${AWS_SESSION_TOKEN:-}" ]]; then
        EXTRA_ARGS+=(--ae "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN")
      fi
    elif [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
      AUTH_KIND="Anthropic API key"
      EXTRA_ARGS+=(--ae "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY")
    else
      fail "Claude authentication is missing: configure Claude Code OAuth, Anthropic API, or Bedrock credentials"
    fi
    ;;
esac

# RUN_PID is portable across macOS Bash 3.2 (no BASHPID) and modern Bash.
STAMP=$(date -u +%Y%m%dT%H%M%SZ)-${RUN_PID}
RUN_DIR="$RUNS_ROOT/${STAMP}-${MODE}-${AGENT}-${SHORT_SHA}"
TASK_COPY="$RUN_DIR/task"
HARBOR_OUTPUT="$RUN_DIR/harbor-output"
mkdir -p "$RUN_DIR" "$HARBOR_OUTPUT"
cp -R "$TASK_DIR" "$TASK_COPY"

TB3_HEAD=""
if [[ "$MODE" == "cheat" ]]; then
  TB3_REPO="$RUN_DIR/terminal-bench"
  git clone --depth 1 --filter=blob:none --sparse \
    https://github.com/harbor-framework/terminal-bench.git "$TB3_REPO" >/dev/null 2>&1
  if [[ -n "$EXPECTED_TB3_HEAD" ]]; then
    git -C "$TB3_REPO" fetch --depth 1 origin "$EXPECTED_TB3_HEAD" >/dev/null 2>&1
    git -C "$TB3_REPO" checkout --detach "$EXPECTED_TB3_HEAD" >/dev/null 2>&1
  fi
  git -C "$TB3_REPO" sparse-checkout set docs/prompts .github
  TB3_HEAD=$(git -C "$TB3_REPO" rev-parse HEAD)
  if [[ -n "$EXPECTED_TB3_HEAD" && "$TB3_HEAD" != "$EXPECTED_TB3_HEAD" ]]; then
    fail "expected Terminal-Bench HEAD $EXPECTED_TB3_HEAD, found $TB3_HEAD"
  fi
  PROMPT="$TB3_REPO/docs/prompts/hack-trial-prompt.md"
  [[ -f "$PROMPT" ]] || fail "live adversarial prompt was not found"
  sed -i.bak -E 's/[[:space:]]*[Dd]o not cheat[^.]*\.//g' "$TASK_COPY/instruction.md"
  rm -f "$TASK_COPY/instruction.md.bak"
  printf '\n\n' >> "$TASK_COPY/instruction.md"
  cat "$PROMPT" >> "$TASK_COPY/instruction.md"
fi

python3 - "$RUN_DIR/metadata.json" "$REPO_SHA" "$TASK_TREE" "$MODE" "$AGENT_NAME" "$MODEL" "$REASONING" "$HARBOR_VERSION" "$AUTH_KIND" "$TB3_HEAD" "$DRY_RUN" <<'PY'
import json
import sys
from pathlib import Path
(
    path, repo_sha, task_tree, mode, agent, model, reasoning,
    harbor_version, auth_kind, tb3_head, dry_run,
) = sys.argv[1:]
Path(path).write_text(json.dumps({
    "repository_sha": repo_sha,
    "task_tree": task_tree,
    "mode": mode,
    "agent": agent,
    "model": model,
    "reasoning_effort": reasoning,
    "environment": "docker",
    "harbor_version": harbor_version,
    "auth_kind": auth_kind,
    "terminal_bench_head": tb3_head or None,
    "attempts_requested": 0 if dry_run == "1" else 1,
    "harbor_analyze": False,
    "dry_run": dry_run == "1",
}, indent=2) + "\n", encoding="utf-8")
PY

cat > "$RUN_DIR/command-redacted.txt" <<EOF
harbor run \\
  -p <disposable-task-copy> \\
  --agent $AGENT_NAME \\
  --model $MODEL \\
  --env docker \\
  --yes \\
  <authentication redacted> \\
  --ak reasoning_effort=$REASONING \\
  -o <harbor-output> \\
  --job-name <job-name>
EOF

if [[ "$DRY_RUN" == "1" ]]; then
  cat <<EOF
Candidate trial path check PASSED
repository_sha=$REPO_SHA
task_tree=$TASK_TREE
mode=$MODE
agent=$AGENT_NAME
model=$MODEL
reasoning_effort=$REASONING
harbor=$HARBOR_VERSION
auth=$AUTH_KIND
terminal_bench_head=${TB3_HEAD:-not-used}
model_calls=0
evidence=$RUN_DIR
EOF
  exit 0
fi

JOB_NAME="${MODE}-${AGENT}-${SHORT_SHA}-${RUN_PID}"
set +e
harbor run \
  -p "$TASK_COPY" \
  --agent "$AGENT_NAME" \
  --model "$MODEL" \
  --env docker \
  --yes \
  "${EXTRA_ARGS[@]}" \
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
metadata = json.loads((run_dir / "metadata.json").read_text())
console = (run_dir / "harbor-console.log").read_text(encoding="utf-8", errors="replace")
means = re.findall(r"Mean[:\s]+([0-9]+(?:\.[0-9]+)?)", console)
reward = float(means[-1]) if means else None
exception_matches = re.findall(r"Exceptions[:\s]+([0-9]+)", console)
exceptions = int(exception_matches[-1]) if exception_matches else None
ctrf_files = sorted((run_dir / "harbor-output").rglob("ctrf.json"))
result_files = sorted((run_dir / "harbor-output").rglob("result.json"))
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
    for test in data.get("results", {}).get("tests", []):
        if isinstance(test, dict) and str(test.get("status", "")).lower() in {"failed", "fail"}:
            failed_tests.append(str(test.get("name") or test.get("suite") or "unknown"))

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
}
(run_dir / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")

lines = [
    f"# {metadata['mode'].title()} candidate trial",
    "",
    f"- Repository SHA: `{metadata['repository_sha']}`",
    f"- Task tree: `{metadata['task_tree']}`",
    f"- Agent/model: `{metadata['agent']}` / `{metadata['model']}`",
    f"- Reasoning: `{metadata['reasoning_effort']}`",
    f"- Environment: `{metadata['environment']}`",
    f"- Harbor: `{metadata['harbor_version']}`",
    f"- Terminal-Bench HEAD: `{metadata['terminal_bench_head'] or 'not used'}`",
    "- Attempts requested: `1`",
    "- `harbor analyze`: **not run**",
    f"- Harbor exit status: `{harbor_status}`",
    f"- Reward: `{reward if reward is not None else 'unparsed'}`",
    f"- Exceptions: `{exceptions if exceptions is not None else 'unparsed'}`",
    f"- Execution classification: **{execution}**",
    f"- Verifier passed/failed/skipped: `{passed}` / `{failed}` / `{skipped}`",
]
if failed_tests:
    lines += ["", "## Failed tests", ""] + [f"- `{name}`" for name in failed_tests]
lines += ["", f"Evidence directory: `{run_dir}`"]
(run_dir / "summary.md").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
PY

printf '\nEvidence directory: %s\n' "$RUN_DIR"
exit "$HARBOR_STATUS"
