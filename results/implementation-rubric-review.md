# Current TB3 Implementation-Rubric Review

This file is a source-level audit, **not** a claim that the live automated implementation-rubric reviewer has passed the final task. Terminal-Bench HEAD `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` and its `docs/prompts/task-implementation.toml` remain authoritative.

Current rubric-corrected candidate:

```text
316aaf9804a82cc43e6075a657f3effda0c5717c
```

Exact-tree deterministic qualification and automated rubric execution are still required before final submission.

## Review history

A read-only Work review of predecessor tree `fc064cac...` judged it **RUBRIC LIKELY FAIL** and identified concrete issues rather than only stylistic concerns:

1. transaction response-loss verification read undocumented `snapshot["request_report"]`;
2. generation-object reachability parsed a record `"key"` field that was not yet documented;
3. transaction instructions prescribed internal evaluation/commit state and required a `workspace_transaction` marker;
4. workspace reader/plain-build helpers used inherited stderr pipes followed by unbounded post-wait reads and lacked equivalent descendant cleanup;
5. instruction length, reviewer complexity, deterministic sleeps, and expert-time/solvability were additional subjective risks.

The current successor was built specifically to remove the concrete blockers without changing starter/reference runtime difficulty.

## Corrections in the current candidate

- **Private replay state removed from verification.** The post-publish transaction test first obtains the original report by public same-ID replay, verifies that replay does not republish, then requires the exact same report after later replacement plus workspace/project GC.
- **Record schema made explicit.** The only generation-record field needed for object reachability is now documented: each record is JSON containing a 64-lowercase-hex `key`; extension fields are allowed.
- **Transaction marker no longer required.** Ordinary project current is observed through the required public `read` interface and its acquired generation token. A candidate may use any internal transaction metadata/layout consistent with the documented generation schema.
- **Workspace selector remains representation-neutral.** Current workspace generation is resolved by documented `commit_seq`, not a fixed selector pathname.
- **Async process isolation hardened.** Flagged long-lived helpers use verifier-owned log files rather than inherited stderr pipes and perform bounded process/session cleanup; transaction helpers use the same process-tree cleanup model.
- **Transaction prose is outcome-oriented.** The instruction now states stale-view rejection/retry, atomic visibility, ordinary-current nonmovement, disjoint progress/merge, overlap conflict, replay, and reclamation outcomes rather than a mandatory lock/read-set algorithm.
- **Instruction compressed.** Repeated transaction/crash prose was consolidated into invariant groups and compact hook tables.
- **Expert estimate calibrated to the actual starter.** `expert_time_estimate_hours = 4.0`; the starter already contains the target evaluator and CLI skeleton, while the estimate assumes a focused domain expert who knows the intended approach in advance, matching the live rubric definition.

## Current source-level criterion assessment

