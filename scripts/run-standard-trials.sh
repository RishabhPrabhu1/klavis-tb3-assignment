#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
JOBS_ROOT=${JOBS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/standard"}
N_ATTEMPTS=${N_ATTEMPTS:-3}
AGENTS=${AGENTS:-both}

if ! [[ "$N_ATTEMPTS" =~ ^[1-9][0-9]*$ ]] || (( N_ATTEMPTS > 10 )); then
  echo "N_ATTEMPTS must be an integer from 1 to 10" >&2
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
  echo "Standard trials must use Harbor 0.14.0 to match the live /run workflow." >&2
  echo "Install it with: uv tool install --force 'harbor==0.14.0'" >&2
  exit 2
fi

mkdir -p "$JOBS_ROOT"

run_codex() {
  if ! command -v codex >/dev/null 2>&1 || [[ ! -f "$HOME/.codex/auth.json" ]]; then
    echo "Codex subscription auth is unavailable. Run 'codex login' first." >&2
    exit 2
  fi
  for attempt in $(seq 1 "$N_ATTEMPTS"); do
    harbor run \
      -p "$TASK_DIR" \
      --agent codex \
      --model openai/gpt-5.6-sol \
      --env docker \
      --yes \
      -o "$JOBS_ROOT" \
      --job-name "build-snapshot-publish-codex-${attempt}" \
      --ae CODEX_FORCE_AUTH_JSON=1 \
      --ak reasoning_effort=xhigh
  done
}

run_claude() {
  if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
    echo "CLAUDE_CODE_OAUTH_TOKEN is required for Claude subscription-auth trials." >&2
    echo "Generate one with 'claude setup-token', then export it before rerunning." >&2
    exit 2
  fi
  for attempt in $(seq 1 "$N_ATTEMPTS"); do
    harbor run \
      -p "$TASK_DIR" \
      --agent claude-code \
      --model anthropic/claude-opus-5 \
      --env docker \
      --yes \
      -o "$JOBS_ROOT" \
      --job-name "build-snapshot-publish-claude-${attempt}" \
      --ae CLAUDE_FORCE_OAUTH=1 \
      --ae CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN" \
      --ae CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000 \
      --ak reasoning_effort=max
  done
}

case "$AGENTS" in
  codex) run_codex ;;
  claude) run_claude ;;
  both)
    run_codex
    run_claude
    ;;
esac
