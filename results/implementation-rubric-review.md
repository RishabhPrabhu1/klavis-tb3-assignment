# Terminal-Bench Implementation-Rubric Review

This document is a source-level audit of the frozen task. It is **not** a substitute for the automated Terminal-Bench implementation-rubric reviewer and does not claim that check has passed.

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

Pinned Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

Deterministic qualification on the exact frozen tree is complete:

```text
static checks:                         PASS
Oracle/reference:                      68/68
Harbor Oracle/NOP:                     1/0
frontier calls during qualification:   0
```

Its fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected all 40/40 development mutation negative controls. The sole successor task delta is verifier teardown/process-reaping hygiene in `tests/conftest.py`; the frozen successor reran current-tree static checks, the complete 68-test reference verifier, and exact-tree Harbor Oracle/NOP.

## Defects corrected before the freeze

Read-only source review of earlier predecessors exposed concrete issues. They were treated as task/verifier defects rather than model failures and corrected before the frozen tree:

1. Hidden workspace-current representation assumptions were removed.
2. Ordinary project-current observation was made representation-neutral.
3. Verification stopped depending on private request replay fields.
4. Directly inspected committed-record schema was documented with extension fields allowed.
5. Candidate subprocess isolation and teardown cleanup were hardened.
6. Lost-response durability tests were reordered so they exercise the intended reclamation state.
7. Live-owner duplicate semantics were documented for project requests, workspace capture, and workspace transactions.
8. Transaction requirements were expressed as observable outcomes rather than a prescribed algorithm.
9. Exact retry-count assumptions were removed.
10. Verifier teardown child reaping was added to eliminate cross-test contamination.

## Source-level criterion assessment

| Criterion | Assessment | Basis / residual risk |
|---|---|---|
| Verifiable | Likely pass | Deterministic hooks, explicit observable schemas, separate verifier, reference witness. |
| Solvable | Borderline | Complete reference exists and starter scaffolding is nonblank, but the composed state-machine surface is large. |
| Difficult | Supported by calibration | A superseded qualified tree produced a clean Sol/xhigh reward-0 with broad failures; exact final-tree matrix is still required. |
| Interesting / realistic | Likely pass | Build consistency, idempotency, crash recovery, optimistic transactions, readers, and reclamation are professional systems concerns. |
| Outcome verified | Likely pass | Representation assumptions identified during review were removed or documented. |
| Anti-cheat robustness | Likely pass | Separate verifier, unprivileged candidate, verifier/reference excluded from agent environment; empirical `/cheat` remains required. |
| Functional verification | Likely pass | Candidate code is executed and reward is behavior-based. |
| Deterministic / reproducible | Likely pass | Fixed dependencies and deterministic pause/failpoint schedules dominate; teardown cleanup is hardened. |
| Test/instruction alignment | Likely pass | Replay, record schema, current-state observation, duplicate ownership, and transaction outcomes are explicitly aligned. |
| Structured-data schema | Likely pass | Directly graded report/generation schemas are normative with extension policy stated. |
| Reviewable | Likely pass | `results/contract-coverage.md` maps requirements to tests and trust boundaries. |
| Instruction concision | Borderline | The contract is long because eight interfaces and several crash/concurrency invariants are normative. |
| Expert-time estimate | Borderline | The 4-hour estimate assumes an expert working from the provided starter and understanding the intended systems approach. |
| Verifier separation / hygiene | Likely pass | Artifact boundary, pinned verifier dependencies, unprivileged candidate execution, and cleanup are explicit. |

## Automated check — NOT RUN

The current Terminal-Bench implementation-rubric workflow is Claude-dependent. This submission environment does not have a usable Claude Code subscription or another usable Claude provider route, so the automated review was not executed.

No automated rubric PASS is claimed. A valid future result must:

- run on the exact frozen task tree;
- use the pinned/current Terminal-Bench implementation-rubric source of truth;
- include the complete live criterion set;
- record zero failed criteria.

The repository retains the OAuth runner required to reproduce that check if Claude access becomes available:

```bash
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
EXPECTED_TB3_HEAD=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480 \
CONFIRM_ZERO_COST_COVERAGE=1 \
bash scripts/run-implementation-rubric-oauth.sh
```

Until such a run is successfully completed, this requirement remains explicitly incomplete regardless of the source-level assessment above.
