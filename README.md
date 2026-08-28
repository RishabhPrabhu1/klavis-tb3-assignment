# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` repairs an incremental build system that composes crash-consistent publication, concurrent incremental builds, exactly-once requests, live readers and reclamation, cross-project workspace snapshots, and atomic optimistic multi-project workspace write transactions.

The intended difficulty is systems composition, not hidden file-layout requirements. Deterministic pause/fail hooks expose concurrency and crash boundaries without relying on uncontrolled races.

## Frozen submission candidate

```text
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
```

This is the frozen task tree for final evaluation. Do not count model evidence from any other task tree toward the required matrix.

The immediately preceding fully-qualified task tree was:

```text
301107828273e249fbd31ed34d86bf3fed7143a1
```

The only task-tree delta from that predecessor is verifier teardown/reaping hygiene in `tasks/build-snapshot-publish/tests/conftest.py`; the instruction, starter, and reference runtime semantics are unchanged.

## Deterministic qualification

Recorded qualification for the frozen tree:

```text
TB3 static checks:        PASS
Oracle/reference:         68/68
Harbor 0.14 Oracle:       1.000
Harbor 0.14 NOP:          0.000
frontier calls:           0
```

The predecessor rejected all 40/40 development mutation negative controls. Because the frozen successor changes only verifier teardown/reaping hygiene, it reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP. The machine-readable record is `results/preflight-status.json`.

For a fully fresh exact-tree rerun including all 40 mutation controls:

```bash
bash scripts/run-final-tree-deadline-qualification.sh
```

The successor-delta qualification path used for the recorded frozen-tree evidence is:

```bash
bash scripts/run-fast-final-successor-qualification.sh
```

Both qualification paths are zero-frontier-model gates.

## Implementation rubric

The task has undergone repeated source-level rubric audits and concrete verifier/specification defects found during those reviews were corrected before the frozen tree was qualified. The automated Terminal-Bench implementation-rubric result on the exact frozen tree is still a required gate and must not be represented as passed until a same-tree result records zero failed criteria.

Prepared exact-tree runners:

```bash
# Klavis/Claude subscription OAuth route
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
CONFIRM_ZERO_COST_COVERAGE=1 \
bash scripts/run-implementation-rubric-oauth.sh

# Amazon Bedrock route, only with confirmed eligible coverage
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
bash scripts/run-implementation-rubric-bedrock.sh
```

`bash scripts/run-next-frontier-step.sh` refuses to launch a frontier probe unless the exact-tree deterministic qualification marker **and** an exact-tree automated rubric PASS both exist.

## Required frontier matrix

At the pinned Terminal-Bench workflow snapshot, the required configurations are:

| Mode | Agent | Model | Reasoning | Required |
|---|---|---|---|---:|
| `/run` | Codex | `openai/gpt-5.6-sol` | `xhigh` | 3 genuine verifier failures |
| `/run` | Claude Code | `anthropic/claude-opus-5` | `max` | 3 genuine verifier failures |
| `/cheat` | Codex | `openai/gpt-5.6-sol` | `xhigh` | 1 reward-0 run |
| `/cheat` | Claude Code | `anthropic/claude-opus-5` | `max` | 1 reward-0 run |

Standard-trial crashes, auth/provider/quota failures, container failures, timeouts, and other infrastructure errors do **not** count as model failures. `/cheat` follows the pinned live workflow's reward condition: any nonzero reward fails the adversarial requirement.

### Frozen-tree frontier status

No frontier model call has yet been counted on `d862ab3cc79718e959e9cc7ec1b792540990a24d`.

```text
Codex standard:   0/3
Claude standard:  0/3
Codex cheat:      0/1
Claude cheat:     0/1
```

These records are updated in `results/standard-trials.md` and `results/cheat-trials.md` as exact-tree evidence is collected.

## Difficulty calibration — historical only

The superseded calibration tree `fc064cac2fb1241b68a98475dbc8ea04fbe579cc` passed its then-current 66/66 reference suite, rejected 40/40 development mutants, and produced Harbor Oracle/NOP `1/0`. A clean GPT-5.6 Sol/xhigh standard trial on that historical tree returned:

```text
reward = 0
45 passed / 21 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
runtime = 29m44s
```

That result demonstrates difficulty only. Later verifier/schema/process review superseded the tree, so it does **not** count toward the final matrix.

## Source-of-truth snapshot

The local evaluation workflow is pinned to Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

Immediately before final frontier evaluation/submission, the live Terminal-Bench defaults and rubric should be rechecked; any upstream change to required model identity, trial count, Harbor behavior, timeout rules, or rubric requirements supersedes this snapshot.

## Authoritative commands

```bash
# Current local state
bash scripts/deadline-status.sh

# Fresh deterministic qualification if needed
bash scripts/run-final-tree-deadline-qualification.sh

# First frontier call only after exact-tree rubric PASS
bash scripts/run-next-frontier-step.sh

# Complete Codex standards after a legitimate first reward-0 failure is reviewed/frozen
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh

# Exact-tree adversarial runs
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 bash scripts/run-deadline-cheat-matrix.sh
CONFIRM_FREEZE=1 CONFIRM_ZERO_COST_COVERAGE=1 AGENT=claude TARGET_CHEATS=1 bash scripts/run-deadline-cheat-matrix.sh

# Final acceptance audit
bash scripts/final-submission-audit.sh
```

Legacy/development wrappers are not evidence sources. Current-tree guards in the authoritative entry points are the submission path.

## Evidence records

- `results/preflight-status.json` — frozen-tree deterministic qualification
- `results/implementation-rubric-review.md` — rubric audit and automated-gate status
- `results/standard-trials.md` — required `/run` matrix
- `results/cheat-trials.md` — required `/cheat` matrix
- `results/failure-analysis.md` — model-failure classification
- `results/contract-coverage.md` — instruction-to-verifier traceability
- `results/environment.md` — Terminal-Bench/configuration snapshot
- `results/execution-plan.md` — remaining gate order

Raw local evidence remains under `~/.cache/klavis-tb3-runs/`, keyed by repository/task/upstream SHAs and agent configuration.

## Final readiness

```bash
bash scripts/final-submission-audit.sh
```

Submission is ready only when that audit reports `FINAL_STATUS=READY_FOR_SUBMISSION` and the repository documentation has been updated with the exact final trial evidence.
