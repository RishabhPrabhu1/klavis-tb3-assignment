# Current TB3 Implementation-Rubric Review

This file is a source-level audit, **not** a claim that the automated implementation-rubric reviewer has passed the final task. Terminal-Bench revision `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` and its implementation rubric remain the pinned evaluation source of truth for this submission snapshot.

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

Deterministic qualification is complete on this exact tree:

```text
static checks:       PASS
Oracle/reference:    68/68
Harbor Oracle/NOP:   1/0
frontier calls:      0
```

Its fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected all 40/40 development mutation negative controls. The sole successor task delta is verifier teardown/reaping hygiene in `tests/conftest.py`; the frozen successor reran current-tree static checks, the complete 68-test reference verifier, and exact-tree Harbor Oracle/NOP.

The **automated implementation-rubric PASS remains outstanding** until a same-tree result records zero failed criteria. Frontier launch wrappers now refuse to proceed without that evidence.

## Review history and corrected blockers

Read-only source reviews of earlier predecessors found concrete issues. They were treated as task/verifier defects rather than model failures and corrected before the frozen tree:

1. **Hidden workspace-current representation.** A verifier helper once assumed a fixed selector path. Current observation resolves documented workspace `commit_seq`; selector naming is private.
2. **Hidden project-current representation.** Workspace-only transaction history means newest project history is not ordinary current. Current verification asks the required public `read` interface which generation it acquired.
3. **Private replay state.** Transaction replay once depended on verifier-only `request_report` state. Current recovery verification uses observable committed snapshot/member/output identity instead.
4. **Undocumented committed-record schema.** The directly inspected generation record `key` schema is now explicitly documented, with extension fields allowed.
5. **Incomplete subprocess isolation.** Workspace candidate processes now use verifier-owned logs, isolated sessions, candidate-UID baselines, bounded cleanup, and final teardown reaping.
6. **Premature replay repair.** The lost-response transaction test now defers its first retry until after later overlapping publication plus workspace and project reclamation.
7. **Undocumented live-owner duplicate semantics.** Project requests, workspace capture, and workspace-build explicitly state that a same-ID duplicate remains pending while a live pre-commit owner is paused and that dead owners are immediately replaceable.
8. **Over-prescriptive transaction wording.** The contract states observable stale-view, atomicity, merge/conflict, replay, and reclamation outcomes instead of requiring a specific lock/read-set algorithm.
9. **Over-specific replay-attempt count.** Deferred replay requires the documented positive-integer `attempts` schema rather than an invented exact retry count.
10. **Teardown zombie contamination.** The frozen successor adds verifier-only child reaping in `tests/conftest.py`, which is the sole task delta from the fully-qualified predecessor.

## Current source-level criterion assessment

| Criterion | Assessment | Basis / residual risk |
|---|---|---|
| Verifiable | LIKELY PASS | Deterministic hooks, binary reward, separate verifier, explicit schemas, reference witness. |
| Solvable | BORDERLINE | Full reference exists and starter contains evaluator/CLI scaffolding, but the composed state-machine surface is large. |
| Difficult | PASS CALIBRATION | Historical superseded tree produced a clean Sol/xhigh reward-0 with 45/66 passing and 21 failing. Final-tree matrix remains required. |
| Interesting / realistic | PASS | Build/release consistency, idempotency, crash recovery, optimistic transactions, readers, and reclamation are professional systems problems. |
| Outcome verified | LIKELY PASS | Representation assumptions found during review were removed or explicitly documented. |
| Anti-cheat robustness | LIKELY PASS | Separate verifier, candidate unprivileged, tests/reference excluded from agent environment; empirical `/cheat` still required. |
| Functional verification | PASS | Candidate code is executed; reward is behavior-based rather than source-keyword grading. |
| Deterministic / reproducible | LIKELY PASS | Fixed dependencies and deterministic pause/failpoint schedules dominate; teardown cleanup was hardened. |
| Test/instruction alignment | LIKELY PASS | Replay, record schema, current-state observation, duplicate ownership, and transaction outcomes are now aligned. |
| Structured-data schema | LIKELY PASS | Directly graded report/generation schemas are normative and extension policy is explicit. |
| Reviewable | LIKELY PASS | `results/contract-coverage.md` maps requirements to tests and documents representation-neutrality/trust boundaries. |
| Instruction concision | BORDERLINE | Contract is necessarily long because eight interfaces and multiple crash/concurrency invariants are normative. |
| Expert-time estimate | BORDERLINE | `4.0h` is a best-case expert-known-solution repair estimate from a nonblank starter; strict reviewer judgment remains possible. |
| Separate verifier / hygiene | PASS SOURCE-LEVEL | Artifact boundary is explicit, dependencies are verifier-owned and pinned, candidate runs unprivileged. |

## Automated gate

Do **not** claim rubric success from this self-audit. The exact-tree automated result must be produced first.

Prepared runners:

```bash
# Claude subscription OAuth
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
EXPECTED_TB3_HEAD=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480 \
CONFIRM_ZERO_COST_COVERAGE=1 \
bash scripts/run-implementation-rubric-oauth.sh

# Bedrock, only with separately confirmed eligible zero-out-of-pocket coverage
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
EXPECTED_TB3_HEAD=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480 \
bash scripts/run-implementation-rubric-bedrock.sh
```

A passing result must be exact-tree, exact-upstream-revision, contain the complete live criterion set, and have zero failed criteria. `scripts/run-next-frontier-step.sh` checks for that same-tree PASS before launching Codex.

Current source-level judgment: **BORDERLINE → LIKELY PASS**, with no known concrete hidden-schema or verifier-isolation blocker remaining. The unresolved gate is empirical automated rubric acceptance, not another speculative task rewrite.
