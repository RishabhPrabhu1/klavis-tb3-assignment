# Build Snapshot Publication

Original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Submission status

Deterministic qualification is complete on the frozen task tree. The controllable Codex evaluation is also complete: **3/3 valid GPT-5.6 Sol / `xhigh` standard reward-0 failures** and **1/1 Codex `/cheat` reward-0 entry**.

The submission does **not** claim full Terminal-Bench 3 compliance because the Claude-dependent automated implementation rubric, three Claude Code / Opus 5 standard trials, and Claude `/cheat` entry could not be executed without usable Claude access. Those required rows remain explicit rather than being replaced with alternate-model or provider-failure results.

## Overview

`tasks/build-snapshot-publish/` asks an agent to repair an incremental build system that must correctly compose:

- incremental cache invalidation;
- crash-consistent project publication;
- exactly-once request replay;
- concurrent readers, builds, and garbage collection;
- cross-project workspace snapshots;
- optimistic atomic multi-project workspace write transactions.

The difficulty is preserving system-wide invariants across concurrency, recovery, reclamation, and replay. Deterministic pause/fail hooks expose those boundaries without relying on uncontrolled races or hidden timing assumptions.

## Repository layout

```text
tasks/build-snapshot-publish/  Terminal-Bench task, environment, solution, and verifier
results/                       qualification, evaluation, and failure-analysis evidence
scripts/                       reproducible validation and evaluation tooling
.github/workflows/             read-only submission consistency CI
```

## Frozen task

The submission task tree is:

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

This task-tree hash is the canonical identity for evaluation evidence. Model results from other task trees are historical calibration only and do not count toward the final matrix.

The frozen tree differs from its fully-qualified predecessor only by verifier teardown/process-reaping hygiene in `tests/conftest.py`; task instructions, starter behavior, reference semantics, and the graded contract are unchanged.

## Current validation status

| Requirement | Status | Evidence |
|---|---|---|
| Current TB3 static checks | **PASS** | [`results/validation.md`](results/validation.md) |
| Reference verifier | **68/68 PASS** | [`results/preflight-status.json`](results/preflight-status.json) |
| Harbor 0.14 Oracle | **1.000** | [`results/preflight-status.json`](results/preflight-status.json) |
| Harbor 0.14 NOP | **0.000** | [`results/preflight-status.json`](results/preflight-status.json) |
| Development mutation controls | **40/40 rejected on fully-qualified predecessor** | [`results/contract-coverage.md`](results/contract-coverage.md) |
| Automated implementation rubric | **NOT RUN — Claude access unavailable** | [`results/implementation-rubric-review.md`](results/implementation-rubric-review.md) |
| Codex / Sol `xhigh` standard matrix | **3/3 COMPLETE** | [`results/standard-trials.md`](results/standard-trials.md) |
| Codex `/cheat` | **1/1 COMPLETE — reward 0** | [`results/cheat-trials.md`](results/cheat-trials.md) |
| Claude Code / Opus 5 `max` standard matrix | **NOT RUN — Claude access unavailable** | [`results/standard-trials.md`](results/standard-trials.md) |
| Claude `/cheat` | **NOT RUN — Claude access unavailable** | [`results/cheat-trials.md`](results/cheat-trials.md) |

The deterministic qualification itself made **zero model calls**. The three counted Codex standard runs completed on the exact frozen task tree with verifier outcomes `62 passed / 6 failed`, `64 / 4`, and `54 / 14`; all had Harbor exit status `0`, authoritative reward `0.0`, and no standard-trial exceptions.

The Codex adversarial run used the same frozen task tree, `openai/gpt-5.6-sol`, `xhigh`, and pinned Terminal-Bench revision `79e71650...`; the collector recorded `reward_zero=1`, `target=1`, and `status=CHEAT_MATRIX_COMPLETE`.

## Claude access limitation

