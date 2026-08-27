#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TB3_REPO=${TB3_REPO:-"$HOME/.cache/klavis-tb3-terminal-bench"}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/implementation-rubric"}
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-}

fail() { echo "ERROR: $*" >&2; exit 2; }
command -v uvx >/dev/null 2>&1 || fail "uvx is required"
[[ -d "$TB3_REPO/.git" ]] || fail "Terminal-Bench checkout missing at $TB3_REPO"
TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
[[ -z "$EXPECTED_TASK_TREE" || "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

[[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "1" ]] || fail "set CLAUDE_CODE_USE_BEDROCK=1"
if [[ -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && -z "${AWS_ACCESS_KEY_ID:-}" && -z "${AWS_PROFILE:-}" ]]; then
  fail "Bedrock credentials are not configured"
fi
if [[ -n "${ANTHROPIC_API_KEY:-}" || -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  fail "unset ANTHROPIC_API_KEY and CLAUDE_CODE_OAUTH_TOKEN for the Bedrock rubric path"
fi
export AWS_REGION=${AWS_REGION:-us-east-1}
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000

UPSTREAM_HEAD=$(git -C "$TB3_REPO" rev-parse HEAD)
RUBRIC="$TB3_REPO/docs/prompts/task-implementation.toml"
REVIEW_INSTRUCTION="$TB3_REPO/scripts/rubric-regression/templates/instruction.md"
[[ -f "$RUBRIC" ]] || fail "live rubric missing: $RUBRIC"
[[ -f "$REVIEW_INSTRUCTION" ]] || fail "rubric reviewer instruction missing: $REVIEW_INSTRUCTION"

STAMP=$(date -u +%Y%m%dT%H%M%SZ)
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
  "auth_kind": "Amazon Bedrock",
  "aws_region": "$AWS_REGION"
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

python3 - "$VERDICTS" "$RUBRIC" "$RUN_DIR/result.json" <<'PY'
import json,sys,tomllib
from pathlib import Path
src,rubric_path,out=map(Path,sys.argv[1:])
doc=json.JSONDecoder().raw_decode(src.read_text(encoding="utf-8").lstrip())[0]
checks=doc.get("checks")
if not isinstance(checks,dict) or not checks:
    raise SystemExit("invalid verdicts: missing checks dict")
rubric=tomllib.loads(rubric_path.read_text(encoding="utf-8"))
criteria=[c["name"] for c in rubric["criteria"]]
missing=[name for name in criteria if name not in checks]
if missing:
    raise SystemExit(f"verdicts missing criteria: {missing}")
failed=[]
for name in criteria:
    value=checks[name]
    # Upstream verdict shape has evolved; treat explicit false/fail values as failures.
    if isinstance(value,bool):
        ok=value
    elif isinstance(value,dict):
        raw=value.get("passed",value.get("pass",value.get("result",value.get("status"))))
        ok = raw is True or (isinstance(raw,str) and raw.lower() in {"pass","passed","ok","true"})
    else:
        ok = isinstance(value,str) and value.lower() in {"pass","passed","ok","true"}
    if not ok:
        failed.append(name)
payload={"checks":checks,"criteria":criteria,"failed":failed,"passed":len(failed)==0,"source_verdicts":str(src)}
out.write_text(json.dumps(payload,indent=2)+"\n",encoding="utf-8")
print("\n=== IMPLEMENTATION RUBRIC REPORT ===")
print(f"criteria={len(criteria)}")
print(f"failed={len(failed)}")
for name in failed:
    print(f"FAIL {name}")
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
