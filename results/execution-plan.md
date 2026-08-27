# Active Execution Plan — Deadline Mode

## Current candidate

```text
task tree: 5620526fada6eebea16910fc62bf71746aaa40ea
```

This is the representation-neutral optimistic workspace-transaction candidate. The immediately previous tree `40cbd341...` passed deterministic qualification (66/66 Oracle, 40/40 mutants, Harbor Oracle/NOP 1/0) but its valid Sol reward-0 probe exposed an unstated verifier assumption about `.workspace-cache/CURRENT`. That helper is fixed in the current tree.

No task-semantic changes should be made unless the corrected tree either fails deterministic qualification for a real task/reference defect or is cleanly solved by a valid required model trial.

## Deadline acceptance policy

Once the task/verifier/specification are clean, a **valid reward-0 caused by a genuine candidate implementation error** is sufficient to freeze. A deep architectural failure is stronger evidence, but a substantive local implementation failure also satisfies the required model-failure condition.

Do not freeze on specification ambiguity, verifier defects, provider/auth/quota issues, runtime/container errors, invalid timeout/crash, or suspicious reward-hacking/leakage behavior.

## Live source-of-truth requirements

Current Terminal-Bench behavior:

```text
Standard /run:
  3 trials × claude-code / anthropic/claude-opus-5 / max
  3 trials × codex       / openai/gpt-5.6-sol       / xhigh

Adversarial /cheat:
  1 trial × claude-code / anthropic/claude-opus-5 / max
  1 trial × codex       / openai/gpt-5.6-sol       / xhigh
```

The distinction matters: `/run` expands the shared `trials: 3` into a `(task × agent × trial)` matrix, while the live `/cheat` workflow has only `(task × agent)` and runs once per agent.

**Final frontier evidence target: 8 valid runs total.** Every counted run must complete normally with no invalidating exception.

## Pipeline

### Gate 1 — Corrected-tree deterministic qualification

Run on exact task tree `5620526f...`:

- current TB3 static checks;
- Oracle/reference: expected 66/66;
- 40/40 non-equivalent mutants rejected;
- Harbor Oracle=1 / NOP=0 / zero frontier calls.

Primary resume command:

```bash
bash scripts/resume-deadline-cycle.sh
```

The resume command reuses same-tree evidence and refuses duplicate model launches after interruption.

### Gate 2 — One corrected-tree Codex frontier probe

The guarded frontier path attempts same-tree Codex `/cheat` first, then one standard Sol/xhigh difficulty probe when allowed. A provider cybersecurity block remains invalid and cannot count as the final cheat result.

Decision:

- valid standard reward 1 -> one targeted final strengthening only, then requalify;
- valid standard reward 0 from real candidate behavior -> freeze immediately;
- verifier/spec/infrastructure/provider issue -> repair only that issue.

### Gate 3 — Frozen Codex standard matrix

After freeze:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

Counts the accepted probe toward the three required standard failures and runs only missing attempts.

### Gate 4 — Claude access, rubric, and standard matrix

Paid Claude subscription is unavailable. Zero-out-of-pocket path:

```text
AWS Free Tier/credits -> Amazon Bedrock -> Claude Code -> Opus 5
```

Prepared scripts:

```text
scripts/run-claude-bedrock-trial.sh
scripts/run-deadline-claude-bedrock-matrix.sh
scripts/run-implementation-rubric-bedrock.sh
```

If the free AWS account grants Anthropic model entitlement, the Claude matrix collector gathers **3 standard reward-0 + 1 cheat reward-0** and stops on solve or invalid execution. The rubric runner reproduces the live Claude Code `sonnet` implementation reviewer through Bedrock/Harbor 0.18.0.

### Gate 5 — Final Codex adversarial result

Live TB3 requires **one** Codex `/cheat` invocation on the frozen tree. Use:

```bash
AGENT=codex CONFIRM_FREEZE=1 bash scripts/run-required-cheat.sh
```

It must be a valid completed reward-0 run. Historical OpenAI cybersecurity safety blocks are invalid and remain the largest external compliance risk.

### Gate 6 — Rubric cleanup if current evidence is unusable

The live implementation rubric flags likely reviewer risks in the current task-local README/instruction presentation. A non-applied transformation is prepared at:

```text
scripts/apply-deadline-rubric-cleanup.sh
```

It removes the duplicative optional task README, adds a one-sentence real-world role, and rewrites one implementation-prescriptive lock sentence as an outcome-level serialization requirement. **Do not apply it until the interrupted `5620526f...` evidence is inspected**, because any task-tree change requires full requalification and new frontier evidence.

### Gate 7 — Final audit

Before submission:

- record frozen task tree, execution commit, live TB3 HEAD, Harbor versions;
- update valid/invalid trial ledgers and failure analysis;
- run final deterministic checks again if time permits;
- run:

```bash
bash scripts/final-submission-audit.sh
```

Expected:

```text
Codex standard reward-0:  3/3
Claude standard reward-0: 3/3
Codex cheat reward-0:     1/1
Claude cheat reward-0:    1/1
FINAL_STATUS=READY_FOR_SUBMISSION
```

## Current status

- [ ] Inspect/resume interrupted `5620526f...` qualification/frontier cycle without duplicate calls.
- [ ] Obtain or classify corrected-tree Sol probe.
- [ ] Freeze candidate on first legitimate standard reward-0.
- [ ] Complete 3/3 Codex standard failures.
- [ ] Establish zero-cost Bedrock access; complete implementation rubric if possible.
- [ ] Complete 3/3 Claude standard failures.
- [ ] Complete 1/1 Codex + 1/1 Claude adversarial reward-0 runs.
- [ ] Final audit/docs/submission.

## Historical evidence not counted toward final matrix

- `4eaf21ae...` — valid Sol solve, 37/37.
- `42cba8ad...` — substantial near-solve but invalid due provider quota exception.
- `17291a73...` — valid Sol solve, 58/58.
- `bff3b135...` — 65/66 Oracle due verifier current/history bug; no frontier call.
- `40cbd341...` — qualified; valid Sol reward-0 61/66, but failures were masked by an unstated verifier selector pathname; not difficulty evidence.
- provider-safety-blocked `/cheat` attempts — invalid.

## Immediate rule

Do not reconstruct known state manually and do not rerun a frontier model when same-tree completed or incomplete evidence exists. Preserve exact validity classification for every attempt.
