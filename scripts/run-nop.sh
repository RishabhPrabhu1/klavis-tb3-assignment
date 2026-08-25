#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_DIR="$ROOT_DIR/tasks/build-snapshot-publish"
HARBOR_ENV=${HARBOR_ENV:-modal}
JOBS_DIR=${JOBS_DIR:-"${TMPDIR:-/tmp}/build-snapshot-publish-jobs/nop"}

harbor run \
  -p "$TASK_DIR" \
  --agent nop \
  --env "$HARBOR_ENV" \
  --n-attempts 1 \
  --jobs-dir "$JOBS_DIR" \
  --job-name build-snapshot-publish-nop
