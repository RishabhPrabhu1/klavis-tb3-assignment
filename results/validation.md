# Validation

## Frozen task revision

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

This is the only task tree eligible for final Klavis model evidence.

## Deterministic qualification — PASS

Recorded exact-tree qualification:

```text
static checks:       PASS
Oracle/reference:    68/68
Harbor 0.14 Oracle:  1.000
Harbor 0.14 NOP:     0.000
frontier calls:      0
```

Machine-readable status is in `results/preflight-status.json`.

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected all 40/40 development mutation controls. The frozen successor differs only in `tasks/build-snapshot-publish/tests/conftest.py`, where verifier teardown/reaping was hardened. Because this delta does not alter the instruction, starter, reference behavior, or graded contract, the frozen successor reran current-tree static checks, the complete 68-test reference verifier, and exact-tree Harbor Oracle/NOP.

For a fresh full exact-tree reproduction that reruns all mutation controls as well:

```bash
bash scripts/run-final-tree-deadline-qualification.sh
```

## Verifier hardening history

Earlier development trees were intentionally invalidated when review exposed hidden representation assumptions. None of those failures is counted as final model evidence. The current verifier no longer requires:

- a fixed workspace-current selector pathname;
- newest project-history generation to equal ordinary project current;
- private request replay fields;
- undocumented transaction metadata markers;
- undocumented exact retry counts.

Direct filesystem inspection is limited to the small generation/object schemas explicitly stated in `instruction.md`. Candidate execution is isolated from verifier truth and runs unprivileged.

`results/contract-coverage.md` contains the requirement-to-test and representation-neutrality audit.

## Implementation-rubric gate — OUTSTANDING

Source-level review has no known concrete hidden-schema or verifier-isolation blocker remaining. The automated current Terminal-Bench implementation-rubric result is still required on the exact frozen tree and must return zero failed criteria before frontier calls begin.

The repository provides exact-tree OAuth and Bedrock rubric runners. `scripts/run-next-frontier-step.sh` refuses to launch Codex unless a same-tree automated rubric PASS exists.

## Frontier validity policy

Standard `/run` evidence counts only when:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
```

Provider/auth/quota failures, model unavailability, Docker/Harbor failures, verifier execution failures, timeouts, and other infrastructure errors do not count as model failures.

Adversarial `/cheat` follows the pinned live workflow's reward acceptance rule: every required task × agent entry must receive reward `0`; any nonzero reward fails the adversarial requirement.

## Current frontier status

```text
Codex / Sol xhigh standard:       0/3
Claude Code / Opus 5 max standard: 0/3
Codex /cheat:                     0/1
Claude /cheat:                    0/1
```

No final-tree frontier model call has been counted yet.

## Current gate order

1. **DONE** — frozen exact-tree deterministic qualification (`68/68`, Harbor `1/0`, zero frontier calls).
2. **NEXT** — automated implementation-rubric PASS on `d862ab3...`.
3. One guarded Sol/xhigh standard probe on the exact tree.
4. Inspect the result: genuine candidate reward-0 failure → freeze; solve → requirement not met; spec/verifier/infrastructure failure → do not count.
5. Complete the three valid Codex standard failures if the first probe is legitimate.
6. Complete one Codex `/cheat` reward-0 run.
7. Complete three valid Claude Opus 5/max standard failures.
8. Complete one Claude `/cheat` reward-0 run.
9. Update evidence ledgers and failure analysis with exact paths/results.
10. Run `bash scripts/final-submission-audit.sh` and require `FINAL_STATUS=READY_FOR_SUBMISSION`.
11. Verify the default GitHub branch exposes this exact task tree and current documentation before sending the repository URL.

## Pinned evaluation snapshot

The local workflow currently pins Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

Immediately before final frontier execution/submission, recheck current Terminal-Bench defaults and rubric. If required models, trial counts, Harbor behavior, timeout policy, or rubric criteria changed upstream, the current source of truth supersedes this snapshot.
