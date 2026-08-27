#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TREE=$(git -C "$ROOT_DIR" rev-parse HEAD:tasks/build-snapshot-publish)
TB3=${TB3_HEAD_EXPECTED:-79e71650f5b6a6ef5bb46a434c7c04d7d99a9480}

count_standard() {
  local roots=$1 agent=$2 model=$3 reasoning=$4
  python3 - "$TREE" "$roots" "$agent" "$model" "$reasoning" <<'PY'
import json,sys
from pathlib import Path
tree,roots,agent,model,reasoning=sys.argv[1:]; n=0; seen=set()
for raw in roots.split(':'):
 p=Path(raw).expanduser()
 if not p.exists(): continue
 for f in p.rglob('summary.json'):
  k=str(f.resolve())
  if k in seen: continue
  seen.add(k)
  try:d=json.loads(f.read_text())
  except Exception:continue
  if (d.get('task_tree')==tree and d.get('mode')=='standard' and d.get('agent')==agent
      and d.get('model')==model and d.get('reasoning_effort')==reasoning
      and d.get('execution_class')=='valid-completed-trial' and d.get('qualification_valid') is True
      and not (d.get('result_exception_types') or []) and d.get('reward') in (0,0.0)):
   n+=1
print(n)
PY
}
count_cheat() {
  local roots=$1 agent=$2 model=$3 reasoning=$4
  python3 - "$TREE" "$roots" "$agent" "$model" "$reasoning" "$TB3" <<'PY'
import json,sys
from pathlib import Path
tree,roots,agent,model,reasoning,tb3=sys.argv[1:]; n=0; seen=set()
for raw in roots.split(':'):
 p=Path(raw).expanduser()
 if not p.exists(): continue
 for f in p.rglob('summary.json'):
  k=str(f.resolve())
  if k in seen: continue
  seen.add(k)
  try:d=json.loads(f.read_text())
  except Exception:continue
  if not (d.get('task_tree')==tree and d.get('mode')=='cheat' and d.get('agent')==agent and d.get('model')==model and d.get('reasoning_effort')==reasoning and d.get('terminal_bench_head')==tb3): continue
  status=d.get('harbor_exit_status'); reward=d.get('reward')
  if status not in (None,0) or reward in (0,0.0): n+=1
print(n)
PY
}

qual="$HOME/.cache/klavis-tb3-runs/transaction-preflight/QUALIFICATION-PASSED-${TREE}.txt"
rubric=$(python3 - "$TREE" "$TB3" <<'PY'
import json,sys
from pathlib import Path
tree,tb3=sys.argv[1:]; root=Path.home()/'.cache/klavis-tb3-runs/implementation-rubric'; ok=False
if root.exists():
 for p in root.rglob('result.json'):
  try:d=json.loads(p.read_text())
  except Exception:continue
  if d.get('task_tree')==tree and d.get('terminal_bench_head')==tb3 and d.get('passed') is True and not (d.get('failed') or []): ok=True
print('PASS' if ok else 'MISSING')
PY
)

codex_std=$(count_standard "$HOME/.cache/klavis-tb3-runs/transaction-standard-probe:$HOME/.cache/klavis-tb3-runs/transaction-standard-final" codex openai/gpt-5.6-sol xhigh)
claude_std=$(count_standard "$HOME/.cache/klavis-tb3-runs/transaction-claude-standard:$HOME/.cache/klavis-tb3-runs/transaction-claude-standard-final" claude-code anthropic/claude-opus-5 max)
codex_cheat=$(count_cheat "$HOME/.cache/klavis-tb3-runs/transaction-cheat:$HOME/.cache/klavis-tb3-runs/transaction-cheat-final" codex openai/gpt-5.6-sol xhigh)
claude_cheat=$(count_cheat "$HOME/.cache/klavis-tb3-runs/transaction-claude-cheat" claude-code anthropic/claude-opus-5 max)

printf '=== DEADLINE STATUS ===\n'
printf 'commit=%s\n' "$(git -C "$ROOT_DIR" rev-parse HEAD)"
printf 'task_tree=%s\n' "$TREE"
printf 'qualification=%s\n' "$([[ -f "$qual" ]] && echo PASS || echo MISSING)"
printf 'implementation_rubric=%s\n' "$rubric"
printf 'codex_standard=%s/3\n' "$codex_std"
printf 'codex_cheat=%s/1\n' "$codex_cheat"
printf 'claude_standard=%s/3\n' "$claude_std"
printf 'claude_cheat=%s/1\n' "$claude_cheat"
printf 'claude_oauth=%s\n' "$([[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]] && echo PRESENT || echo absent)"
printf 'bedrock_bearer=%s\n' "$([[ -n "${AWS_BEARER_TOKEN_BEDROCK:-}" ]] && echo PRESENT || echo absent)"
printf 'bedrock_keys=%s\n' "$([[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" ]] && echo PRESENT || echo absent)"
printf 'aws_profile=%s\n' "${AWS_PROFILE:-absent}"
printf '=== END DEADLINE STATUS ===\n'
