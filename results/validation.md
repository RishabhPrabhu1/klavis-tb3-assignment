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
bash scripts/run-final-tree-deadline-qualification.sh
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

## Automated implementation rubric — OUTSTANDING

Source-level review found and corrected the concrete hidden-schema and verifier-isolation defects identified during development. The automated current Terminal-Bench implementation-rubric result is nevertheless a separate required check and is **not claimed as passed** until a same-tree reviewer result records zero failed criteria.

Prepared OAuth and Bedrock runners are documented in `results/implementation-rubric-review.md`.

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

## Current frontier status

```text
Codex / Sol xhigh standard:         collection in progress; 0/3 counted until audited
Claude Code / Opus 5 max standard: 0/3 counted
Codex /cheat:                       0/1 counted
Claude /cheat:                      0/1 counted
```

An invocation is not entered as evidence merely because it was launched. Each standard run is audited after completion before it can count.

Claude-dependent evaluation, including the automated implementation-rubric run, remains outstanding pending usable Claude access. If that access is unavailable at delivery time, those gaps are disclosed explicitly rather than represented as passed.

## Pinned evaluation snapshot

The local workflow pins Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

At that snapshot, the required matrix is three Codex/Sol `xhigh` standard failures, three Claude Code/Opus 5 `max` standard failures, and one reward-0 `/cheat` entry for each agent.

The current Terminal-Bench defaults and rubric should be rechecked immediately before final delivery; any upstream change to required model identity, trial count, Harbor behavior, timeout rules, or rubric requirements supersedes this pinned snapshot.
