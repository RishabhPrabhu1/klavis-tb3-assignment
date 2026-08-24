#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
HARBOR_ENV=${HARBOR_ENV:-modal}
JOBS_ROOT=${JOBS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/standard"}

mkdir -p "$JOBS_ROOT"

CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000 harbor run \
  --path "$TASK_DIR" \
  --agent claude-code \
  --model anthropic/claude-opus-5 \
  --agent-kwarg reasoning_effort=max \
  --env "$HARBOR_ENV" \
  --n-attempts 3 \
  --n-concurrent 3 \
  --jobs-dir "$JOBS_ROOT/claude-opus-5" \
  --job-name build-snapshot-publish-claude-standard

harbor run \
  --path "$TASK_DIR" \
  --agent codex \
  --model openai/gpt-5.6-sol \
  --agent-kwarg reasoning_effort=xhigh \
  --env "$HARBOR_ENV" \
  --n-attempts 3 \
  --n-concurrent 3 \
  --jobs-dir "$JOBS_ROOT/codex-gpt-5.6-sol" \
  --job-name build-snapshot-publish-codex-standard
