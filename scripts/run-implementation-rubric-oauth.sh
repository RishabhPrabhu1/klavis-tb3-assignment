#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/implementation-rubric"}
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-}
EXPECTED_TB3_HEAD=${EXPECTED_TB3_HEAD:-"79e71650f5b6a6ef5bb46a434c7c04d7d99a9480"}
CONFIRM_ZERO_COST_COVERAGE=${CONFIRM_ZERO_COST_COVERAGE:-0}

fail() { echo "ERROR: $*" >&2; exit 2; }
command -v uvx >/dev/null 2>&1 || fail "uvx is required"
[[ -d "$TB3_REPO/.git" ]] || fail "Terminal-Bench checkout missing at $TB3_REPO"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
[[ -z "$EXPECTED_TASK_TREE" || "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"
[[ "$CONFIRM_ZERO_COST_COVERAGE" == "1" ]] || fail "set CONFIRM_ZERO_COST_COVERAGE=1 only for Klavis's subscription/OAuth route with zero API billing"
[[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]] || fail "CLAUDE_CODE_OAUTH_TOKEN is missing; run 'claude setup-token' first"
# Prevent accidental API/provider fallback.
unset ANTHROPIC_API_KEY || true
unset AWS_BEARER_TOKEN_BEDROCK || true
unset AWS_ACCESS_KEY_ID || true
unset AWS_SECRET_ACCESS_KEY || true
unset AWS_SESSION_TOKEN || true
unset AWS_PROFILE || true
unset CLAUDE_CODE_USE_BEDROCK || true
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000

UPSTREAM_HEAD=$(git -C "$TB3_REPO" rev-parse HEAD)
[[ "$UPSTREAM_HEAD" == "$EXPECTED_TB3_HEAD" ]] || fail "expected Terminal-Bench HEAD $EXPECTED_TB3_HEAD, found $UPSTREAM_HEAD"
RUBRIC="$TB3_REPO/docs/prompts/task-implementation.toml"
REVIEW_INSTRUCTION="$TB3_REPO/scripts/rubric-regression/templates/instruction.md"
[[ -f "$RUBRIC" ]] || fail "live rubric missing: $RUBRIC"
[[ -f "$REVIEW_INSTRUCTION" ]] || fail "rubric reviewer instruction missing: $REVIEW_INSTRUCTION"

RUN_PID=${BASHPID:-$$}
STAMP=$(date -u +%Y%m%dT%H%M%SZ)-${RUN_PID}
RUN_DIR="$RUNS_ROOT/${STAMP}-${TREE:0:12}"
STAGE="$RUN_DIR/stage"
mkdir -p "$STAGE/task-under-review" "$RUN_DIR/jobs"
cp -R "$ROOT_DIR/$TASK_REL" "$STAGE/task-under-review/"
cp "$RUBRIC" "$STAGE/rubric.toml"

cat > "$RUN_DIR/metadata.json" <<EOF
{
  "repository_sha": "$(git -C "$ROOT_DIR" rev-parse HEAD)",
  "task_tree": "$TREE",
  "terminal_bench_head": "$UPSTREAM_HEAD",
  "harbor_version": "0.18.0",
  "review_agent": "claude-code",
  "review_model": "sonnet",
  "auth_kind": "Claude Code subscription OAuth"
}
EOF

cd "$RUN_DIR"
set +e
uvx --from harbor==0.18.0 harbor exec \
  -p "$STAGE/task-under-review" \
  -p "$STAGE/rubric.toml" \
  --instruction-path "$REVIEW_INSTRUCTION" \
  -f /app/verdicts.json \
  --image ubuntu:24.04 \
  -a claude-code -m sonnet \
  --ae CLAUDE_FORCE_OAUTH=1 \
  --ae "CLAUDE_CODE_OAUTH_TOKEN=$CLAUDE_CODE_OAUTH_TOKEN" \
  --ae CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000 \
  --jobs-dir "$RUN_DIR/jobs" \
  --job-name rubric-review \
  2>&1 | tee "$RUN_DIR/harbor-console.log"
STATUS=${PIPESTATUS[0]}
set -e

VERDICTS=$(find "$RUN_DIR/jobs/rubric-review" -path '*/artifacts/app/verdicts.json' 2>/dev/null | head -1 || true)
if [[ -z "$VERDICTS" ]]; then
  echo "RUBRIC_STATUS=INVALID_NO_VERDICTS"
  echo "harbor_exit=$STATUS"
  echo "evidence=$RUN_DIR"
  exit 21
fi

python3 - "$VERDICTS" "$RUBRIC" "$RUN_DIR/result.json" "$RUN_DIR/metadata.json" <<'PY'
import json,sys,tomllib
from pathlib import Path
src,rubric_path,out,metadata_path=map(Path,sys.argv[1:])
doc=json.JSONDecoder().raw_decode(src.read_text(encoding="utf-8").lstrip())[0]
checks=doc.get("checks")
if not isinstance(checks,dict) or not checks:
    raise SystemExit("invalid verdicts: missing checks dict")
rubric=tomllib.loads(rubric_path.read_text(encoding="utf-8"))
criteria=[c["name"] for c in rubric["criteria"]]
missing=[name for name in criteria if name not in checks]
if missing:
    raise SystemExit(f"verdicts missing criteria: {missing}")
failed=[]; passed=[]; not_applicable=[]
for name in criteria:
    value=checks[name]
    raw=value.get("outcome",value.get("passed",value.get("pass",value.get("result",value.get("status"))))) if isinstance(value,dict) else value
    if raw is True or (isinstance(raw,str) and raw.lower() in {"pass","passed","ok","true"}): passed.append(name)
    elif isinstance(raw,str) and raw.lower() in {"not_applicable","not applicable","n/a","na"}: not_applicable.append(name)
    else: failed.append(name)
meta=json.loads(metadata_path.read_text(encoding="utf-8"))
payload={**meta,"checks":checks,"criteria":criteria,"failed":failed,"passed_criteria":passed,"not_applicable":not_applicable,"passed":not failed,"source_verdicts":str(src)}
out.write_text(json.dumps(payload,indent=2)+"\n",encoding="utf-8")
print("\n=== IMPLEMENTATION RUBRIC REPORT ===")
print(f"task_tree={payload['task_tree']}")
print(f"terminal_bench_head={payload['terminal_bench_head']}")
print(f"criteria={len(criteria)}")
print(f"passed={len(passed)}")
print(f"not_applicable={len(not_applicable)}")
print(f"failed={len(failed)}")
for name in failed:
    explanation=checks.get(name,{}).get("explanation","") if isinstance(checks.get(name),dict) else ""
    print(f"FAIL {name}: {explanation}")
print(f"overall={'PASS' if not failed else 'FAIL'}")
print(f"result_json={out}")
print("=== END IMPLEMENTATION RUBRIC REPORT ===")
PY

if python3 - "$RUN_DIR/result.json" <<'PY'
import json,sys
raise SystemExit(0 if json.load(open(sys.argv[1]))["passed"] else 1)
PY
then
  echo "RUBRIC_STATUS=PASS"
  exit 0
fi

echo "RUBRIC_STATUS=FAIL"
exit 1
