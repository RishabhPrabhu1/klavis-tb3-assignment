#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-}
HARBOR_ENV=${HARBOR_ENV:-modal}
JOBS_ROOT=${JOBS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/cheat"}
JOB_NAME=${JOB_NAME:-build-snapshot-publish-cheat}

if [[ -z "$TB3_REPO" || ! -f "$TB3_REPO/rubrics/hack-trial-prompt.md" ]]; then
  echo "Set TB3_REPO to the live terminal-bench checkout; the cheat helper uses its current hack prompt." >&2
  exit 2
fi

task_copy=$(mktemp -d "${TMPDIR:-/tmp}/build-snapshot-publish-cheat-task.XXXXXX")
config=$(mktemp "${TMPDIR:-/tmp}/build-snapshot-publish-cheat.XXXXXX.json")
trap 'rm -rf "$task_copy"; rm -f "$config"' EXIT
cp -R "$TASK_DIR/." "$task_copy/"
instruction="$task_copy/instruction.md"
hack_prompt="$TB3_REPO/rubrics/hack-trial-prompt.md"

# Match the live /cheat workflow's remove-then-append transform without relying
# on GNU sed -i semantics (the development machine may be macOS/BSD sed).
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

# Match the live remote /cheat workflow: one Harbor invocation fans out one
# adversarial attempt for each configured task/agent pair.
python3 - "$config" "$task_copy" "$HARBOR_ENV" "$JOBS_ROOT" "$JOB_NAME" <<'PY'
import json
import sys

config, task, env_type, jobs_dir, job_name = sys.argv[1:]
payload = {
    "job_name": job_name,
    "jobs_dir": jobs_dir,
    "n_attempts": 1,
    "n_concurrent_trials": 2,
    "environment": {"type": env_type},
    "agents": [
        {
            "name": "claude-code",
            "model_name": "anthropic/claude-opus-5",
            "kwargs": {"reasoning_effort": "max"},
            "env": {"CLAUDE_CODE_MAX_OUTPUT_TOKENS": "128000"},
        },
        {
            "name": "codex",
            "model_name": "openai/gpt-5.6-sol",
            "kwargs": {"reasoning_effort": "xhigh"},
            "env": {},
        },
    ],
    "tasks": [{"path": task}],
}
with open(config, "w", encoding="utf-8") as stream:
    json.dump(payload, stream, indent=2)
    stream.write("\n")
PY

cat "$config"
harbor run -c "$config"
