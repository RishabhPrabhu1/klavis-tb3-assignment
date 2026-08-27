# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` is an incremental build-system repair task combining:

- crash-safe immutable project generations and atomic publication;
- concurrent incremental builds with stable input views and reusable-cache merging;
- reader/writer lifecycle, bounded GC, and object reclamation;
- exactly-once project request IDs across duplicate concurrency, owner death, response loss, later publication, and GC;
- linearizable cross-project workspace snapshots;
- optimistic atomic multi-project `workspace-build` transactions.

The transaction crux is composition rather than a hidden representation requirement. Expensive member evaluation occurs privately without globally serializing publication. Commit then validates workspace-member versions, ordinary project-current versions, manifests, and exact source observations. Disjoint transactions must progress and merge latest state; overlapping or stale transactions retry. Transaction-private project generations do not move ordinary project current, and exactly-once replay must survive later replacement and both workspace/project reclamation.

Deterministic failpoints and pausepoints expose crash/concurrency boundaries without wall-clock races.

## Current candidate

Current qualified task tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

The final reviewer-facing cleanup that produced this tree changed only task README/instruction/metadata presentation; runtime tests and the reference implementation remained unchanged. The exact tree has now been requalified from scratch.

Deterministic qualification:

```text
TB3 static checks: PASS
Oracle/reference:  66/66
mutations:         40/40 rejected
Harbor Oracle:     1.000
Harbor NOP:        0.000
frontier calls:    0 during qualification
```

Evidence:

```text
~/.cache/klavis-tb3-runs/transaction-preflight/20260827T213154Z-d2837bf220bd
```

## Historical calibration

- `4eaf21ae9456395fb080be497852c0ff9623b8fa` — generation-publication design, cleanly solved by GPT-5.6 Sol/xhigh.
- `42cba8ad00bebf316048d1470033c1742a20ec97` — exactly-once redesign; substantive Sol run reached 48/48 but was formally invalid due provider/subscription exception.
- `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` — workspace-snapshot redesign; deterministically qualified then cleanly solved by Sol, 58/58, reward 1.
- `40cbd34104e1f0a549be23b46ef70655b728cece` — first optimistic transaction tree; valid Sol reward-0 was masked by an unstated `.workspace-cache/CURRENT` verifier assumption, so it did not count.
- `5620526fada6eebea16910fc62bf71746aaa40ea` — representation-neutral transaction tree, superseded before final evidence for implementation-rubric presentation cleanup.
- `fc064cac2fb1241b68a98475dbc8ea04fbe579cc` — current qualified candidate.

## Repository structure

```text
tasks/build-snapshot-publish/   TB3 task, starter, reference solution, verifier
scripts/                        qualification, trial, audit, resume, and deadline runners
results/                        validation state, trial records, coverage, failure analysis
```

## Source of truth and qualification

Current Terminal-Bench source-of-truth commit used for final evidence:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

The deterministic qualifier runs current static checks, the full Oracle/reference verifier, 40 non-equivalent development mutations, and Harbor Oracle/NOP with zero frontier calls:

```bash
bash scripts/run-next-qualification-step.sh
```

The implementation autoreview is a separate required gate. `scripts/run-implementation-rubric-bedrock.sh` mirrors the live review shape for the planned zero-spend Bedrock route and records exact-tree/upstream provenance.

## Frontier requirements

Klavis states that the current TB3 CI/review automation is the source of truth for trial count and `/run`/`/cheat` behavior. At the pinned upstream commit, standard `/run` uses three trials per agent, while Docker `/cheat` uses one matrix entry per `(task × agent_config)` with no trial dimension.

| Mode | Agent | Model | Reasoning | Required valid reward-0 trials |
|---|---|---|---|---:|
| standard `/run` | Codex | `openai/gpt-5.6-sol` | xhigh | 3 |
| standard `/run` | Claude Code | `anthropic/claude-opus-5` | max | 3 |
| adversarial `/cheat` | Codex | `openai/gpt-5.6-sol` | xhigh | 1 |
| adversarial `/cheat` | Claude Code | `anthropic/claude-opus-5` | max | 1 |

Candidate trials use Harbor 0.14.0 and Docker, matching the Klavis sample commands. Auth/quota/provider-safety/timeouts/container failures do not count. `result.json` exception state and verifier reward are authoritative through `scripts/audit-trial-evidence.py`.

## Deadline workflow

On macOS Bash 3.2, resume the qualified candidate without re-running deterministic qualification using:

```bash
bash scripts/resume-macos-deadline-cycle.sh
```

Once a valid same-tree reward-0 standard probe is reviewed as a real task-caused model failure, collect the remaining standard matrices with:

```bash
CONFIRM_FREEZE=1 AGENT=codex  MODE=standard MAX_PARALLEL=2 bash scripts/run-parallel-final-matrix.sh
CONFIRM_FREEZE=1 AGENT=claude MODE=standard MAX_PARALLEL=2 bash scripts/run-parallel-final-matrix.sh
```

The adversarial requirement is one valid reward-0 run per agent. If using the generic matrix runner, set the explicit target to one:

```bash
CONFIRM_FREEZE=1 TARGET_VALID_ZEROES=1 AGENT=codex  MODE=cheat MAX_PARALLEL=1 bash scripts/run-parallel-final-matrix.sh
CONFIRM_FREEZE=1 TARGET_VALID_ZEROES=1 AGENT=claude MODE=cheat MAX_PARALLEL=1 bash scripts/run-parallel-final-matrix.sh
```

Each batch stops if a launched run is invalid, incomplete, or nonzero reward.

## Claude access

Klavis's sample uses Claude Code OAuth. For a zero-out-of-pocket path, Claude Code and Harbor also support Amazon Bedrock while preserving the required Claude Code agent, Opus 5 model, max reasoning, Docker environment, and Harbor evidence. The generic trial runner accepts a Bedrock bearer credential or ordinary AWS credentials. If AWS Free Tier does not permit Opus 5 without a paid upgrade, that route must stop rather than incur cost.

## Evidence policy

A model result counts only if:

- it is on the exact qualified/frozen task tree;
- execution finishes without provider/auth/quota/timeout/container/Harbor contamination;
- authoritative Harbor `result.json` contains no invalidating exception;
- its authoritative verifier reward is unambiguous;
- verifier execution completes normally;
- a standard failure is caused by candidate behavior under a clear contract rather than a specification/verifier defect.

The final audit is intentionally strict:

```bash
bash scripts/final-submission-audit.sh
```

It refuses `READY_FOR_SUBMISSION` unless the exact tree has zero-model qualification, implementation-rubric PASS, three valid reward-0 standard trials per required agent, one valid reward-0 adversarial trial per required agent, and the required repository documentation.

## Evidence records

- `results/preflight-status.json`
- `results/implementation-rubric-review.md`
- `results/standard-trials.md`
- `results/cheat-trials.md`
- `results/failure-analysis.md`
- `results/contract-coverage.md`
- `results/execution-plan.md`

Raw local evidence is kept under `~/.cache/klavis-tb3-runs/` with repository/task/upstream SHAs, model configuration, Harbor output, authoritative result JSON, verifier CTRF, trajectories, and evidence audits.
