# Validation

## Frozen task revision

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

This is the only task tree eligible for final Klavis model evidence.

## Deterministic qualification — PASS

Recorded exact-tree qualification:

```text
static checks:                         PASS
Oracle/reference:                      68/68
Harbor 0.14 Oracle:                    1.000
Harbor 0.14 NOP:                       0.000
model calls during qualification:      0
```

Machine-readable status is in `results/preflight-status.json`.

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected all 40/40 development mutation controls. The frozen successor differs only in `tasks/build-snapshot-publish/tests/conftest.py`, where verifier teardown/process reaping was hardened. Because this delta does not alter the instruction, starter, reference behavior, or graded contract, the frozen successor reran current-tree static checks, the complete 68-test reference verifier, and exact-tree Harbor Oracle/NOP.

A full exact-tree reproduction, including mutation controls, is available through:

```bash
bash scripts/run-qualification.sh
```

## Verifier hardening

Earlier development trees were invalidated when review exposed hidden representation assumptions. None of those failures is counted as final model evidence. The current verifier no longer requires a fixed workspace-current selector pathname, newest project-history generation to equal ordinary project current, private request replay fields, undocumented transaction metadata markers, or undocumented exact retry counts.

Direct filesystem inspection is limited to the generation/object schemas stated in `instruction.md`. Candidate execution is isolated from verifier truth and runs unprivileged. `results/contract-coverage.md` contains the detailed requirement-to-test and representation-neutrality audit.

## Automated implementation rubric — NOT RUN

The automated Terminal-Bench implementation-rubric review is a separate required Claude-dependent check and has not been executed because usable Claude access is unavailable for this submission. No automated rubric PASS is claimed. `results/implementation-rubric-review.md` documents the source-level assessment and the missing provider-dependent check.

## Evaluation evidence policy

Standard `/run` evidence counts only when authoritative Harbor output establishes:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
verifier completed normally
```

Provider/auth/quota failures, model unavailability, Docker/Harbor failures, verifier execution failures, timeouts, and other infrastructure errors do not count as model failures.

Adversarial `/cheat` follows the pinned live workflow's reward acceptance rule: every required task × agent entry must receive reward `0`; any nonzero reward fails the adversarial requirement.

## Current evaluation status

```text
Codex / Sol xhigh standard:         3/3 counted — COMPLETE
Codex /cheat:                       1/1 reward-0 — COMPLETE
Claude Code / Opus 5 max standard: NOT RUN — Claude access unavailable
Claude /cheat:                      NOT RUN — Claude access unavailable
Automated implementation rubric:   NOT RUN — Claude access unavailable
```

The exact-tree Codex standard collector completed on execution commit `90ba6964ae64fa04be2e58162c59b0be186023d8` with:

```text
valid_sol_xhigh_failures=3
target=3
status=SOL_MATRIX_COMPLETE
```

The three counted verifier outcomes were `62/6`, `64/4`, and `54/14` passed/failed, each with Harbor exit status `0`, authoritative reward `0.0`, and no standard-trial exceptions. `results/standard-trials.md` and `results/failure-analysis.md` contain exact evidence paths and failure analysis.

The exact-tree Codex adversarial collector then completed with:

```text
agent=codex
model=openai/gpt-5.6-sol
reasoning=xhigh
terminal_bench_head=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
reward_zero=1
target=1
status=CHEAT_MATRIX_COMPLETE
```

The adversarial Harbor result had reward `0.0`; `results/cheat-trials.md` records its exact evidence directory, result exception, and reward-based acceptance rationale.

Claude-dependent requirements remain visible as incomplete rather than being replaced with another model or an authentication/provider failure.

## Pinned evaluation snapshot

The repository pins Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

At that snapshot, the required matrix is three Codex/Sol `xhigh` standard failures, three Claude Code/Opus 5 `max` standard failures, and one reward-0 `/cheat` entry for each agent.

The current Terminal-Bench defaults and rubric should be rechecked immediately before final delivery; any upstream change to required model identity, trial count, Harbor behavior, timeout rules, or rubric requirements supersedes this pinned snapshot.