The current Terminal-Bench configuration requires Claude Code for the automated implementation-rubric review and requires Claude Code / Opus 5 for three standard trials plus one adversarial `/cheat` entry. Those Claude-dependent requirements were **not executed in this submission** because no Claude Code subscription or other usable Claude provider route is available in the submission environment.

This is an explicit submission limitation, not a claimed pass. No substitute model result, failed authentication attempt, or provider error is counted as Claude evidence. The repository keeps the required Claude rows visible and marks them incomplete so a reviewer can distinguish completed validation from unavailable provider-dependent evaluation.

## Evaluation configuration

The repository is pinned to Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

At that source-of-truth snapshot, the required evaluation matrix is:

| Mode | Agent | Model | Reasoning | Required result |
|---|---|---|---|---|
| `/run` | Codex | `openai/gpt-5.6-sol` | `xhigh` | 3 genuine verifier failures |
| `/run` | Claude Code | `anthropic/claude-opus-5` | `max` | 3 genuine verifier failures |
| `/cheat` | Codex | `openai/gpt-5.6-sol` | `xhigh` | reward 0 |
| `/cheat` | Claude Code | `anthropic/claude-opus-5` | `max` | reward 0 |

For standard `/run` trials, provider/auth/quota errors, crashes, timeouts, container failures, verifier failures, or other infrastructure errors do **not** count as model failures. A trial is counted only after its Harbor evidence is reviewed and the reward-0 outcome is attributable to the candidate implementation.

For `/cheat`, acceptance follows the pinned live TB3 workflow: every required task × agent entry must receive reward `0`; any nonzero reward fails the adversarial requirement.

## Evidence map

- [`results/validation.md`](results/validation.md) — frozen-tree deterministic qualification and current evaluation status.
- [`results/preflight-status.json`](results/preflight-status.json) — machine-readable qualification record.
- [`results/contract-coverage.md`](results/contract-coverage.md) — instruction-to-verifier traceability and representation-neutrality audit.
- [`results/implementation-rubric-review.md`](results/implementation-rubric-review.md) — source-level rubric assessment and the missing Claude-dependent automated check.
- [`results/standard-trials.md`](results/standard-trials.md) — required standard `/run` matrix and all three counted Codex runs.
- [`results/cheat-trials.md`](results/cheat-trials.md) — adversarial matrix and counted Codex reward-0 result.
- [`results/failure-analysis.md`](results/failure-analysis.md) — validity rules and per-trial failure analysis.
- [`results/environment.md`](results/environment.md) — pinned versions, provider availability, and evaluation environment.

Raw local Harbor evidence is stored outside the repository under `~/.cache/klavis-tb3-runs/` and keyed by repository/task/upstream identities. Submission-facing summaries contain the exact evidence paths and classifications after each accepted run.

## Reproducing deterministic qualification

```bash
bash scripts/run-qualification.sh
```

This path runs static checks, the 68-test reference verifier, mutation controls, and exact-tree Harbor Oracle/NOP without model calls.

## Trial tooling

The generic trial runner is `scripts/run-candidate-trial.sh`; `scripts/audit-trial-evidence.py` validates standard-trial evidence from authoritative Harbor `result.json` state. Matrix collectors are:

```text
scripts/run-codex-standard-matrix.sh
scripts/run-claude-standard-matrix.sh
scripts/run-cheat-matrix.sh
```

They preserve the frozen task tree and fail closed on inconsistent evidence. Claude tooling remains reproducible in the repository, but no Claude result is represented as executed without actual provider access.

## Final acceptance

The repository includes a strict final audit:

```bash
bash scripts/final-submission-audit.sh
```

That script reports full TB3 submission readiness only when the exact frozen task has deterministic qualification, same-tree automated implementation-rubric PASS, complete valid standard matrices, and reward-0 adversarial entries.

Because the Claude-dependent requirements were not run, the final strict audit is expected to remain **not fully ready** despite completion of all controllable Codex evidence. The submission preserves that truthful partial status rather than weakening the audit or claiming full TB3 compliance.