| Criterion | Current assessment | Basis / remaining risk |
|---|---|---|
| `verifiable` | LIKELY PASS | Deterministic hooks, exact programmatic assertions, pinned verifier deps, no runtime verifier network installs. Final exact-tree repeated qualification still required. |
| `solvable` | BORDERLINE → LIKELY PASS | Full reference exists. Scope is substantial, but starter is nonblank and 4h is a best-case expert-known-solution estimate. This remains the main subjective risk. |
| `difficult` | PASS CALIBRATION | Predecessor with same runtime challenge produced a clean Sol/xhigh reward-0 with 45/66 tests passing and 21 failing. Final-tree trial still required for submission evidence. |
| `interesting` | PASS | Build/release consistency, idempotency, crash recovery, and reclamation are professional systems problems. |
| `outcome_verified` | LIKELY PASS | Transaction choreography/marker requirement removed; remaining schemas are small durable artifacts needed for externally auditable GC/history behavior. |
| `anti_cheat_robustness` | LIKELY PASS | Separate verifier, no tests/solution in agent image, candidate runs unprivileged during verification. Empirical `/cheat` remains required. |
| `task_security` | PASS | No credential access, network exfiltration, host escape, obfuscation, or unrelated destructive behavior. |
| `functional_verification` | PASS | Candidate code is executed; tests do not grade source keywords or implementation patterns. |
| `deterministic_reproducible` | BORDERLINE → LIKELY PASS | Dependencies are pinned and most concurrency uses deterministic handshakes. A few bounded fixed-delay assertions remain a reviewer risk but are not the core synchronization mechanism. |
| `essential_difficulty` | PASS | Failures require concurrency/recovery/GC reasoning, not clerical output formatting. |
| `test_instruction_alignment` | LIKELY PASS | Previously hidden `request_report`, record schema, selector, and transaction-marker assumptions have been removed or documented. |
| `structured_data_schema` | LIKELY PASS | Reports/plans and the directly inspected committed-generation schemas are explicitly normative; extension fields are stated where allowed. |
| `novel` | PASS | Custom composition of build cache, exactly-once, consistent-cut, optimistic transaction, and GC protocols. |
| `agentic` | PASS | Requires multi-file exploration, implementation, process/concurrency debugging, and repeated execution. |
| `reviewable` | BORDERLINE → LIKELY PASS | Test suite is large, but metadata and `results/contract-coverage.md` provide requirement-to-test traceability and representation-neutrality history. |
| `instruction_concision` | BORDERLINE | Contract is still long because eight public interfaces and several crash/concurrency invariants are normative. It is substantially shorter and no longer procedural, but length remains subjective. |
| `difficulty_explanation_quality` | PASS | States systems crux, professional role, and synthetic-fixture provenance without model pass-rate claims. |
| `solution_explanation_quality` | PASS | Describes a high-level witness consistent with separate solution source files rather than a step-by-step required algorithm. |
| `verification_explanation_quality` | PASS | Explains execution schedules, crash/replay/GC checks, and mutation negative controls. |
| `category_and_tags` | PASS | `Software / Systems` with specific systems tags. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive kebab-case and three tokens. |
| `resource_configuration` | PASS | 4h agent timeout / 15m verifier timeout; ordinary CPU/memory/storage limits. Difficulty is reasoning rather than computation. |
| `task_readme` | LIKELY PASS GIVEN STATIC CONSTRAINT | Live static check requires a README and four headings. Current content is short reviewer-maintenance context rather than a duplicate full specification. |
| `expert_time_estimate` | BORDERLINE → LIKELY PASS | Nonzero 4.0h best-case expert estimate; final reviewer may still judge scope high. |
| `task_toml_schema` | LIKELY PASS | Uses recognized metadata/verifier/agent/environment fields only. |
| `no_extraneous_files` | LIKELY PASS | Task-local files are build/runtime/solution/test scaffolding or statically required reviewer documentation. |
| `artifact_efficiency` | PASS | Artifact is the small agent-edited `/app/buildsys/` deliverable, not a dependency/build tree. |
| `separate_verifier_configured` | PASS SOURCE-LEVEL | `/app/buildsys/` is declared as artifact; verifier tooling is baked into `tests/Dockerfile`. |
| `environment_hygiene` | PASS | Agent image contains starter/project only; verifier image owns test dependencies. |
| `verifier_execution_isolation` | LIKELY PASS | Concrete inherited-pipe deadlock paths were removed and async process cleanup was strengthened. Exact-tree tests remain the operational check. |
| binary reward / identifiers / typos | LIKELY PASS | Binary pytest reward; current static checks are the final source of truth. |

## README/static-check tension

The live rubric describes a task README as optional and says it should not duplicate other task content. Separately, the pinned static checker requires `README.md` plus exactly these headings: `Difficulty explanation`, `Solution explanation`, `Verification explanation`, and `Relevant experience`. The task therefore retains a minimal README whose content is limited to reviewer/maintenance context not otherwise needed by the agent.

## Remaining gates

The task is **not yet marked rubric-passed**. Before final submission:

1. exact task tree must pass current static checks, full Oracle/reference tests, all 40 development mutants, and Harbor Oracle/NOP;
2. the live implementation-rubric review must return zero failed criteria on that exact tree;
3. the exact frozen tree must complete the required Sol and Opus standard matrices and current `/cheat` runs.

Current source-level judgment: **BORDERLINE → LIKELY PASS**, with `instruction_concision` and best-case expert scope the main subjective risks rather than known hidden verifier requirements.
