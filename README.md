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

The difficulty is in preserving system-wide invariants across concurrency, recovery, reclamation, and replay. Deterministic pause/fail hooks expose those boundaries without relying on uncontrolled races or hidden timing assumptions.

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
| Automated implementation rubric | **Outstanding** | [`results/implementation-rubric-review.md`](results/implementation-rubric-review.md) |
| Codex / Sol `xhigh` standard matrix | **In progress / not counted until audited** | [`results/standard-trials.md`](results/standard-trials.md) |
| Codex `/cheat` | **Outstanding** | [`results/cheat-trials.md`](results/cheat-trials.md) |
| Claude Code / Opus 5 `max` standard matrix | **Outstanding** | [`results/standard-trials.md`](results/standard-trials.md) |
| Claude `/cheat` | **Outstanding** | [`results/cheat-trials.md`](results/cheat-trials.md) |

The deterministic qualification itself made **zero frontier-model calls**. An in-progress or unaudited model invocation is never represented as completed evidence.

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

The reviewer-facing evidence is intentionally separated by purpose:

- [`results/validation.md`](results/validation.md) — frozen-tree deterministic qualification and verifier hardening summary.
- [`results/preflight-status.json`](results/preflight-status.json) — machine-readable qualification record.
- [`results/contract-coverage.md`](results/contract-coverage.md) — instruction-to-verifier traceability and representation-neutrality audit.
- [`results/implementation-rubric-review.md`](results/implementation-rubric-review.md) — implementation-rubric analysis and automated-gate status.
- [`results/standard-trials.md`](results/standard-trials.md) — required standard `/run` matrix.
- [`results/cheat-trials.md`](results/cheat-trials.md) — required adversarial `/cheat` matrix.
- [`results/failure-analysis.md`](results/failure-analysis.md) — model-failure validity rules and per-trial analysis.
- [`results/environment.md`](results/environment.md) — pinned versions, auth modes, and evaluation environment.
- [`results/submission-checklist.md`](results/submission-checklist.md) — final delivery/access/evidence checklist.

Raw local Harbor evidence is stored outside the repository under `~/.cache/klavis-tb3-runs/` and keyed by repository/task/upstream identities. Submission-facing summaries contain the exact evidence paths and classifications after each accepted run.

## Reproducing deterministic qualification

A full exact-tree rerun is available with:

```bash
bash scripts/run-final-tree-deadline-qualification.sh
```

The recorded frozen-tree successor qualification can be reproduced with:

```bash
bash scripts/run-fast-final-successor-qualification.sh
```

Both paths are zero-frontier-model qualification gates.

## Trial tooling

The authoritative generic trial runner is:

```bash
bash scripts/run-candidate-trial.sh
```

It records repository SHA, task tree, model, reasoning level, Harbor version, auth mode, and raw result locations, then `scripts/audit-trial-evidence.py` reclassifies standard-trial validity from authoritative Harbor `result.json` state rather than relying on console text alone.

Matrix wrappers are provided for the final Codex, Claude, and adversarial runs. These scripts preserve the frozen task tree and fail closed on inconsistent evidence.

## Historical calibration

Historical model runs are retained because they document task iteration, but are explicitly excluded from the final matrix.

The strongest superseded calibration tree, `fc064cac2fb1241b68a98475dbc8ea04fbe579cc`, produced a clean GPT-5.6 Sol/xhigh reward-0 trial with `45 passed / 21 failed`. Later verifier/schema/process corrections superseded that tree, so the result demonstrates difficulty only. Earlier solved and verifier-defect trees are documented in [`results/failure-analysis.md`](results/failure-analysis.md).

## Final acceptance

The repository includes a strict final audit:

```bash
bash scripts/final-submission-audit.sh
```

That script reports full TB3 submission readiness only when the exact frozen task has the required deterministic qualification, same-tree automated implementation-rubric PASS, complete valid standard matrices, and reward-0 adversarial entries. Until those conditions are met, the repository documents the remaining gaps rather than representing them as passed.
