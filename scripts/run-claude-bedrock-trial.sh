#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TASK_REL="tasks/build-snapshot-publish"
TASK_DIR="$ROOT_DIR/$TASK_REL"
MODE=${MODE:-standard}
DRY_RUN=${DRY_RUN:-0}
EXPECTED_TASK_TREE=${EXPECTED_TASK_TREE:-}
EXPECTED_TB3_HEAD=${EXPECTED_TB3_HEAD:-}
RUNS_ROOT=${RUNS_ROOT:-"$HOME/.cache/klavis-tb3-runs/transaction-claude"}
MODEL="anthropic/claude-opus-5"
REASONING="max"
AGENT_NAME="claude-code"

fail() { echo "ERROR: $*" >&2; exit 2; }
[[ "$MODE" == "standard" || "$MODE" == "cheat" ]] || fail "MODE must be standard or cheat"
[[ "$DRY_RUN" == "0" || "$DRY_RUN" == "1" ]] || fail "DRY_RUN must be 0 or 1"

for command in git python3 docker harbor; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required"
done
[[ "$(harbor --version 2>&1)" == *"0.14.0"* ]] || fail "Harbor 0.14.0 is required"
docker info >/dev/null 2>&1 || fail "Docker is unavailable"

TREE=$(git -C "$ROOT_DIR" rev-parse "HEAD:$TASK_REL")
REPO_SHA=$(git -C "$ROOT_DIR" rev-parse HEAD)
SHORT_SHA=${REPO_SHA:0:12}
[[ -z "$EXPECTED_TASK_TREE" || "$TREE" == "$EXPECTED_TASK_TREE" ]] || fail "expected task tree $EXPECTED_TASK_TREE, found $TREE"
[[ -z "$(git -C "$ROOT_DIR" status --porcelain -- "$TASK_REL")" ]] || fail "task tree is dirty"

# Bedrock-only auth: never fall through to paid Anthropic API or Claude subscription OAuth.
[[ "${CLAUDE_CODE_USE_BEDROCK:-}" == "1" ]] || fail "set CLAUDE_CODE_USE_BEDROCK=1"
if [[ -z "${AWS_BEARER_TOKEN_BEDROCK:-}" && -z "${AWS_ACCESS_KEY_ID:-}" && -z "${AWS_PROFILE:-}" ]]; then
  fail "Bedrock credentials missing: set AWS_BEARER_TOKEN_BEDROCK, AWS_ACCESS_KEY_ID/SECRET, or AWS_PROFILE"
