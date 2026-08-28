# Submission Execution Plan

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

The task is frozen. `tasks/build-snapshot-publish/` must not change unless a concrete specification or verifier defect is demonstrated. Any task-tree change invalidates same-tree model evidence and requires requalification.

## Validated baseline

| Check | Status |
|---|---|
| Current TB3 static checks | PASS |
| Reference verifier | 68/68 PASS |
| Harbor 0.14 Oracle | 1.000 |
| Harbor 0.14 NOP | 0.000 |
| Frontier calls during deterministic qualification | 0 |
| Predecessor mutation controls | 40/40 rejected |

The mutation evidence belongs to fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1`. The frozen successor differs only in verifier teardown/process-reaping hygiene in `tests/conftest.py`, then reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP.

Machine-readable qualification evidence is in `results/preflight-status.json`.

## Required evaluation matrix

```text
Standard /run:
  3 × codex       / openai/gpt-5.6-sol       / xhigh
  3 × claude-code / anthropic/claude-opus-5 / max

Adversarial /cheat:
  1 × codex       / openai/gpt-5.6-sol       / xhigh
  1 × claude-code / anthropic/claude-opus-5 / max
```

Standard runs count only when Harbor and the verifier complete normally and reward `0` is caused by candidate behavior. Authentication, quota, provider, container, timeout, Harbor, verifier, or other infrastructure failures do not count as model failures.

Adversarial runs follow the pinned live TB3 reward rule: every required task × agent entry must receive reward `0`.

## Current execution state

- Deterministic qualification: **complete**.
- Codex standard matrix: **1/3 counted**. Trial 1 completed in 32m46s with authoritative reward `0.0`, no result exceptions, and `62 passed / 6 failed`; the failures were reviewed as genuine candidate-behavior failures.
- Codex standard trials 2–3: **remaining**.
- Codex `/cheat`: **remaining after standard matrix**.
- Automated implementation rubric: **NOT RUN — Claude access unavailable**.
- Claude Code / Opus 5 standard trials 1–3: **NOT RUN — Claude access unavailable**.
- Claude Code / Opus 5 `/cheat`: **NOT RUN — Claude access unavailable**.

## Claude-dependent submission limitation

The current submission environment has no Claude Code subscription and no usable Anthropic API or Bedrock route. The Claude-dependent requirements are therefore not scheduled for this submission. They remain required by TB3 and remain visibly incomplete in the repository.

No alternate model, provider/authentication error, or manual source review will be substituted for those missing results. The submission email will disclose that the automated implementation rubric, three Claude standard trials, and Claude adversarial entry could not be executed because required Claude access was unavailable.

## Codex completion path

For each standard run, use the exact frozen task tree and required configuration:

```text
agent:       codex
model:       openai/gpt-5.6-sol
reasoning:   xhigh
environment: docker
Harbor:      0.14.0
```

After each invocation:

1. Preserve the raw Harbor output.
2. Run `scripts/audit-trial-evidence.py` against its evidence directory.
3. Require `execution_class = valid-completed-trial`, `qualification_valid = true`, no result exceptions, and authoritative reward `0`.
4. Inspect failed tests and implementation behavior to ensure the failure is genuine rather than a specification/verifier defect.
5. Only then insert the run into `results/standard-trials.md` and `results/failure-analysis.md`.

Trial 1 has completed this process successfully. The remaining Codex standard runs are collected with:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

The Codex adversarial entry is then collected with:

```bash
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 \
bash scripts/run-deadline-cheat-matrix.sh
```

## Claude-dependent routes retained for reproducibility

Required Claude standard configuration:

```text
agent:     claude-code
model:     anthropic/claude-opus-5
reasoning: max
```

The repository retains prepared OAuth and Bedrock runners so the intended execution path is auditable, but no Claude result is represented as complete without an actual same-tree run. In the current submission environment those routes are unavailable.

The automated implementation rubric likewise remains incomplete because the current TB3 reviewer uses Claude Code / Sonnet.

## Final evidence update

Before delivery, every completed Codex run must record:

- execution commit;
- frozen task tree;
- agent/model/reasoning;
- Harbor and Terminal-Bench provenance where applicable;
- evidence directory;
- authoritative reward;
- exception state;
- verifier pass/fail counts;
- failed tests;
- failure classification;
- whether the run counts toward the required matrix.

The repository's final audit is:

```bash
bash scripts/final-submission-audit.sh
```

`FINAL_STATUS=READY_FOR_SUBMISSION` is reserved for full TB3 compliance. Because the Claude-dependent requirements are not being run, the strict audit is expected to remain not fully ready. That partial state must be preserved and disclosed rather than weakening the audit.

## Historical calibration

Historical trees are retained only to document iteration. They do not fill final matrix slots.

The superseded calibration tree `fc064cac2fb1241b68a98475dbc8ea04fbe579cc` produced a valid Sol/xhigh reward-0 result with `45 passed / 21 failed`. Later verifier/schema/process corrections changed the task tree, so that run is difficulty evidence only.