#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
HARBOR_ENV=${HARBOR_ENV:-modal}
JOBS_ROOT=${JOBS_ROOT:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/standard"}
JOB_NAME=${JOB_NAME:-build-snapshot-publish-standard}

mkdir -p "$JOBS_ROOT"
config=$(mktemp "${TMPDIR:-/tmp}/build-snapshot-publish-standard.XXXXXX.json")
trap 'rm -f "$config"' EXIT

python3 - "$config" "$TASK_DIR" "$HARBOR_ENV" "$JOBS_ROOT" "$JOB_NAME" <<'PY'
import json
import sys

config, task, env_type, jobs_dir, job_name = sys.argv[1:]
payload = {
    "job_name": job_name,
    "jobs_dir": jobs_dir,
    "n_attempts": 3,
    "n_concurrent_trials": 6,
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