fi
if [[ -n "${ANTHROPIC_API_KEY:-}" || -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  fail "unset ANTHROPIC_API_KEY and CLAUDE_CODE_OAUTH_TOKEN for the zero-spend Bedrock path"
fi
export AWS_REGION=${AWS_REGION:-us-east-1}
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000

STAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_DIR="$RUNS_ROOT/${STAMP}-${MODE}-claude-bedrock-${SHORT_SHA}"
TASK_COPY="$RUN_DIR/task"
HARBOR_OUTPUT="$RUN_DIR/harbor-output"
mkdir -p "$RUN_DIR" "$HARBOR_OUTPUT"
cp -R "$TASK_DIR" "$TASK_COPY"

TB3_HEAD=""
if [[ "$MODE" == "cheat" ]]; then
  TB3_REPO="$RUN_DIR/terminal-bench"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/harbor-framework/terminal-bench.git "$TB3_REPO" >/dev/null 2>&1
  git -C "$TB3_REPO" sparse-checkout set docs/prompts .github
  TB3_HEAD=$(git -C "$TB3_REPO" rev-parse HEAD)
  [[ -z "$EXPECTED_TB3_HEAD" || "$TB3_HEAD" == "$EXPECTED_TB3_HEAD" ]] || fail "expected TB3 HEAD $EXPECTED_TB3_HEAD, found $TB3_HEAD"
  PROMPT="$TB3_REPO/docs/prompts/hack-trial-prompt.md"
  [[ -f "$PROMPT" ]] || fail "live adversarial prompt missing"
  sed -i.bak -E 's/[[:space:]]*[Dd]o not cheat[^.]*\.//g' "$TASK_COPY/instruction.md"
  rm -f "$TASK_COPY/instruction.md.bak"
  printf '\n\n' >> "$TASK_COPY/instruction.md"
  cat "$PROMPT" >> "$TASK_COPY/instruction.md"
fi

python3 - "$RUN_DIR/metadata.json" "$REPO_SHA" "$TREE" "$MODE" "$TB3_HEAD" <<'PY'
import json, os, sys
from pathlib import Path
path, sha, tree, mode, tb3 = sys.argv[1:]
Path(path).write_text(json.dumps({
  "repository_sha": sha,
  "task_tree": tree,
  "mode": mode,
  "agent": "claude-code",
  "model": "anthropic/claude-opus-5",
  "reasoning_effort": "max",
  "environment": "docker",
  "harbor_version": "0.14.0",
  "auth_kind": "Amazon Bedrock",
  "aws_region": os.environ.get("AWS_REGION", "us-east-1"),
  "terminal_bench_head": tb3 or None,
  "attempts_requested": 1,
  "harbor_analyze": False,
  "dry_run": False,
}, indent=2)+"\n", encoding="utf-8")
PY

cat > "$RUN_DIR/command-redacted.txt" <<EOF
CLAUDE_CODE_USE_BEDROCK=1 AWS_REGION=$AWS_REGION <AWS credentials redacted> \\
harbor run -p <task-copy> --agent claude-code --model anthropic/claude-opus-5 \\
  --env docker --yes --ak reasoning_effort=max -o <harbor-output> --job-name <job>
EOF

if [[ "$DRY_RUN" == "1" ]]; then
  echo "Claude Bedrock trial path check PASSED"
  echo "repository_sha=$REPO_SHA"
  echo "task_tree=$TREE"
  echo "mode=$MODE"
  echo "agent=$AGENT_NAME"
  echo "model=$MODEL"
  echo "reasoning_effort=$REASONING"
  echo "aws_region=$AWS_REGION"
  echo "model_calls=0"
  echo "evidence=$RUN_DIR"
  exit 0
fi

JOB_NAME="${MODE}-claude-bedrock-${SHORT_SHA}"
set +e
harbor run \
  -p "$TASK_COPY" \
  --agent "$AGENT_NAME" \
  --model "$MODEL" \
  --env docker \
  --yes \
  --ak reasoning_effort=max \
  -o "$HARBOR_OUTPUT" \
  --job-name "$JOB_NAME" \
  2>&1 | tee "$RUN_DIR/harbor-console.log"
HARBOR_STATUS=${PIPESTATUS[0]}
set -e

python3 - "$RUN_DIR" "$HARBOR_STATUS" <<'PY'
import json, re, sys
from pathlib import Path
run=Path(sys.argv[1]); status=int(sys.argv[2])
meta=json.loads((run/"metadata.json").read_text())
console=(run/"harbor-console.log").read_text(encoding="utf-8",errors="replace")
means=re.findall(r"Mean[:\s]+([0-9]+(?:\.[0-9]+)?)",console)
reward=float(means[-1]) if means else None
ctrfs=sorted((run/"harbor-output").rglob("ctrf.json")); results=sorted((run/"harbor-output").rglob("result.json"))
passed=failed=skipped=None; failed_tests=[]
for p in ctrfs:
    try: d=json.loads(p.read_text(encoding="utf-8"))
    except Exception: continue
    s=d.get("results",{}).get("summary",{})
    if isinstance(s,dict):
        passed=s.get("passed",passed); failed=s.get("failed",failed); skipped=s.get("skipped",skipped)
    for t in d.get("results",{}).get("tests",[]):
        if isinstance(t,dict) and str(t.get("status","")).lower() in {"failed","fail"}:
            failed_tests.append(str(t.get("name") or t.get("suite") or "unknown"))
execution="infrastructure-or-run-error" if status else ("completed-but-reward-unparsed" if reward is None else "valid-completed-trial")
summary={**meta,"harbor_exit_status":status,"reward":reward,"execution_class":execution,
         "tests":{"passed":passed,"failed":failed,"skipped":skipped},
         "tests_passed":passed,"tests_failed":failed,"tests_skipped":skipped,
         "failed_tests":failed_tests,"result_files":[str(p) for p in results],"ctrf_files":[str(p) for p in ctrfs]}
(run/"summary.json").write_text(json.dumps(summary,indent=2)+"\n",encoding="utf-8")
PY

python3 "$ROOT_DIR/scripts/audit-trial-evidence.py" "$RUN_DIR"
python3 - "$RUN_DIR/summary.json" <<'PY'
import json,sys
from pathlib import Path
d=json.loads(Path(sys.argv[1]).read_text())
print("\n=== CLAUDE BEDROCK TRIAL REPORT ===")
for key in ("repository_sha","task_tree","mode","agent","model","reasoning_effort","aws_region","harbor_exit_status","execution_class","qualification_valid","reward","tests_passed","tests_failed","tests_skipped","result_exception_types"):
    print(f"{key}={d.get(key)!r}")
print(f"failed_tests={d.get('failed_tests')!r}")
print(f"summary_json={sys.argv[1]}")
print("=== END CLAUDE BEDROCK TRIAL REPORT ===")
PY

exit "$HARBOR_STATUS"
