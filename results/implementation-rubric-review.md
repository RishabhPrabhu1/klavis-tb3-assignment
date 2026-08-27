# Current TB3 implementation-rubric review

This is a reviewer-side assessment, not a claim that Terminal-Bench's automated `/review` workflow ran. It was originally audited against the live rubric blob `5a88f5f89bdfc3b633c06e3dc06486fc9385e2b7`. At upstream `b2d4a935cfb1a6f621f611ea69421039cfccd158` on August 26, 2026, that exact unchanged blob now lives at `docs/prompts/task-implementation.toml` after the upstream documentation-layout refactor.

## Summary

- Clear pass: 32 criteria
- Pass with concern: 2 criteria
- Fail: 0 criteria
- Not applicable: 1 criterion

No correctness, security, or verifier-alignment blocker is currently known. The two remaining review risks are frontier difficulty calibration and verifier/reviewer size.

## Criterion review

| Criterion | Verdict | Review |
|---|---|---|
| `verifiable` | PASS | Programmatic verifier, independent reference model, deterministic pause/failpoint orchestration, pinned verifier tooling, repeated Oracle regression, and Oracle/NOP separation. |
| `solvable` | PASS | The reference repair passes the full suite. Its core design is substantial but remains a few-hours systems implementation for an expert who already understands the transaction/concurrency requirements. |
| `difficult` | CONCERN | The redesigned task combines crash consistency, exact snapshot publication, optimistic stable-input validation, concurrent writers, and lost-update avoidance while preserving selective caching. This is materially harder than the earlier single-generation insight, but final calibration still requires the frontier trials. |
| `interesting` | PASS | The failure class maps directly to concurrent build/artifact publication systems: stale artifacts, lost cache updates, interrupted writers, and input races. |
| `outcome_verified` | PASS | Runtime tests grade observable bytes, snapshots, reports, cache reuse, progress, and recovery. Generations, symlinks, locks, journals, or any other oracle mechanism are not required. |
| `anti_cheat_robustness` | PASS | Repository is private during calibration; separate verifier keeps tests/reference/reward outside the agent image; candidate executions are unprivileged and descendants are cleaned up. Final `/cheat` trials remain required empirical evidence. |
| `task_security` | PASS | No credential reads/exfiltration, host escape, hidden network behavior, obfuscation, or unrelated destructive behavior in the task files. |
| `functional_verification` | PASS | Grading executes the candidate and inspects behavior; no source-keyword or implementation-pattern checks determine reward. |
| `deterministic_reproducible` | PASS | No task-relevant live service is required by the verifier; Python verifier packages are pinned; deterministic barriers replace timing guesses; the Oracle suite is now repeated in CI. |
| `essential_difficulty` | PASS | Difficulty comes from composing cache correctness, atomic publication, optimistic validation, and concurrent commit semantics, not formatting or arbitrary thresholds. |
| `test_instruction_alignment` | CONCERN | Current behavioral assertions map to explicit instruction requirements, including exact closure, failpoint, concurrency, and stable-input semantics. The suite is necessarily orchestration-heavy and some verifier modules exceed TB3's preferred concise shape, increasing reviewer burden. |
| `novel` | PASS | Custom incremental-build state machine plus crash/concurrency interaction is not a textbook exercise or memorized algorithm. |
| `agentic` | PASS | Solving requires exploring an existing codebase, modifying implementation files, running/debugging the system, and reasoning from observed process/filesystem behavior. |
| `reviewable` | PASS | Independent reference logic, explicit metadata explanations, contract matrix, deterministic tests, and named mutants make the intended semantics auditable. |
| `instruction_concision` | PASS | No headings, roleplay, tool list, or solution recipe. The longer paragraphs are normative because the benchmark now has concurrency and stable-input semantics; wording is outcome-focused rather than prescribing locks/revalidation architecture. |
| `solution_quality` | PASS | Oracle performs genuine incremental build/cache/transaction work and does not encode fixture answers. |
| `separate_verifier_configured` | PASS | Only `/app/buildsys/` crosses as the candidate artifact; verifier truth and dependencies live in the verifier image. |
| `environment_hygiene` | PASS | Agent image contains the starter/project only; verifier-only tooling is isolated in `tests/Dockerfile`. |
| `structured_data_schema` | PASS | Exact report top-level/event/output schemas and dependency semantics are explicitly stated. |
| `typos` | PASS | No known critical path, CLI, variable, or filename mismatch in the current task contract. |
| `difficulty_explanation_quality` | PASS | Metadata describes transactional build state, interrupted work, disjoint concurrent progress, and lost-update/stale-input hazards. |
| `solution_explanation_quality` | PASS | Metadata explains one valid private-evaluation/short-commit/merge strategy and explicitly leaves alternate implementations legal. |
| `verification_explanation_quality` | PASS | Metadata describes independent expected results, failpoints, deterministic concurrency, stable-input tests, and privilege isolation. |
| `category_and_tags` | PASS | `Software / Systems` with build-system, caching, concurrency, transaction, incremental-build, and debugging tags fits the task. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive, kebab-case, and within current slug policy. |
| `resource_configuration` | PASS | 1 CPU / 2 GiB is modest; verifier timeout is ample; 4-hour agent timeout matches a difficult systems repair. |
| `task_readme` | PASS | Reviewer-facing documentation describes the task and validation without being part of the agent-visible solution contract. |
| `expert_time_estimate` | PASS | Four hours remains plausible for a domain expert who recognizes the required concurrency architecture. |
| `task_toml_schema` | PASS | Current metadata/verifier/environment fields fit the live task schema and pass live static checks. |
| `no_extraneous_files` | PASS | Task directory contains only task scaffold, environment, solution, verifier, and required reviewer documentation. |
| `artifact_efficiency` | PASS | Only the small `/app/buildsys/` implementation is transferred; no large generated dependency tree is graded. |
| `verifier_execution_isolation` | PASS | Candidate subprocesses drop to `nobody`; hidden state stays root-owned; process groups and detached candidate-UID descendants are terminated/reaped. |
| `ctrf_reporting` | PASS | Pytest emits `/logs/verifier/ctrf.json` through the pinned plugin. |
| `do_not_modify_enforced` | N/A | The task protects behavior rather than declaring a concrete file immutable. |
| `binary_reward` | PASS | `test.sh` writes exactly `1` on complete pytest success and `0` otherwise. |

## Current conclusion

The task is ready for frontier difficulty measurement. Do not add more requirements in response to individual model trajectories. If the frozen redesign is solved cleanly by a frontier model, treat that as task-level difficulty evidence rather than inventing another trajectory-specific verifier trap.
