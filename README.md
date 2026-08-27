# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` is an incremental build system repair task combining:

- crash-safe immutable project generations and atomic publication;
- concurrent incremental builds with stable input views and reusable-cache merging;
- reader/writer lifecycle, bounded GC, and object reclamation;
- exactly-once project request IDs across duplicate concurrency, owner death, response loss, later publication, and GC;
- linearizable cross-project workspace snapshots;
- optimistic atomic multi-project `workspace-build` transactions.

The transaction crux is composition rather than a hidden representation requirement. Expensive member evaluation occurs privately without globally serializing publication. Commit then validates workspace-member versions, ordinary project-current versions, manifests, and exact source observations. Disjoint transactions must progress and merge latest state; overlapping or stale transactions retry. Transaction-private project generations do not move ordinary project current, and exactly-once replay must survive later replacement and both workspace/project reclamation.

Deterministic failpoints and pausepoints expose crash/concurrency boundaries without wall-clock races.

## Current candidate

Current rubric-clean task tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

Relative to the previous representation-neutral transaction tree `5620526fada6eebea16910fc62bf71746aaa40ea`, runtime tests and the reference implementation are unchanged. Before final qualification, one reviewer-facing cleanup was applied:

- the statically required task README was reduced to non-duplicative reviewer context;
- the fully prepared expert estimate was aligned from 6.0h to 3.5h;
- difficulty metadata now states the real-world engineering role and synthetic-fixture provenance required by the live rubric;
- a few transaction coordination sentences were made outcome-oriented instead of prescribing a particular lock implementation.

The new tree must therefore be fully requalified and measured from scratch. Evidence from `5620526f...` is historical only.

## Important historical evidence

- `4eaf21ae9456395fb080be497852c0ff9623b8fa` — generation-publication design, cleanly solved by GPT-5.6 Sol/xhigh.
- `42cba8ad00bebf316048d1470033c1742a20ec97` — exactly-once redesign; substantive Sol run reached 48/48 but was formally invalid due provider/subscription exception.
- `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` — workspace-snapshot redesign; deterministically qualified then cleanly solved by Sol, 58/58, reward 1.
- `40cbd34104e1f0a549be23b46ef70655b728cece` — first optimistic transaction tree; valid Sol reward-0 was masked by an unstated `.workspace-cache/CURRENT` verifier assumption, so it did not count.
- `5620526fada6eebea16910fc62bf71746aaa40ea` — representation-neutral transaction tree, superseded before final evidence because source review found high-confidence implementation-rubric presentation risks.
- `fc064cac2fb1241b68a98475dbc8ea04fbe579cc` — current candidate.

## Repository structure

```text
tasks/build-snapshot-publish/   TB3 task, starter, reference solution, verifier
scripts/                        qualification, trial, audit, resume, and deadline runners
results/                        validation state, trial records, coverage, failure analysis
```

## Required qualification

Current live Terminal-Bench source of truth is pinned during final evidence to:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

The deterministic qualification entrypoint is:

```bash
bash scripts/run-next-qualification-step.sh
```

It runs current TB3 static checks, the full Oracle/reference verifier, 40 non-equivalent mutations across the five coverage matrices, and Harbor Oracle/NOP with zero frontier-model calls. The current expected runtime totals remain 66 Oracle tests and 40 rejected mutants because the rubric cleanup changed no tests/reference semantics.

The current implementation autoreview is a separate required gate. TB3's live review workflow uses Harbor 0.18.0 with the live `task-implementation.toml`, Claude Code, and Sonnet. `scripts/run-implementation-rubric-bedrock.sh` mirrors that review shape for the zero-spend Bedrock route and records same-tree/upstream provenance.

## Frontier requirement

Klavis requires three valid trials for each mode/configuration:

| Mode | Agent | Model | Reasoning | Required valid reward-0 trials |
|---|---|---|---|---:|
| standard `/run` | Codex | `openai/gpt-5.6-sol` | xhigh | 3 |
| standard `/run` | Claude Code | `anthropic/claude-opus-5` | max | 3 |
| adversarial `/cheat` | Codex | `openai/gpt-5.6-sol` | xhigh | 3 |
| adversarial `/cheat` | Claude Code | `anthropic/claude-opus-5` | max | 3 |

Candidate trials use Harbor 0.14.0. Auth/quota/provider-safety/timeouts/container failures do not count. `result.json` exception state and verifier reward are authoritative through `scripts/audit-trial-evidence.py`.

## Deadline workflow

Resume/requalify and obtain the first Codex difficulty measurement with:

```bash
bash scripts/resume-deadline-cycle.sh
```

The resume runner reuses only exact-tree evidence and refuses duplicate launches when an incomplete trial exists.

Once a valid same-tree reward-0 standard probe is reviewed as a real task-caused model failure, final matrices can be collected with the guarded parallel runner. The default is two simultaneous trials to reduce wall time without assuming excessive local Docker capacity:

```bash
CONFIRM_FREEZE=1 AGENT=codex  MODE=standard MAX_PARALLEL=2 bash scripts/run-parallel-final-matrix.sh
CONFIRM_FREEZE=1 AGENT=claude MODE=standard MAX_PARALLEL=2 bash scripts/run-parallel-final-matrix.sh
CONFIRM_FREEZE=1 AGENT=codex  MODE=cheat    MAX_PARALLEL=2 bash scripts/run-parallel-final-matrix.sh
CONFIRM_FREEZE=1 AGENT=claude MODE=cheat    MAX_PARALLEL=2 bash scripts/run-parallel-final-matrix.sh
```

Each batch stops immediately if any launched run is invalid, incomplete, or nonzero reward.

## Claude access

Klavis's sample uses Claude Code OAuth. For a zero-out-of-pocket path, Claude Code and Harbor also support Amazon Bedrock while preserving the required Claude Code agent, Opus 5 model, max reasoning, Docker environment, and Harbor evidence. The generic trial runner accepts Bedrock API-key or explicit AWS credential environment variables. If AWS Free Tier does not permit Opus 5 without a paid upgrade, that route must stop rather than incur cost.

## Evidence policy

A model result counts only if:

- it is on the exact qualified/frozen task tree;
- execution finishes without provider/auth/quota/timeout/container/Harbor contamination;
- authoritative Harbor `result.json` contains no invalidating exception;
- its authoritative verifier reward is unambiguous;
- verifier execution completes normally;
- a standard failure is caused by candidate behavior under a clear contract rather than specification/verifier defects.

The final audit is intentionally strict:

```bash
bash scripts/final-submission-audit.sh
```

It refuses `READY_FOR_SUBMISSION` unless the exact tree has zero-model qualification, implementation-rubric PASS, all four 3-trial reward-0 matrices, and the required repository documentation.

## Evidence records

- `results/preflight-status.json`
- `results/implementation-rubric-review.md`
- `results/standard-trials.md`
- `results/cheat-trials.md`
- `results/failure-analysis.md`
- `results/contract-coverage.md`
- `results/execution-plan.md`

Raw local evidence is kept under `~/.cache/klavis-tb3-runs/` with repository/task/upstream SHAs, model configuration, Harbor output, authoritative result JSON, verifier CTRF, trajectories, and evidence audits.
