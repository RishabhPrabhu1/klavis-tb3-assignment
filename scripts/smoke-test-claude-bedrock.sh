#!/usr/bin/env bash
set -euo pipefail

# Zero-cost/credit-only Claude Code -> Amazon Bedrock entitlement smoke test.
# This is NOT a Terminal-Bench trial and must never be counted as evaluation evidence.
# It makes at most one tiny Opus 5 request with a strict budget and turn cap.

REGION=${AWS_REGION:-us-east-1}
MODEL=${CLAUDE_BEDROCK_SMOKE_MODEL:-global.anthropic.claude-opus-5}
MAX_BUDGET_USD=${CLAUDE_BEDROCK_SMOKE_MAX_USD:-0.05}
DRY_RUN=${DRY_RUN:-0}

fail() { echo "ERROR: $*" >&2; exit 2; }

command -v claude >/dev/null 2>&1 || fail "Claude Code CLI is not installed"

if [[ -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && ( -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ) && -z "${AWS_PROFILE:-}" ]]; then
  fail "No Bedrock credentials found. Configure AWS_BEARER_TOKEN_BEDROCK, AWS access credentials, or AWS_PROFILE."
fi

export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION="$REGION"

cat <<EOF
=== CLAUDE BEDROCK OPUS 5 SMOKE TEST ===
provider=Amazon Bedrock
model=$MODEL
region=$REGION
max_turns=1
max_budget_usd=$MAX_BUDGET_USD
purpose=entitlement/routing check only; NOT evaluation evidence
EOF

if [[ "$DRY_RUN" == "1" ]]; then
  echo "status=DRY_RUN_NO_MODEL_CALL"
  exit 0
fi

TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/klavis-claude-smoke.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT
OUT="$TMP_DIR/result.json"
ERR="$TMP_DIR/stderr.log"

set +e
claude -p \
  --model "$MODEL" \
  --effort max \
  --max-turns 1 \
  --max-budget-usd "$MAX_BUDGET_USD" \
  --no-session-persistence \
  --output-format json \
  "Do not use tools. Reply with exactly OPUS5_BEDROCK_OK and nothing else." \
  >"$OUT" 2>"$ERR"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "status=FAILED"
  echo "claude_exit=$status"
  if grep -Eqi 'access|not authorized|not entitled|marketplace|subscription|403|AccessDenied|ValidationException|model.*not.*available' "$ERR" "$OUT" 2>/dev/null; then
    echo "classification=BEDROCK_ACCESS_OR_ENTITLEMENT_BLOCK"
  elif grep -Eqi 'credential|token|signature|ExpiredToken|UnrecognizedClient|Unauthorized' "$ERR" "$OUT" 2>/dev/null; then
    echo "classification=BEDROCK_CREDENTIAL_ERROR"
  else
    echo "classification=OTHER_CLAUDE_BEDROCK_ERROR"
  fi
  echo "No retry is automatic. Inspect the error before any further model call."
  sed -n '1,80p' "$ERR" | sed -E 's/(token|key|secret)[^ ]*/\1=<redacted>/Ig' >&2 || true
  exit "$status"
fi

if ! grep -q 'OPUS5_BEDROCK_OK' "$OUT"; then
  echo "status=FAILED"
  echo "classification=UNEXPECTED_RESPONSE"
  echo "Claude Code completed, but the expected sentinel was not present."
  exit 3
fi

echo "status=PASS"
echo "classification=OPUS5_BEDROCK_CLAUDE_CODE_CONFIRMED"
echo "This proves only connectivity/entitlement. It does not count toward Klavis /run or /cheat evidence."
