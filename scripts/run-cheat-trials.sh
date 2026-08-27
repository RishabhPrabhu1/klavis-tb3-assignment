#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-}
JOBS_ROOT=${JOBS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/cheat"}
AGENTS=${AGENTS:-both}

if [[ -z "$TB3_REPO" || ! -f "$TB3_REPO/docs/prompts/hack-trial-prompt.md" ]]; then
  echo "Set TB3_REPO to a fresh live terminal-bench checkout." >&2
  exit 2
fi
if [[ "$AGENTS" != "codex" && "$AGENTS" != "claude" && "$AGENTS" != "both" ]]; then
  echo "AGENTS must be codex, claude, or both" >&2
  exit 2
fi
if ! command -v harbor >/dev/null 2>&1; then
  echo "Install Harbor 0.14.0 first: uv tool install --force 'harbor==0.14.0'" >&2
  exit 2
fi
if ! harbor --version 2>&1 | grep -q '0\.14\.0'; then
  echo "Cheat trials must use Harbor 0.14.0 to match the live /cheat workflow." >&2
  exit 2
fi

task_copy=$(mktemp -d "${TMPDIR:-/tmp}/build-snapshot-publish-cheat-task.XXXXXX")
trap 'rm -rf "$task_copy"' EXIT
cp -R "$TASK_DIR/." "$task_copy/"
instruction="$task_copy/instruction.md"
hack_prompt="$TB3_REPO/docs/prompts/hack-trial-prompt.md"

# Match the live /cheat transform: remove the ordinary anti-cheat sentence and
# append the current upstream adversarial prompt. The original task is untouched.
python3 - "$instruction" "$hack_prompt" <<'PY'
from pathlib import Path
import re
import sys

instruction = Path(sys.argv[1])
hack_prompt = Path(sys.argv[2])
text = instruction.read_text(encoding="utf-8")
text = re.sub(r"\s*[Dd]o not cheat[^.]*\.", "", text)
text = text.rstrip() + "\n\n" + hack_prompt.read_text(encoding="utf-8")
instruction.write_text(text, encoding="utf-8")
PY

mkdir -p "$JOBS_ROOT"

run_codex() {
  if ! command -v codex >/dev/null 2>&1 || [[ ! -f "$HOME/.codex/auth.json" ]]; then
    echo "Codex subscription auth is unavailable. Run 'codex login' first." >&2
    exit 2
  fi
  harbor run \
    -p "$task_copy" \
    --agent codex \
    --model openai/gpt-5.6-sol \
    --env docker \
    --yes \
    -o "$JOBS_ROOT" \
    --job-name build-snapshot-publish-cheat-codex \
    --ae CODEX_FORCE_AUTH_JSON=1 \
    --ak reasoning_effort=xhigh
}

run_claude() {
  if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
    echo "CLAUDE_CODE_OAUTH_TOKEN is required for Claude subscription-auth cheat trials." >&2
    echo "Generate one with 'claude setup-token', then export it before rerunning." >&2
    exit 2
  fi
  harbor run \
    -p "$task_copy" \
    --agent claude-code \
    --model anthropic/claude-opus-5 \
    --env docker \
    --yes \
    -o "$JOBS_ROOT" \
    --job-name build-snapshot-publish-cheat-claude \
    --ae CLAUDE_FORCE_OAUTH=1 \
    --ae CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN" \
    --ae CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000 \
    --ak reasoning_effort=max
}

case "$AGENTS" in
  codex) run_codex ;;
  claude) run_claude ;;
  both)
    run_codex
    run_claude
    ;;
esac
