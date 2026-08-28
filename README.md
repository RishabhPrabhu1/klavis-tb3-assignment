# Build Snapshot Publication

Original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

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
| Codex / Sol `xhigh` standard matrix | **1/3 counted; 2 remaining** | [`results/standard-trials.md`](results/standard-trials.md) |
| Codex `/cheat` | **Outstanding** | [`results/cheat-trials.md`](results/cheat-trials.md) |
| Claude Code / Opus 5 `max` standard matrix | **NOT RUN — Claude access unavailable** | [`results/standard-trials.md`](results/standard-trials.md) |
| Claude `/cheat` | **NOT RUN — Claude access unavailable** | [`results/cheat-trials.md`](results/cheat-trials.md) |

The deterministic qualification itself made **zero frontier-model calls**. Model evidence is represented as complete only after Harbor result evidence is audited and the failure cause is reviewed.

## Claude access limitation

The current Terminal-Bench configuration requires Claude Code for the automated implementation-rubric review and requires Claude Code / Opus 5 for three standard trials plus one adversarial `/cheat` entry. Those Claude-dependent requirements are **not being executed in this submission** because no Claude Code subscription or other usable Claude provider route is available in the submission environment.

This is an explicit submission limitation, not a claimed pass. No substitute model result, failed authentication attempt, or provider error is counted as Claude evidence. The repository keeps the required Claude rows visible and marks them incomplete so a reviewer can distinguish completed validation from unavailable provider-dependent evaluation.

## Evaluation configuration

The repository is pinned to Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

At that source-of-truth snapshot, the required frontier matrix is:

| Mode | Agent | Model | Reasoning | Required result |
|---|---|---|---|---|
| `/run` | Codex | `openai/gpt-5.6-sol` | `xhigh` | 3 genuine verifier failures |
| `/run` | Claude Code | `anthropic/claude-opus-5` | `max` | 3 genuine verifier failures |
| `/cheat` | Codex | `openai/gpt-5.6-sol` | `xhigh` | reward 0 |
| `/cheat` | Claude Code | `anthropic/claude-opus-5` | `max` | reward 0 |

For standard `/run` trials, provider/auth/quota errors, crashes, timeouts, container failures, verifier failures, or other infrastructure errors do **not** count as model failures. A trial is counted only after its Harbor `result.json` evidence is audited and the reward-0 outcome is attributable to the candidate implementation.

For `/cheat`, acceptance follows the pinned live TB3 workflow: every required task × agent entry must receive reward `0`; any nonzero reward fails the adversarial requirement.

## Evidence map

- [`results/validation.md`](results/validation.md) — frozen-tree deterministic qualification and verifier-hardening summary.
- [`results/preflight-status.json`](results/preflight-status.json) — machine-readable qualification record.
- [`results/contract-coverage.md`](results/contract-coverage.md) — instruction-to-verifier traceability and representation-neutrality audit.
- [`results/implementation-rubric-review.md`](results/implementation-rubric-review.md) — source-level rubric assessment and the missing Claude-dependent automated check.
- [`results/standard-trials.md`](results/standard-trials.md) — required standard `/run` matrix and counted Codex evidence.
- [`results/cheat-trials.md`](results/cheat-trials.md) — required adversarial `/cheat` matrix.
- [`results/failure-analysis.md`](results/failure-analysis.md) — model-failure validity rules, historical calibration, and per-trial analysis.
- [`results/environment.md`](results/environment.md) — pinned versions, provider availability, and evaluation environment.

Raw local Harbor evidence is stored outside the repository under `~/.cache/klavis-tb3-runs/` and keyed by repository/task/upstream identities. Submission-facing summaries contain the exact evidence paths and classifications after each accepted run.

## Reproducing deterministic qualification

A complete exact-tree deterministic qualification is available with:

```bash
bash scripts/run-qualification.sh
```

This path runs static checks, the 68-test reference verifier, mutation controls, and exact-tree Harbor Oracle/NOP without frontier-model calls.

## Trial tooling

The generic trial runner is:

```bash
bash scripts/run-candidate-trial.sh
```

It records repository SHA, task tree, model, reasoning level, Harbor version, auth mode, and raw result locations. `scripts/audit-trial-evidence.py` then reclassifies standard-trial validity from authoritative Harbor `result.json` state rather than relying on console text alone.

The matrix collectors are:

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

That script reports full TB3 submission readiness only when the exact frozen task has the required deterministic qualification, same-tree automated implementation-rubric PASS, complete valid standard matrices, and reward-0 adversarial entries.

Because the Claude-dependent requirements are not being run without Claude access, the final strict audit is expected to remain **not fully ready** even after the remaining Codex evidence is complete. The submission preserves that truthful partial status rather than weakening the audit or claiming full TB3 compliance.
