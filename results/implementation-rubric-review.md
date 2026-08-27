# Current TB3 Implementation-Rubric Review

This file is a source-level audit, **not** a claim that the live automated implementation-rubric reviewer has passed the final task. Terminal-Bench HEAD `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` and its `docs/prompts/task-implementation.toml` remain authoritative.

Current rubric-corrected candidate:

```text
85eb3be3ce69a625a06eab3e37c69badbab89779
```

Exact-tree deterministic qualification and automated rubric execution are still required before final submission.

## Review history

Two read-only Work reviews were used as source-level negative controls.

The first, on predecessor `fc064cac...`, found concrete hidden-schema/process/prescriptive-contract defects. Those produced the first rubric-corrected successor.

The second, on `d7d7adf...`, confirmed that the private `request_report` dependency was gone and structured schemas were documented, but still judged the tree **RUBRIC LIKELY FAIL** because:

1. synchronous workspace capture, workspace GC, and workspace-build still used agent-controlled pipes without full session/descendant cleanup;
2. async capture did not carry UID-baseline cleanup metadata through finish/kill paths;
3. the transaction lost-response test performed an early public replay before later replacement/GC, allowing an implementation to rely on that retry to make state durable;
4. duplicate tests required a live owner to keep ownership while the instruction did not state that observable behavior;
5. expert-time/solvability, instruction length, deterministic sleeps, and review size remained subjective risks.

## Corrections in the frozen candidate

- **All cited workspace candidate execution paths are isolated.** Synchronous capture, workspace GC, synchronous workspace-build, async capture, workspace reads, and plain builds use verifier-owned stdout/stderr files, `start_new_session=True`, a pre-launch candidate-UID PID baseline, and bounded cleanup on success/failure/timeout. Transaction helpers use the same model.
- **Cleanup portability no longer contaminates local mutation evidence.** Host-only non-root `PermissionError` on process signalling is treated as a developer-host limitation, while the authoritative root verifier still raises any such cleanup failure.
- **Lost-response first replay is truly deferred.** After `workspace-build:after-publish`, the verifier performs a later overlapping transaction, workspace GC, and project GC *before the first retry*. That first replay is validated against the stranded snapshot member identity plus the original output path/hash; `attempts` is required only to satisfy the documented positive-integer schema. A second replay must be exactly identical and still nonpublishing.
- **Live-owner duplicate behavior is explicit.** Project requests, workspace capture, and workspace-build state that a duplicate remains pending while a live pre-commit owner is paused; dead owners are immediately replaceable.
- **Private replay state remains absent from verification.** No `request_report` field is required.
- **Transaction marker remains representation-private.** Ordinary project current is observed through the public `read` interface; no `workspace_transaction` metadata bit is required.
- **Record schema is explicit.** The only directly inspected generation-record field is documented: JSON with a 64-lowercase-hex `key`, with extension fields allowed.
- **Workspace selector is representation-neutral.** Current workspace generation is resolved by documented `commit_seq`, not a fixed selector pathname.
- **Transaction prose is outcome-oriented.** The instruction states stale-view rejection/retry, atomic visibility, ordinary-current nonmovement, disjoint progress/merge, overlap conflict, replay, and reclamation outcomes rather than a mandatory lock/read-set algorithm.

## Current source-level criterion assessment

