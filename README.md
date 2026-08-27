# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` repairs an incremental build system that composes:

- crash-consistent immutable project publication;
- concurrent incremental builds with stable-input validation and reusable-cache merging;
- exactly-once requests across duplicate concurrency, owner death, response loss, later publication, and GC;
- live readers plus bounded project/object reclamation;
- simultaneous cross-project workspace snapshots;
- atomic optimistic multi-project workspace write transactions;
- workspace readers/GC with transitive project-generation protection.

The intended difficulty is systems composition, not hidden file-layout requirements. Deterministic pause/fail hooks expose concurrency and crash boundaries without relying on uncontrolled races.

## Current candidate

Current rubric-corrected task tree:

```text
316aaf9804a82cc43e6075a657f3effda0c5717c
```

This successor preserves the same starter and reference implementation as the difficulty-proven transaction task while removing verifier assumptions found during review:

- ordinary project current is observed through the public `read` interface, not a private selector or transaction marker;
- workspace current is resolved from documented workspace generation metadata, not a fixed `CURRENT` pathname;
- response-loss replay is verified through the public replay interface, not a private `request_report` field;
- the small generation-record object-reference schema inspected by GC verification is explicitly documented;
- long-lived verifier processes use bounded cleanup and verifier-owned log files rather than unbounded inherited-pipe reads.

Final deterministic qualification and model evidence must use this exact task tree or a later explicitly documented successor. Do not count historical-tree trials toward the final matrix.

## Difficulty calibration

The immediately preceding semantic task, `fc064cac2fb1241b68a98475dbc8ea04fbe579cc`, passed 66/66 reference tests, rejected 40/40 development mutants, and produced Harbor Oracle/NOP rewards `1/0`. A clean GPT-5.6 Sol/xhigh standard trial then returned:

```text
reward = 0
45 passed / 21 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
runtime = 29m44s
```

The failures spanned publication, exactly-once durability, readers/GC, reclamation interleavings, recovery, and transaction replay. Later rubric review found verifier/schema/process issues in that tree, so this trial is **difficulty calibration only**, not final required evidence. The current successor changes verifier observation and documentation rather than starter/reference runtime code; no further difficulty strengthening is planned.

Earlier calibration history is documented in `results/failure-analysis.md`.

## Repository structure

```text
tasks/build-snapshot-publish/   task, starter, reference solution, verifier
scripts/                        qualification, trial, audit, and deadline runners
results/                        validation state, trial records, coverage, failure analysis
```

## Source of truth

Pinned Terminal-Bench source-of-truth revision for this submission workflow:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

Klavis requires current TB3 static/implementation review, Docker, Oracle/NOP, three standard trials for each required agent configuration, and current `/cheat` behavior.

## Deterministic qualification

For the checked-out candidate tree:

```bash
bash scripts/run-next-qualification-step.sh
```

This runs current TB3 static checks, the complete reference verifier, 40 non-equivalent development mutations, then Harbor Oracle/NOP with zero frontier-model calls. The resulting same-tree qualification marker is stored under `~/.cache/klavis-tb3-runs/transaction-preflight/`.

When deterministic qualification and an exact-tree zero-model Harbor preflight were already completed before a scripts-only commit, `scripts/adopt-qualified-tree.sh` can create the canonical marker only after explicit confirmation and exact-tree evidence verification; it cannot silently manufacture qualification for a different task tree.

## Required frontier matrix

At the pinned TB3 workflow, standard `/run` requires three attempts per agent configuration. Docker `/cheat` has one matrix entry per `(task × agent)` and no extra trial dimension.

| Mode | Agent | Model | Reasoning | Required |
|---|---|---|---|---:|
| `/run` | Codex | `openai/gpt-5.6-sol` | xhigh | 3 genuine verifier failures |
| `/run` | Claude Code | `anthropic/claude-opus-5` | max | 3 genuine verifier failures |
| `/cheat` | Codex | `openai/gpt-5.6-sol` | xhigh | 1 reward-0 run |
| `/cheat` | Claude Code | `anthropic/claude-opus-5` | max | 1 reward-0 run |

Standard-trial crashes, provider/auth/quota failures, container failures, timeouts, and other infrastructure errors do **not** count as model failures.

Adversarial evaluation follows the live TB3 workflow's reward semantics: any nonzero `/cheat` reward fails the requirement; a Harbor/agent failure is recorded by that workflow as reward 0 rather than being subjected to the stricter `/run` validity rule.

## Frontier workflow

After exact-tree deterministic qualification and implementation-rubric review, launch only one first Sol probe:

```bash
bash scripts/run-one-qualified-sol-probe.sh
```

The runner refuses duplicate/incomplete same-tree Sol evidence and distinguishes valid reward-0, valid solve, and invalid execution.

After a valid same-tree model failure is reviewed and the tree is frozen, complete Sol standard evidence with:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

Adversarial evidence uses the live reward-based semantics:

```bash
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 bash scripts/run-deadline-cheat-matrix.sh
```

The generic parallel matrix remains appropriate for the three standard trials.

## Claude access

The required Claude configuration is Claude Code / `anthropic/claude-opus-5` / max. Repository tooling supports Claude Code through Amazon Bedrock without changing that requested agent/model identity. `scripts/smoke-test-claude-bedrock.sh` performs a bounded entitlement check before any full benchmark trial, and `scripts/run-deadline-claude-pipeline.sh` is guarded against silent fallback to direct Anthropic billing.

Zero-cost provider entitlement is an external prerequisite; the repository does not assume ordinary AWS Free Tier credits cover third-party Anthropic usage.

## Evidence policy

For standard `/run`, a result counts only when it is on the exact qualified/frozen tree, completes without invalidating infrastructure/provider exceptions, runs the verifier normally, and receives reward 0 because of candidate behavior under a clear contract.

For `/cheat`, the exact tree/configuration must be used and the recorded reward must be 0; any nonzero reward means the verifier was defeated.

Final readiness is checked with:

```bash
bash scripts/final-submission-audit.sh
```

The audit requires exact-tree qualification, implementation-rubric PASS, three valid reward-0 standard trials for each required agent, one reward-0 adversarial run for each required agent, and the repository evidence records.

## Evidence records

- `results/preflight-status.json`
- `results/implementation-rubric-review.md`
- `results/standard-trials.md`
- `results/cheat-trials.md`
- `results/failure-analysis.md`
- `results/contract-coverage.md`
- `results/execution-plan.md`

Raw local evidence remains under `~/.cache/klavis-tb3-runs/` with repository/task/upstream SHAs, model configuration, Harbor output, verifier CTRF, trajectories, and evidence audits.
