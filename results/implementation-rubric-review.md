# Current TB3 implementation-rubric review

This is a reviewer-side assessment, not a claim that Terminal-Bench's automated `/review` workflow ran. It was originally audited against the live rubric blob `5a88f5f89bdfc3b633c06e3dc06486fc9385e2b7`. At upstream `b2d4a935cfb1a6f621f611ea69421039cfccd158` on August 26, 2026, that rubric lives at `docs/prompts/task-implementation.toml`.

The current task tree is `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8` and is still pending deterministic qualification. Verdicts below are therefore a source-level review, not a green qualification claim.

## Summary

- Clear pass: 31 criteria
- Pass with concern: 3 criteria
- Fail: 0 criteria
- Not applicable: 1 criterion

The three current review risks are frontier difficulty calibration, verifier/reviewer size, and instruction length after adding the exactly-once request protocol. Any deterministic qualification failure supersedes this source-level assessment.

## Criterion review

| Criterion | Verdict | Review |
|---|---|---|
| `verifiable` | PASS | Programmatic verifier, independent reference model, deterministic pause/failpoint orchestration, pinned verifier tooling, Oracle/NOP separation, and explicit negative mutations for publication, lifecycle, and request-state defects. |
| `solvable` | PASS | A reference implementation exists for the full publication/lifecycle/request protocol. This remains contingent on the current-tree Oracle passing deterministic qualification. |
| `difficult` | CONCERN | The previous publication/GC tree was solved cleanly by Sol/xhigh. The redesign now composes MVCC publication with exactly-once request IDs, duplicate ownership, crash takeover, post-commit response loss, replay after GC, and an already-in-flight publisher race. Frontier calibration is still required. |
| `interesting` | PASS | The failure classes map to real build/distributed-service problems: lost cache updates, stale snapshots, duplicate requests, response-loss retries, crash takeover, and reclamation races. |
| `outcome_verified` | PASS | Runtime tests grade observable bytes, snapshots, reports, generation ordering/retention required by the contract, request replay behavior, progress, and recovery. They do not require a private `CURRENT` representation, request-journal path, filename layout, or specific lock implementation. |
| `anti_cheat_robustness` | PASS | Separate verifier keeps tests/reference/reward outside the agent image; candidate executions are unprivileged and descendants are cleaned up. Final `/cheat` trials remain required empirical evidence. |
| `task_security` | PASS | No credential reads/exfiltration, host escape, hidden network behavior, obfuscation, or unrelated destructive behavior in the task files. |
| `functional_verification` | PASS | Grading executes the candidate and inspects behavior; source-keyword or implementation-pattern checks do not determine reward. Mutation scripts are development checks, not candidate grading logic. |
| `deterministic_reproducible` | PASS | No task-relevant live service is required by the verifier; verifier packages are pinned; barriers and kernel-process lifetime replace timing/lease guesses. Current-tree repeatability still must be confirmed by qualification. |
| `essential_difficulty` | PASS | Difficulty comes from composing cache correctness, atomic publication, optimistic validation, lifecycle reclamation, and exactly-once request transactions rather than formatting or arbitrary thresholds. |
| `test_instruction_alignment` | CONCERN | Request-ID validation, duplicate ownership, response-loss, replay-after-GC, and publication-race assertions are explicitly stated in the instruction. The orchestration-heavy verifier increases reviewer burden and must be watched for accidental representation assumptions. |
| `novel` | PASS | The composed incremental-build + snapshot MVCC + exactly-once request state machine is not a textbook algorithm or memorized coding exercise. |
| `agentic` | PASS | Solving requires exploring an existing codebase, modifying multiple implementation modules, running/debugging concurrent processes, and reasoning from filesystem/process behavior. |
| `reviewable` | PASS | Independent reference logic, contract matrix, deterministic named tests, and targeted mutants make the intended semantics auditable. |
| `instruction_concision` | CONCERN | The instruction is outcome-focused and avoids prescribing a solution, but it is necessarily long because publication, reader/GC lifecycle, and exactly-once request semantics are all normative. Further requirements should not be added casually. |
| `solution_quality` | PASS | Oracle performs genuine incremental build/cache/publication/lifecycle/request work and does not encode fixture answers. |
| `separate_verifier_configured` | PASS | Only `/app/buildsys/` crosses as the candidate artifact; verifier truth and dependencies live in the verifier image. |
| `environment_hygiene` | PASS | Agent image contains the starter/project only; verifier-only tooling is isolated in `tests/Dockerfile`. |
| `structured_data_schema` | PASS | Build and GC report schemas are explicitly stated; request replay is defined as returning the exact original build report rather than introducing a hidden new schema. |
| `typos` | PASS | No known critical path, CLI, variable, or filename mismatch in the current source audit. Deterministic qualification remains the authoritative check. |
| `difficulty_explanation_quality` | PASS | Repository documentation explains why the clean Sol solve invalidated the prior tree and why the redesign changes the transaction model instead of adding model-specific traps. |
| `solution_explanation_quality` | PASS | The private reference demonstrates one valid strategy while the instruction leaves request-record representation and lock/journal layout open. |
| `verification_explanation_quality` | PASS | Contract coverage maps request replay, takeover, response-loss, publication races, GC, and privilege isolation to explicit tests/mutants. |
| `category_and_tags` | PASS | `Software / Systems` with build-system, caching, concurrency, transaction, incremental-build, and debugging tags fits the task. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive, kebab-case, and within current slug policy. |
| `resource_configuration` | PASS | 1 CPU / 2 GiB is modest; verifier timeout is ample; 4-hour agent timeout matches a difficult systems repair. |
| `task_readme` | PASS | Reviewer-facing documentation describes the task and current qualification status without becoming part of the agent-visible solution contract. |
| `expert_time_estimate` | PASS | Four hours remains plausible for a domain expert, though the request protocol raises the upper end compared with the solved predecessor. |
| `task_toml_schema` | PASS | Metadata/verifier/environment fields fit the previously checked live task schema; current-tree static checks must reconfirm. |
| `no_extraneous_files` | PASS | Task directory contains the task scaffold, starter, reference solution, verifier, and required reviewer documentation. |
| `artifact_efficiency` | PASS | Only `/app/buildsys/` is transferred; no generated dependency tree or large artifact is graded. |
| `verifier_execution_isolation` | PASS | Candidate subprocesses drop to `nobody`; hidden state stays root-owned; intentional concurrent siblings are distinguished from leaked descendants during cleanup. |
| `ctrf_reporting` | PASS | Pytest emits `/logs/verifier/ctrf.json` through the pinned plugin. |
| `do_not_modify_enforced` | N/A | The task protects behavior rather than declaring a concrete file immutable. |
| `binary_reward` | PASS | `test.sh` writes exactly `1` on complete pytest success and `0` otherwise. |

## Current conclusion

The redesign is ready for **deterministic qualification**, not yet for frontier measurement. If static/Oracle/mutation/Harbor qualification is green, then spend one clean frontier probe. If Sol solves the new tree, redesign at the task level again rather than adding trajectory-specific tests.
