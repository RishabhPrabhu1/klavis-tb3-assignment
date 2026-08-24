#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/hermetic-build-cache"
HARBOR_ENV=${HARBOR_ENV:-docker}
JOBS_DIR=${JOBS_DIR:-"${TMPDIR:-/tmp}/hermetic-build-cache-jobs/oracle"}

harbor run \
  --path "$TASK_DIR" \
  --agent oracle \
  --env "$HARBOR_ENV" \
  --n-attempts 1 \
  --jobs-dir "$JOBS_DIR" \
  --job-name hermetic-build-cache-oracle
