# Active Execution Plan — Deadline Mode

## Current candidate

```text
task tree: 85eb3be3ce69a625a06eab3e37c69badbab89779
```

This is the frozen rubric-corrected optimistic workspace-transaction candidate. Starter and reference implementation are unchanged from the difficulty-proven `fc064cac...` predecessor. The successor removes hidden verifier representation assumptions and hardens process isolation; it does not add more runtime difficulty.

## Deadline acceptance policy

Difficulty strengthening is finished. The predecessor produced a clean Sol/xhigh standard reward-0 with 45 passed / 21 failed, showing that the runtime task is already hard enough.

For the final exact tree:

- a valid standard reward-0 caused by genuine candidate behavior is sufficient to freeze;
- reward 1 means the tree does not satisfy the required standard-failure matrix;
- specification/verifier defects require a narrow repair and requalification;
- provider/auth/quota/container/timeout/other infrastructure failures do not count for standard `/run`.

## Live source-of-truth requirements

```text
Standard /run:
  3 × codex       / openai/gpt-5.6-sol       / xhigh
  3 × claude-code / anthropic/claude-opus-5 / max

Adversarial /cheat:
  1 × codex       / openai/gpt-5.6-sol       / xhigh
  1 × claude-code / anthropic/claude-opus-5 / max
```

Standard runs must be genuine clean model failures. `/cheat` follows the live TB3 reward-only behavior: any nonzero adversarial reward fails; the workflow records reward 0 if `harbor run` itself exits nonzero.

## Gate 1 — Exact-tree deterministic qualification

On the current exact tree, require:

```text
TB3 static checks:       PASS
Oracle/reference:        66/66
core mutants:            14/14 rejected
lifecycle/GC mutants:    6/6 rejected
project-request mutants: 5/5 rejected
workspace mutants:       7/7 rejected
transaction mutants:     8/8 rejected
Harbor Oracle:           1
Harbor NOP:              0
frontier calls:          0
```

Primary command after checking out the current branch head:

```bash
bash scripts/run-final-tree-deadline-qualification.sh
```

This final qualifier reruns all deterministic families on the exact tree; it does not inherit old mutation evidence.

## Gate 2 — Implementation-rubric review

The predecessor Work reviews found real blockers; they have been corrected in the frozen tree. Current source-level assessment is `BORDERLINE -> LIKELY PASS`, with instruction length and best-case expert scope the principal subjective risks.

Do not claim the implementation rubric passed until the live review on the exact tree returns zero failed criteria.

If a zero-cost live reviewer route is not immediately available, a read-only exact-tree Work review is still useful as a negative control, but it is not a substitute for the required automated rubric result.

## Gate 3 — One exact-tree Sol probe

After exact-tree qualification and no known concrete rubric defect remains:

```bash
bash scripts/run-one-qualified-sol-probe.sh
```

The runner refuses duplicate/incomplete same-tree evidence.

Decision:

- valid reward 0 from candidate implementation -> freeze exact tree immediately;
- valid reward 1 -> do not reinterpret as failure;
- invalid/provider/infrastructure result -> preserve as invalid and diagnose before any rerun;
- F3/F4 -> repair only the task/verifier defect and requalify.

## Gate 4 — Frozen Codex standard matrix

After freeze:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

The accepted first probe counts if it is on the final exact tree. The runner launches only enough additional clean failures to reach 3/3 and stops on solve or invalid execution.

## Gate 5 — Codex adversarial run

After freeze:

```bash
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 \
bash scripts/run-deadline-cheat-matrix.sh
```

Require recorded adversarial reward 0. A safety refusal can satisfy this reward condition under the live TB3 `/cheat` workflow; a nonzero reward cannot.

## Gate 6 — Claude / Opus 5

Required identity remains:

```text
agent:     claude-code
model:     anthropic/claude-opus-5
reasoning: max
```

The user cannot spend money. Do not fall back to direct Anthropic pay-as-you-go or require a paid Claude subscription.

Repository tooling supports Bedrock and includes:

```text
scripts/smoke-test-claude-bedrock.sh
scripts/run-deadline-claude-pipeline.sh
```

The pipeline is deliberately guarded against silent direct-Anthropic fallback. Ordinary AWS Free Tier credits should not be assumed to cover third-party Anthropic Marketplace usage; eligible existing AWS Activate/organization/provider credit or another genuinely zero-out-of-pocket entitlement is required.

If eligible Bedrock access exists, the pipeline performs bounded model entitlement checking, implementation-rubric reuse/run as appropriate, 3 clean Opus standard failures, 1 reward-0 Opus adversarial run, then the final audit.

If no zero-cost Opus entitlement is available before the deadline, complete every non-Claude requirement and document the provider-access blocker for Klavis rather than incurring cost.

## Gate 7 — Final audit and submission records

Before submission:

```bash
bash scripts/final-submission-audit.sh
```

Expected final state:

```text
same-tree qualification:          PASS
same-tree implementation rubric:  PASS
Codex standard reward-0:           3/3 clean
Claude standard reward-0:          3/3 clean
Codex cheat reward-0:              1/1
Claude cheat reward-0:             1/1
FINAL_STATUS=READY_FOR_SUBMISSION
```

Update `results/preflight-status.json`, `standard-trials.md`, `cheat-trials.md`, and `failure-analysis.md` with exact evidence directories and execution commit before submission.

## Current status

- [ ] Exact-tree qualification for `85eb3be3...`.
- [ ] Exact-tree implementation-rubric acceptance.
- [ ] One exact-tree Sol probe.
- [ ] Freeze on first legitimate final-tree standard reward-0.
- [ ] Complete 3/3 Sol standard failures.
- [ ] Complete 1/1 Codex adversarial reward-0.
- [ ] Establish genuinely zero-cost Opus 5 access or document external blocker.
- [ ] Complete 3/3 Opus standard failures.
- [ ] Complete 1/1 Opus adversarial reward-0.
- [ ] Final audit and submission.

## Historical evidence not counted toward final matrix

- `17291a73...` — valid Sol solve, 58/58.
- `40cbd341...` — Sol reward-0 masked by hidden workspace-selector verifier assumption; F4.
- `fc064cac...` — deterministically qualified and valid Sol/xhigh reward-0, 45/66; genuine difficulty calibration but superseded by rubric/verifier corrections.
- `d7d7adf...` and `316aaf...` — deterministic/rubric-hygiene predecessors; useful regression evidence only.

## Operational rule

Never rerun a frontier model blindly. Check for same-tree complete or incomplete evidence first. Keep local Mac execution and Work execution in separate worktrees/processes, and do not interrupt a running model or qualification task merely to adopt scripts-only repository updates.
