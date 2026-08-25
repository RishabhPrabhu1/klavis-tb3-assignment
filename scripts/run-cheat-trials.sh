#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-}
HARBOR_ENV=${HARBOR_ENV:-modal}
JOBS_ROOT=${JOBS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/cheat"}

if [[ -z "$TB3_REPO" || ! -f "$TB3_REPO/rubrics/hack-trial-prompt.md" ]]; then
  echo "Set TB3_REPO to the live terminal-bench checkout; the cheat helper uses its current hack prompt." >&2
  exit 2
fi

task_copy=$(mktemp -d "${TMPDIR:-/tmp}/build-snapshot-publish-cheat-task.XXXXXX")
body=$(mktemp "${TMPDIR:-/tmp}/build-snapshot-publish-instruction.XXXXXX")
trap 'rm -rf "$task_copy"; rm -f "$body"' EXIT
cp -R "$TASK_DIR/." "$task_copy/"
instruction="$task_copy/instruction.md"
sed -E 's/[[:space:]]*[Dd]o not cheat[^.]*\.//g' "$instruction" > "$body"
{
  cat "$TB3_REPO/rubrics/hack-trial-prompt.md"
  printf '\n\n'
  cat "$body"
} > "$instruction"

mkdir -p "$JOBS_ROOT"

CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000 harbor run \
  --path "$task_copy" \
  --agent claude-code \
  --model anthropic/claude-opus-5 \
  --agent-kwarg reasoning_effort=max \
  --env "$HARBOR_ENV" \
  --n-attempts 3 \
  --n-concurrent 3 \
  --jobs-dir "$JOBS_ROOT/claude-opus-5" \
  --job-name build-snapshot-publish-claude-cheat

harbor run \
  --path "$task_copy" \
  --agent codex \
  --model openai/gpt-5.6-sol \
  --agent-kwarg reasoning_effort=xhigh \
  --env "$HARBOR_ENV" \
  --n-attempts 3 \
  --n-concurrent 3 \
  --jobs-dir "$JOBS_ROOT/codex-gpt-5.6-sol" \
  --job-name build-snapshot-publish-codex-cheat
