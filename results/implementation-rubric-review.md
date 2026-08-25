# Current TB3 implementation-rubric review

This is a **reviewer-side assessment**, not a claim that Terminal-Bench's automated `/review` workflow ran. It uses the live `rubrics/task-implementation.toml` recorded at upstream commit `405a783ea111ab855718ce93b2b0cadaa2e8d47f`. The official TB3 workflow runs its own model reviewer through Harbor and should be treated as separate evidence if it is later available.

## Summary

- Clear pass: 32 criteria
- Pass with concern: 3 criteria
- Fail: 0 criteria
- Not applicable: 1 criterion

The implementation has no current verifier/correctness blocker in this review. The remaining uncertainty is mostly **difficulty calibration**, plus two review-quality concerns: the verifier is longer than TB3's preferred concise shape, and the public repository should not remain discoverable during adversarial/frontier trials because it contains the exact oracle and tests.

## Criterion review

| Criterion | Verdict | Review |
|---|---|---|
| `verifiable` | PASS | Exact programmatic assertions, independent clean reference model, deterministic fixtures, pinned verifier tooling, and successful Oracle/NOP separation. |
| `solvable` | PASS | A working reference repair is provided and passed the current verifier through Harbor. The implementation is substantial but still a few-hours systems repair rather than a multi-day build. |
| `difficult` | CONCERN | The core is a real crash-consistency/publication abstraction error rather than a local bug. However, the observable snapshot invariant is stated clearly and may make the correct architectural direction discoverable to strong systems-capable agents. Frontier diagnostics are still required before treating difficulty as calibrated. |
| `interesting` | PASS | Atomic publication of related build artifacts while preserving incremental reuse is a real build/release-infrastructure problem. |
| `outcome_verified` | PASS | Tests grade bytes, cache behavior, reports, recovery, and visibility invariants; they do not require the oracle's generation/symlink implementation. |
| `anti_cheat_robustness` | CONCERN | Separate-verifier isolation and the normal-build publication observer close the earlier failpoint-only shortcut. The remaining operational risk is that this standalone repo is currently public and contains exact tests/oracle; make it private before frontier or `/cheat` trials so internet discovery is not an avoidable shortcut. |
| `task_security` | PASS | Reviewed task setup/verifier code is task-scoped; no credential exfiltration, host escape, obfuscated payload, or unrelated destructive behavior was found. |
| `functional_verification` | PASS | Candidate code is executed and outputs/state are checked; source keywords or implementation patterns are not used for reward. |
| `deterministic_reproducible` | PASS | Fixtures and expected results are deterministic, dependencies are pinned where appropriate, and no task-relevant live service is used during verification. |
| `essential_difficulty` | PASS | The distinguishing failure is mixed-snapshot publication under interruption/observation while retaining incremental semantics, not formatting trivia. |
| `test_instruction_alignment` | CONCERN | Assertions map closely to the stated CLI, exact report schema, incremental/recovery requirements, failpoint behavior, and snapshot invariant. The verifier is nevertheless much larger than TB3's "ideally under ~100 lines" preference; modularization helps, but reviewer burden remains above ideal. |
| `novel` | PASS | This is a custom build tool and a combined cache/publication failure mode, not a textbook algorithm or memorized benchmark exercise. |
| `agentic` | PASS | A legitimate repair requires repository exploration, understanding the existing cache/build graph, implementing a state-publication design, and iterating against behavior. |
| `reviewable` | PASS | Task README and metadata explain the failure mode, reference strategy, and verification architecture for non-specialists. |
| `instruction_concision` | PASS | The instruction is compact and outcome-oriented. The snapshot and failpoint paragraphs specify observable requirements; they do not require generations, symlinks, staging directories, or any other oracle architecture. |
| `solution_quality` | PASS | `solve.sh` installs a separate full implementation file; the oracle performs genuine build/cache/publication computation rather than printing fixture answers. |
| `separate_verifier_configured` | PASS | Only `/app/buildsys/` is transferred; verifier truth/tests are baked into the verifier image and verifier dependencies are preinstalled. |
| `environment_hygiene` | PASS | Agent image contains only the build tool/project; tests and verifier-only dependencies live in `tests/Dockerfile`. |
| `structured_data_schema` | PASS | The report JSON object and all nested exact field sets/types are normatively specified in `instruction.md`. |
| `typos` | PASS | No critical path, command, filename, or variable-name typo found in the reviewed contract/scaffold. |
| `difficulty_explanation_quality` | PASS | Metadata identifies the non-local snapshot-validity problem, explains the synthetic-but-realistic graph, and names build/release infrastructure as the real-world setting. |
| `solution_explanation_quality` | PASS | Metadata explains stage/validate/commit visibility at a high level and explicitly says this is one valid strategy rather than a required implementation. |
| `verification_explanation_quality` | PASS | Metadata accurately explains clean-reference comparison, cache/recovery checks, cooperative boundaries, external ordinary-build observation, and privilege separation. |
| `category_and_tags` | PASS | `Software / Systems` and build-system/cache/dependency/debugging tags fit the primary task. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive, kebab-case, and exactly three tokens. |
| `resource_configuration` | PASS | 1 CPU / 2 GiB is modest; verifier 600 s is ample for a short deterministic suite; 4-hour agent timeout is consistent with TB3's hard-task target. |
| `task_readme` | PASS | The README adds reviewer-facing rationale, verification architecture, calibration mutants, and relevant-experience disclosure required by the current contributor checks. |
| `expert_time_estimate` | PASS | 4.0 hours is plausible for an expert who already recognizes the publication abstraction, though frontier trials may indicate the task is easier for current agents than for the intended human calibration. |
| `task_toml_schema` | PASS | Current fields are within the live rubric's allowed schema; `subcategory` is explicitly valid in the current TB3 rubric. |
| `no_extraneous_files` | PASS | Task directory contains only scaffold, environment, solution, verifier, and reviewer README content. |
| `artifact_efficiency` | PASS | The only artifact is the small agent-edited `/app/buildsys/` deliverable; no dependency tree or large fixed dataset is transferred. |
| `verifier_execution_isolation` | PASS | Candidate code runs after dropping to `nobody`; stdout/stderr are file-backed; candidate UID processes and the process group are killed/reaped; reward state stays root-owned. |
| `ctrf_reporting` | PASS | Pytest writes `/logs/verifier/ctrf.json`. |
| `do_not_modify_enforced` | N/A | The instruction specifies behavioral preservation (`keep interface working`, preserve incremental behavior) rather than protecting a concrete file from modification. Those behavioral requirements are directly tested. |
| `binary_reward` | PASS | `test.sh` writes exactly `1` on pytest success and `0` otherwise. |

## Manual-review conclusion

The task is ready to move to **difficulty/adversarial evaluation**, not ready to declare complete. Before those trials, remove the avoidable public-oracle discovery risk. Then run one valid diagnostic for each current default frontier agent. A clean solve by either model is evidence that the core task may be too easy; do not compensate by adding arbitrary edge cases. If both fail for the intended publication-consistency reason, freeze the task and spend the final 3+3 standard matrix, followed by the current one-attempt-per-agent adversarial matrix.
