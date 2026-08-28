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
static checks:                    PASS
Oracle/reference:                 68/68
Harbor Oracle/NOP:                1/0
model calls during qualification: 0
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

## Source-level criterion review

| Criterion | Source-level observation | Residual risk |
|---|---|---|
| Verifiable | Deterministic hooks, explicit observable schemas, separate verifier, and a reference witness are present. | Automated rubric review not executed. |
| Solvable | A complete reference exists and starter scaffolding is nonblank. | The composed state-machine surface is large. |
| Difficult | The frozen tree produced 3/3 valid Codex/Sol `xhigh` standard reward-0 failures. | Claude standard evidence was not run. |
| Interesting / realistic | The task exercises build consistency, idempotency, crash recovery, optimistic transactions, readers, and reclamation. | Automated rubric judgment not available. |
| Outcome verified | Previously identified representation assumptions were either removed or made contractual. | Remaining hidden assumptions would require external review to detect. |
| Anti-cheat robustness | Verifier and reference state are separate from the agent environment; candidate execution is unprivileged. | Codex `/cheat` completed at reward 0; Claude adversarial evidence was not run. |
| Functional verification | Candidate code is executed and reward is behavior-based. | No automated rubric verdict available. |
| Deterministic / reproducible | Dependencies are pinned and pause/failpoint schedules replace uncontrolled timing races. | Platform-specific behavior remains a general systems-test risk. |
| Test/instruction alignment | Replay, schemas, current-state observation, duplicate ownership, and transaction outcomes are explicitly documented. | External rubric review remains the authoritative check. |
| Structured-data schema | Directly graded report/generation schemas are normative with an extension policy. | No automated rubric verdict available. |
| Reviewable | `results/contract-coverage.md` maps requirements to verifier coverage and trust boundaries. | The task is necessarily large. |
| Instruction concision | The contract is organized by interface and invariant. | Length remains a material risk because several crash/concurrency contracts are normative. |
| Expert-time estimate | Starter code and a complete reference implementation are provided. | The 4-hour estimate may be aggressive for an unfamiliar expert. |
| Verifier separation / hygiene | Verifier artifacts, dependencies, unprivileged execution, and cleanup boundaries are explicit. | Automated rubric review not executed. |

These observations are supporting source review only; they are deliberately not converted into pass/fail rubric claims.

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
bash scripts/run-implementation-rubric-oauth.sh
```

Until such a run is successfully completed, this requirement remains explicitly incomplete regardless of the source-level assessment above.
