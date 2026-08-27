#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
CONFIRM_FREEZE=${CONFIRM_FREEZE:-0}
CONFIRM_ZERO_COST_COVERAGE=${CONFIRM_ZERO_COST_COVERAGE:-0}
TB3_HEAD=${TB3_HEAD_EXPECTED:-79e71650f5b6a6ef5bb46a434c7c04d7d99a9480}
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}
QUAL_ROOT=${QUAL_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-preflight"}
RUBRIC_ROOT=${RUBRIC_ROOT:-"$HOME/.cache/klavis-tb3-runs/implementation-rubric"}
CLAUDE_STANDARD_PARALLEL=${CLAUDE_STANDARD_PARALLEL:-2}

fail() { echo "ERROR: $*" >&2; exit 2; }

[[ "$CONFIRM_FREEZE" == "1" ]] || fail "Set CONFIRM_FREEZE=1 only after this exact task tree is approved as frozen."
[[ "$CONFIRM_ZERO_COST_COVERAGE" == "1" ]] || fail "Claude model calls blocked. Set CONFIRM_ZERO_COST_COVERAGE=1 only for Klavis's subscription OAuth route or separately confirmed zero-cost provider coverage."
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ -f "$QUAL_ROOT/QUALIFICATION-PASSED-${TREE}.txt" ]] || fail "same-tree zero-model qualification marker is missing"

AUTH_MODE=""
if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  AUTH_MODE="oauth"
  # This is the route explicitly documented by Klavis: claude setup-token,
  # CLAUDE_FORCE_OAUTH=1, CLAUDE_CODE_OAUTH_TOKEN=<token>. Prevent provider/API fallback.
  unset ANTHROPIC_API_KEY || true
  unset AWS_BEARER_TOKEN_BEDROCK || true
  unset AWS_ACCESS_KEY_ID || true
  unset AWS_SECRET_ACCESS_KEY || true
  unset AWS_SESSION_TOKEN || true
  unset AWS_PROFILE || true
  unset CLAUDE_CODE_USE_BEDROCK || true
elif [[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "1" ]] && { [[ -n "${AWS_BEARER_TOKEN_BEDROCK:-}" ]] || [[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" ]] || [[ -n "${AWS_PROFILE:-}" ]]; }; then
  AUTH_MODE="bedrock"
  [[ -z "${ANTHROPIC_API_KEY:-}" ]] || fail "Unset ANTHROPIC_API_KEY for the Bedrock path"
  export AWS_REGION=${AWS_REGION:-us-east-1}
else
  fail "No zero-cost-covered Claude route found. Preferred: export a token from 'claude setup-token' as CLAUDE_CODE_OAUTH_TOKEN."
fi
export CONFIRM_ZERO_COST_COVERAGE=1

printf '=== DEADLINE CLAUDE PIPELINE ===\n'
printf 'execution_commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'terminal_bench_head=%s\n' "$TB3_HEAD"
printf 'auth_mode=%s\n' "$AUTH_MODE"
printf 'standard_target=3\n'
printf 'cheat_target=1\n'

if [[ "$AUTH_MODE" == "bedrock" ]]; then
  printf '\n[1/5] Bounded Claude Code / Opus 5 Bedrock entitlement smoke test\n'
  bash "$ROOT_DIR/scripts/smoke-test-claude-bedrock.sh"
else
  printf '\n[1/5] Claude subscription OAuth token present (no extra model smoke call)\n'
fi

printf '\n[2/5] Exact-tree Terminal-Bench implementation rubric\n'
if [[ ! -d "$TB3_REPO/.git" ]]; then
  git clone https://github.com/harbor-framework/terminal-bench.git "$TB3_REPO"
fi
git -C "$TB3_REPO" fetch origin
git -C "$TB3_REPO" checkout --detach "$TB3_HEAD"

existing_rubric=$(python3 - "$RUBRIC_ROOT" "$TREE" "$TB3_HEAD" <<'PY'
import json,sys
from pathlib import Path
root=Path(sys.argv[1]).expanduser(); tree=sys.argv[2]; tb3=sys.argv[3]; found=[]
if root.exists():
    for p in root.rglob('result.json'):
        try:d=json.loads(p.read_text(encoding='utf-8'))
        except Exception:continue
        if d.get('task_tree')==tree and d.get('terminal_bench_head')==tb3 and d.get('passed') is True and not (d.get('failed') or []):
            found.append((p.stat().st_mtime,p))
print(str(max(found)[1]) if found else '')
PY
)
if [[ -n "$existing_rubric" ]]; then
  echo "Reusing same-tree rubric PASS: $existing_rubric"
elif [[ "$AUTH_MODE" == "oauth" ]]; then
  EXPECTED_TASK_TREE="$TREE" EXPECTED_TB3_HEAD="$TB3_HEAD" TB3_REPO="$TB3_REPO" RUNS_ROOT="$RUBRIC_ROOT" CONFIRM_ZERO_COST_COVERAGE=1 \
    bash "$ROOT_DIR/scripts/run-implementation-rubric-oauth.sh"
else
  EXPECTED_TASK_TREE="$TREE" EXPECTED_TB3_HEAD="$TB3_HEAD" TB3_REPO="$TB3_REPO" RUNS_ROOT="$RUBRIC_ROOT" \
    bash "$ROOT_DIR/scripts/run-implementation-rubric-bedrock.sh"
fi

printf '\n[3/5] Claude Code / Opus 5 / max standard matrix: 3 valid model failures required\n'
CONFIRM_FREEZE=1 CONFIRM_ZERO_COST_COVERAGE=1 AGENT=claude MODE=standard TARGET_VALID_ZEROES=3 MAX_PARALLEL="$CLAUDE_STANDARD_PARALLEL" \
  bash "$ROOT_DIR/scripts/run-parallel-final-matrix.sh"

printf '\n[4/5] Claude Code / Opus 5 / max adversarial run: reward 0 required\n'
CONFIRM_FREEZE=1 CONFIRM_ZERO_COST_COVERAGE=1 AGENT=claude TARGET_CHEATS=1 TB3_HEAD_EXPECTED="$TB3_HEAD" \
  bash "$ROOT_DIR/scripts/run-deadline-cheat-matrix.sh"

printf '\n[5/5] Final submission audit\n'
set +e
bash "$ROOT_DIR/scripts/final-submission-audit.sh"
audit_status=$?
set -e

if [[ $audit_status -eq 0 ]]; then
  echo "CLAUDE_PIPELINE_STATUS=COMPLETE_AND_FINAL_AUDIT_READY"
else
  echo "CLAUDE_PIPELINE_STATUS=CLAUDE_COMPLETE_OTHER_REQUIREMENTS_REMAIN"
fi
exit "$audit_status"
