#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"

if ! command -v harbor >/dev/null 2>&1; then
  echo "harbor is not installed. Install Harbor 0.14.0 first:" >&2
  echo "  uv tool install 'harbor==0.14.0'" >&2
  exit 2
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex is not installed or not on PATH. Install/update Codex CLI and sign in with your ChatGPT account first." >&2
  exit 2
fi

if [[ ! -f "$HOME/.codex/auth.json" ]]; then
  echo "No Codex subscription auth found at ~/.codex/auth.json." >&2
  echo "Run 'codex login' first, complete the ChatGPT sign-in, then rerun this script." >&2
  exit 2
fi

cat <<'EOF'
Running one strong-model diagnostic with the exact current TB3/Klavis Codex configuration:
  agent: codex
  model: openai/gpt-5.6-sol
  reasoning: xhigh
  environment: docker
  auth: local ChatGPT/Codex subscription auth

This is a diagnostic only. A reward of 0 counts only if the agent and verifier both ran normally and the model genuinely failed the task.
EOF

harbor run \
  -p "$TASK_DIR" \
  --agent codex \
  --model openai/gpt-5.6-sol \
  --env docker \
  --yes \
  --ae CODEX_FORCE_AUTH_JSON=1 \
  --ak reasoning_effort=xhigh
