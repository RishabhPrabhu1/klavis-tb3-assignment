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
frontier calls during qualification:   0
```

Machine-readable status is in `results/preflight-status.json`.

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected all 40/40 development mutation controls. The frozen successor differs only in `tasks/build-snapshot-publish/tests/conftest.py`, where verifier teardown/process reaping was hardened. Because this delta does not alter the instruction, starter, reference behavior, or graded contract, the frozen successor reran current-tree static checks, the complete 68-test reference verifier, and exact-tree Harbor Oracle/NOP.

A full exact-tree reproduction, including mutation controls, is available through:

```bash
bash scripts/run-qualification.sh
```

## Verifier hardening

Earlier development trees were intentionally invalidated when review exposed hidden representation assumptions. None of those failures is counted as final model evidence. The current verifier no longer requires:

- a fixed workspace-current selector pathname;
- newest project-history generation to equal ordinary project current;
- private request replay fields;
- undocumented transaction metadata markers;
- undocumented exact retry counts.

Direct filesystem inspection is limited to the generation/object schemas stated in `instruction.md`. Candidate execution is isolated from verifier truth and runs unprivileged.

`results/contract-coverage.md` contains the detailed requirement-to-test and representation-neutrality audit.

## Automated implementation rubric — NOT RUN

Source-level review found and corrected the concrete hidden-schema and verifier-isolation defects identified during development. The automated Terminal-Bench implementation-rubric review is a separate required Claude-dependent check and has not been executed because usable Claude access is unavailable for this submission.

No automated rubric PASS is claimed. `results/implementation-rubric-review.md` documents the source-level assessment and the missing provider-dependent check.

## Frontier evidence policy

Standard `/run` evidence counts only when all of the following are established from authoritative Harbor output:

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
Codex / Sol xhigh standard:         1/3 counted; 2 remaining
Codex /cheat:                       0/1 counted
Claude Code / Opus 5 max standard: NOT RUN — Claude access unavailable
Claude /cheat:                      NOT RUN — Claude access unavailable
Automated implementation rubric:   NOT RUN — Claude access unavailable
```

Each standard run is audited after completion before it can count. Claude-dependent requirements remain visible as incomplete rather than being replaced with another model or an authentication/provider failure.

## Pinned evaluation snapshot

The repository pins Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

At that snapshot, the required matrix is three Codex/Sol `xhigh` standard failures, three Claude Code/Opus 5 `max` standard failures, and one reward-0 `/cheat` entry for each agent.

The current Terminal-Bench defaults and rubric should be rechecked immediately before final delivery; any upstream change to required model identity, trial count, Harbor behavior, timeout rules, or rubric requirements supersedes this pinned snapshot.
