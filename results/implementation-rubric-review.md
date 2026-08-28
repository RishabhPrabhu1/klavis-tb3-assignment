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

## Claude access limitation

The current Terminal-Bench implementation-rubric workflow is model-driven and uses Claude Code with Sonnet. This submission environment does not have a Claude Code subscription and does not have a usable Anthropic API or Bedrock route. The automated implementation-rubric review is therefore **NOT RUN** for this submission.

This missing result is intentionally disclosed rather than inferred from the source-level audit below. No authentication failure, alternate model, or manual assessment is represented as an automated rubric PASS. The prepared Claude runners remain in the repository only so the exact intended route is reproducible if provider access is later supplied.

## Defects found and corrected during review

Read-only source review of earlier predecessors exposed concrete issues. They were treated as task/verifier defects rather than model failures and corrected before the frozen tree:

1. **Hidden workspace-current representation** — removed fixed selector-path assumptions.
2. **Hidden project-current representation** — ordinary current is now observed through the documented read behavior rather than inferred from newest history.
3. **Private replay state** — verification uses observable committed snapshot/member/output identity rather than verifier-only request fields.
4. **Undocumented record schema** — the directly inspected record `key` field is explicitly documented and extension fields are allowed.
5. **Incomplete subprocess isolation** — candidate processes use verifier-owned logs, isolated sessions, unprivileged execution, bounded cleanup, and teardown reaping.
6. **Premature replay repair** — lost-response recovery is tested only after later overlapping publication and reclamation establish the intended durability scenario.
7. **Undocumented live-owner duplicate behavior** — same-ID pending/replacement semantics are now stated for project requests, workspace capture, and workspace transactions.
8. **Over-prescriptive transaction wording** — the contract specifies observable stale-view, atomicity, conflict/merge, replay, and reclamation outcomes rather than a required algorithm.
9. **Over-specific retry count** — only the documented positive-integer `attempts` schema is required.
10. **Teardown zombie contamination** — the frozen successor adds verifier-only child reaping.

## Source-level criterion assessment

| Criterion | Assessment | Basis / residual risk |
|---|---|---|
| Verifiable | Likely pass | Deterministic hooks, explicit observable schemas, separate verifier, reference witness. |
| Solvable | Borderline | Complete reference exists and starter scaffolding is nonblank, but the composed state-machine surface is large. |
| Difficult | Supported by calibration and exact-tree evidence | Historical Sol/xhigh calibration failed broadly; the first exact-tree Sol/xhigh trial also produced a genuine reward-0 implementation failure. |
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

A valid automated result would need to:

- run on the exact frozen task tree;
- use the pinned/current Terminal-Bench implementation-rubric source of truth;
- include the complete live criterion set;
- record zero failed criteria.

Prepared runners:

```bash
# Claude Code OAuth route
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
EXPECTED_TB3_HEAD=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480 \
CONFIRM_ZERO_COST_COVERAGE=1 \
bash scripts/run-implementation-rubric-oauth.sh

# Amazon Bedrock route
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
EXPECTED_TB3_HEAD=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480 \
bash scripts/run-implementation-rubric-bedrock.sh
```

Neither route is usable in the current submission environment because Claude provider access is unavailable. The repository therefore preserves this requirement as incomplete and the final strict readiness audit must not treat it as passed.