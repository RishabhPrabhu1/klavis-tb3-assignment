# Active Execution Plan — Deadline Mode

## Current candidate

```text
task tree: 5620526fada6eebea16910fc62bf71746aaa40ea
```

This is the representation-neutral optimistic workspace-transaction candidate. The immediately previous tree `40cbd341...` passed deterministic qualification (66/66 Oracle, 40/40 mutants, Harbor Oracle/NOP 1/0) but its valid Sol reward-0 probe exposed an unstated verifier assumption about `.workspace-cache/CURRENT`. That helper is fixed in the current tree.

No task-semantic changes should be made unless the corrected tree either fails deterministic qualification for a real task/reference defect or is cleanly solved by a valid required model trial.

## Deadline acceptance policy

The assignment requires failure, not a particular philosophical class of failure. Once the task/verifier/specification are clean, a **valid reward-0 caused by a genuine candidate implementation error** is sufficient to freeze. F1 architectural failures are stronger evidence, but a substantive F2 implementation failure also satisfies the deadline freeze gate.

Do not freeze on:

- specification ambiguity;
- verifier representation assumptions;
- auth/provider/quota issues;
- runtime/container/Harbor errors;
- invalid timeout/crash;
- suspicious reward-hacking or leaked-solution behavior.

Do not add trajectory-specific gotchas.

## Source-of-truth requirements

Current Terminal-Bench defaults:

```text
trials per agent: 3
standard agents:
  claude-code / anthropic/claude-opus-5 / reasoning=max
  codex       / openai/gpt-5.6-sol       / reasoning=xhigh
/cheat uses the same configured trial count and agents
```

Therefore final evidence target is:

```text
Standard /run:
  Codex:   3 valid reward-0
  Claude:  3 valid reward-0

Adversarial /cheat:
  Codex:   3 valid reward-0
  Claude:  3 valid reward-0
```

Every counted trial must be normally completed with no invalidating exception.

## Pipeline

### Gate 1 — Corrected-tree deterministic qualification

Run on exact task tree `5620526f...`:

- current TB3 static checks;
- Oracle/reference: expected 66/66;
- core mutants: 14/14 rejected;
- lifecycle/GC: 6/6 rejected;
- project request: 5/5 rejected;
- workspace snapshot/cross-layer: 7/7 rejected;
- workspace transaction: 8/8 rejected;
- total: 40/40 rejected;
- Harbor Oracle=1 / NOP=0 / zero frontier calls.

Primary command:

```bash
bash scripts/resume-deadline-cycle.sh
```

The resume command reuses existing same-tree evidence and refuses duplicate model launches after interruption.

### Gate 2 — One corrected-tree Codex frontier probe

The guarded frontier path attempts same-tree `/cheat` first. A provider cybersecurity block remains invalid and does not count as reward-0 evidence, but audited same-tree safety-block evidence may permit the one ordinary difficulty probe.

Run exactly one Codex GPT-5.6 Sol/xhigh standard probe.

Decision:

- valid reward 1 -> current candidate is solved; one targeted final strengthening only, then requalify;
- valid reward 0 from real candidate behavior -> freeze immediately;
- verifier/spec/infrastructure/provider issue -> repair only that issue; do not redesign architecture unnecessarily.

### Gate 3 — Frozen Codex standard matrix

After reviewer freeze approval:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

The script counts the accepted probe toward the 3 required standard failures, runs only the missing attempts, and stops on solve or invalid execution.

### Gate 4 — Claude access and standard matrix

Preferred Klavis auth is Claude Code OAuth via `claude setup-token`, but a paid Claude subscription is unavailable.

Zero-out-of-pocket fallback to test after freeze:

```text
AWS Free Tier credits -> Amazon Bedrock -> anthropic.claude-opus-5 -> Claude Code
```

Claude Code officially supports Bedrock and Bedrock exposes the required model ID `anthropic.claude-opus-5`. Final evidence must still record:

```text
agent=claude-code
model=anthropic/claude-opus-5
reasoning_effort=max
environment=docker
```

Need 3 valid standard reward-0 trials.

### Gate 5 — Final adversarial matrices

Need 3 valid reward-0 `/cheat` trials for Codex and 3 for Claude on the frozen tree.

Codex has historically hit an external OpenAI cybersecurity safety block before substantive cheat execution. Those attempts are invalid. If that continues on the frozen tree, document it exactly; do not claim compliance unless valid reward-0 trials are actually obtained or Klavis explicitly accepts the provider limitation.

### Gate 6 — Final deterministic/fresh-clone audit and documentation

Before submission:

- re-run final deterministic checks on frozen tree if time permits;
- verify exact task tree and execution commit;
- record current Terminal-Bench HEAD and Harbor 0.14.0;
- ensure results ledgers contain all valid/invalid classifications and evidence paths;
- confirm README and task-local documentation describe the frozen semantics;
- run:

```bash
bash scripts/final-submission-audit.sh
```

Expected final output:

```text
FINAL_STATUS=READY_FOR_SUBMISSION
```

## Current status

- [ ] Gate 1 — corrected `5620526f...` deterministic qualification (latest Work session was interrupted by Work's 5-hour limit; inspect/resume evidence, do not blindly rerun).
- [ ] Gate 2 — corrected-tree Codex difficulty probe.
- [ ] Gate 3 — 3/3 Codex standard failures.
- [ ] Gate 4 — establish zero-cost Claude Opus 5 route and obtain 3/3 Claude standard failures.
- [ ] Gate 5 — 3/3 Codex + 3/3 Claude adversarial reward-0 trials.
- [ ] Gate 6 — final audit/docs/fresh-clone submission check.

## Historical evidence not counted toward final matrix

- `4eaf21ae...` — valid Sol solve, 37/37.
- `42cba8ad...` — substantial near-solve but formally invalid standard run due provider quota exception.
- `17291a73...` — valid Sol solve, 58/58.
- `bff3b135...` — 65/66 Oracle because verifier conflated transaction-private history with ordinary current; no frontier call.
- `40cbd341...` — deterministically qualified; valid Sol reward-0 61/66, but five failures were masked by an unstated verifier workspace-selector pathname; not difficulty evidence.
- all provider-safety-blocked `/cheat` attempts — invalid.

## Immediate operating rule

Do not spend time reconstructing already-known state manually. Use evidence-aware scripts. Do not rerun a frontier model if a same-tree completed or incomplete attempt already exists. Preserve every valid/invalid result with exact classification.
