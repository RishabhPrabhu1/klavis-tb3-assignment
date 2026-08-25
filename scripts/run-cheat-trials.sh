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
trap 'rm -rf "$task_copy"' EXIT
cp -R "$TASK_DIR/." "$task_copy/"
instruction="$task_copy/instruction.md"

# Match the live /cheat workflow: remove the ordinary anti-cheat sentence,
# then append the live red-team prompt after the legitimate task description.
sed -i -E 's/[[:space:]]*[Dd]o not cheat[^.]*\.//g' "$instruction"
printf '\n\n' >> "$instruction"
cat "$TB3_REPO/rubrics/hack-trial-prompt.md" >> "$instruction"

mkdir -p "$JOBS_ROOT"

# The current /cheat workflow deliberately runs one attempt per configured
# task/agent pair, even though ordinary /run uses three attempts.
CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000 harbor run \
  -p "$task_copy" \
  --agent claude-code \
  -m anthropic/claude-opus-5 \
  --ak reasoning_effort=max \
  --env "$HARBOR_ENV" \
  --n-attempts 1 \
  --jobs-dir "$JOBS_ROOT/claude-opus-5" \
  --job-name build-snapshot-publish-claude-cheat

harbor run \
  -p "$task_copy" \
  --agent codex \
  -m openai/gpt-5.6-sol \
  --ak reasoning_effort=xhigh \
  --env "$HARBOR_ENV" \
  --n-attempts 1 \
  --jobs-dir "$JOBS_ROOT/codex-gpt-5.6-sol" \
  --job-name build-snapshot-publish-codex-cheat