| Criterion | Current assessment | Basis / remaining risk |
|---|---|---|
| `verifiable` | LIKELY PASS | Deterministic hooks, exact assertions, pinned verifier deps, no runtime verifier network installs. Final qualifier reruns all 40 development mutation controls rather than inheriting contaminated families. |
| `solvable` | BORDERLINE | A full reference exists and the starter already contains evaluator/CLI infrastructure, but the repaired state-machine surface is still large. This is the largest remaining subjective risk. |
| `difficult` | PASS CALIBRATION | Predecessor with the same starter/reference runtime challenge produced a clean Sol/xhigh reward-0 with 45/66 passing and 21 failing. Final-tree trial still required. |
| `interesting` | PASS | Build/release consistency, idempotency, crash recovery, and reclamation are professional systems problems. |
| `outcome_verified` | LIKELY PASS | Transaction choreography/marker requirement removed; remaining schemas are explicit committed artifacts used for history/GC observability. |
| `anti_cheat_robustness` | LIKELY PASS | Separate verifier, no tests/solution in agent image, candidate runs unprivileged during authoritative verification. Empirical `/cheat` remains required. |
| `task_security` | PASS | No credential access, network exfiltration, host escape, obfuscation, or unrelated destructive behavior. |
| `functional_verification` | PASS | Candidate code is executed; tests do not grade source keywords or implementation patterns. |
| `deterministic_reproducible` | BORDERLINE → LIKELY PASS | Fixed dependencies and deterministic pause/fail hooks dominate. A few bounded scheduling-delay assertions remain, but they are not used to infer committed state and have explicit process-liveness checks. |
| `essential_difficulty` | PASS | Failures require concurrency/recovery/GC reasoning, not clerical formatting. |
| `test_instruction_alignment` | LIKELY PASS | Hidden replay field, record schema, selector/transaction marker, deferred first replay, positive-attempt schema, and live-owner duplicate semantics are aligned. |
| `structured_data_schema` | LIKELY PASS | Reports/plans and directly inspected committed-generation schemas are explicitly normative; extension fields are stated where allowed. |
| `novel` | PASS | Custom composition of build cache, exactly-once, consistent-cut, optimistic transaction, and GC protocols. |
| `agentic` | PASS | Requires multi-file exploration, implementation, process/concurrency debugging, and repeated execution. |
| `reviewable` | BORDERLINE → LIKELY PASS | Test suite is large, but `results/contract-coverage.md` provides requirement-to-test traceability plus representation-neutrality/process-trust notes. |
| `instruction_concision` | BORDERLINE | Contract is still long because eight interfaces and several crash/concurrency invariants are normative. It is outcome-focused and substantially shorter than the earlier version, but length remains subjective. |
| `difficulty_explanation_quality` | PASS | States systems crux, professional role, and synthetic-fixture provenance without model pass-rate claims. |
| `solution_explanation_quality` | PASS | Describes a high-level witness consistent with separate solution source files rather than a required algorithm. |
| `verification_explanation_quality` | PASS | Explains behavioral schedules, crash/replay/GC checks, and mutation negative controls. |
| `category_and_tags` | PASS | `Software / Systems` with specific systems tags. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive kebab-case and three tokens. |
| `resource_configuration` | PASS | 4h agent timeout / 15m verifier timeout; ordinary CPU/memory/storage limits. Difficulty is reasoning rather than compute. |
| `task_readme` | LIKELY PASS GIVEN STATIC CONSTRAINT | Pinned static checks require README + four headings. Current 17-line file gives reviewer-only context instead of duplicating the full contract. |
| `expert_time_estimate` | BORDERLINE | `4.0h` is a best-case expert-known-solution repair estimate from a nonblank starter, but a strict reviewer may still judge the state-machine surface too large. Raising the estimate would worsen `solvable`; reducing scope would invalidate difficulty calibration. |
| `task_toml_schema` | LIKELY PASS | Uses recognized metadata/verifier/agent/environment fields only. |
| `no_extraneous_files` | LIKELY PASS | Task-local files are build/runtime/solution/test scaffolding or statically required reviewer documentation. |
| `artifact_efficiency` | PASS | Artifact is `/app/buildsys/`, not dependency/build output. |
| `separate_verifier_configured` | PASS SOURCE-LEVEL | `/app/buildsys/` is declared as artifact; verifier tooling is baked into `tests/Dockerfile`. |
| `environment_hygiene` | PASS | Agent image contains starter/project only; verifier image owns test dependencies. |
| `verifier_execution_isolation` | LIKELY PASS | All Work-cited candidate invocation paths now use verifier-owned logs, isolated sessions, baseline-aware cleanup, and bounded timeout handling. |
| binary reward / identifiers / typos | LIKELY PASS | Binary pytest reward; current static checks are final source of truth. |

## README/static-check tension

The live rubric describes a task README as optional and discourages duplicate content. The pinned static checker separately requires `README.md` plus the four exact headings `Difficulty explanation`, `Solution explanation`, `Verification explanation`, and `Relevant experience`. The task therefore retains the shortest useful reviewer-context README while keeping the agent contract in `instruction.md` and metadata in `task.toml`.

## Remaining gates

The task is **not yet marked rubric-passed**. Before final submission:

1. exact task tree `85eb3be3ce69a625a06eab3e37c69badbab89779` must pass current static checks, full Oracle/reference tests, all 40 development mutants, and Harbor Oracle/NOP;
2. the live implementation-rubric review must return zero failed criteria on that exact tree;
3. the exact frozen tree must complete the required Sol and Opus standard matrices and current `/cheat` runs.

Current source-level judgment: **BORDERLINE → LIKELY PASS**. There is no remaining known hidden-schema or verifier-isolation blocker; the main uncertainty is whether the automated reviewer considers the best-case expert scope and instruction length acceptable.
