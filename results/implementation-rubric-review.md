# Current TB3 Implementation-Rubric Self-Review

This is a source-level self-audit, **not** a claim that Terminal-Bench's automated implementation-rubric reviewer has passed the task. The live rubric remains authoritative.

Current candidate task tree:

```text
5620526fada6eebea16910fc62bf71746aaa40ea
```

## Summary

The current task is strong on functional verification, deterministic concurrency orchestration, verifier isolation, task realism, metadata completeness, and resource configuration. Two reviewer-facing criteria deserve explicit attention before final submission:

1. **instruction_concision** — the instruction is long because the task composes project publication, exactly-once requests, workspace snapshots, optimistic transactions, reader liveness, and two GC layers. It is outcome-oriented, but its length and detailed concurrency constraints may still draw a rubric concern.
2. **task_readme** — the optional task-local `README.md` currently repeats substantial task/solution/verification material. The current rubric says an optional README should provide reviewer context not already present in instruction/solution/task.toml, and may fail if it duplicates those sources. If no usable same-tree frontier evidence would be invalidated, deleting the optional task README before final qualification is safer than carrying duplicative content.

Do not change the formal task tree solely for reviewer aesthetics until interrupted same-tree evidence has been inspected.

## Criterion review

| Criterion | Self-review | Notes |
|---|---|---|
| `verifiable` | PASS | Independent reference output logic, deterministic pause/failpoint schedules, reference solution, 66-test Oracle target, 40 non-equivalent mutants. |
| `difficult` | PENDING EMPIRICAL | Earlier workspace tree was solved. Optimistic multi-project transaction redesign is the current calibration object. |
| `outcome_verified` | PASS | Candidate behavior is executed; tests do not grep source or enforce a specific lock/journal implementation. Explicit storage paths inspected by tests are documented task outputs/state. |
| `anti_cheat_robustness` | PASS SOURCE-LEVEL | Separate verifier, unprivileged candidate process, process cleanup, no live verifier network. Final `/cheat` matrices remain required. |
| `functional_verification` | PASS | Runtime behavior only; mutation scripts are development checks and are not verifier reward logic. |
| `deterministic_reproducible` | PASS PENDING CURRENT-TREE RERUN | No task-relevant live service; deterministic process barriers/failpoints; dependencies pinned in verifier image. |
| `agentic` | PASS | Requires multi-file implementation, debugging, concurrency/process interaction, repeated terminal execution. |
| `reviewable` | PASS | Task metadata, independent verifier, contract coverage, named tests, and mutation rationale expose intended invariants. |
| `instruction_concision` | CONCERN | ~18 KB instruction is much longer than ideal. The content is normative/outcome-oriented rather than a step-by-step solution, but the live rubric explicitly prefers concise instructions. |
| `solution_explanation_quality` | PASS | `task.toml` summarizes private-evaluation/short-commit optimistic strategy at a high level. |
| `verification_explanation_quality` | PASS | Metadata plus `results/contract-coverage.md` explain deterministic behavioral coverage. |
| `category_and_tags` | PASS | `Software / Systems`, specific concurrency/build/transaction tags. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive, kebab-case, and three tokens. |
| `resource_configuration` | PASS | Agent 14400s, verifier 900s, 1 CPU/2 GiB/10 GiB; below current 5-hour timeout cap and difficulty is reasoning rather than compute. |
| `task_readme` | **RISK / LIKELY CONCERN** | Optional README currently duplicates large portions of instruction, solution explanation, and verification explanation. Current rubric explicitly discourages duplication. Safest final state may be no task-local README. |
| `expert_time_estimate` | PASS WITH CONCERN | 6.0h is nonzero and plausible for the composed system, though it exceeds the 4h agent timeout. Reviewers may ask whether a perfectly prepared expert can complete within the intended benchmark window. |
| `task_toml_schema` | PASS | Current recognized metadata/verifier/agent/environment fields only; separate-verifier artifacts are valid. |
| `no_extraneous_files` | PASS EXCEPT README QUESTION | Core scaffold/environment/solution/tests are used. Optional README is allowed structurally, but its duplicated content creates the separate `task_readme` concern above. |
| `artifact_efficiency` | PASS | Only `/app/buildsys/` crosses to verifier; no large generated artifacts are shipped. |
| `verifier_execution_isolation` | PASS | Candidate subprocesses drop to `nobody`; verifier/reference stay separate; detached candidate processes are cleaned. |
| `binary_reward` | PASS | Verifier success is binary pytest completion. |

## Representation-neutrality audit

Two verifier assumptions were discovered during development and corrected rather than counted as model failures:

- transaction-private project history is no longer mistaken for ordinary project current;
- workspace transaction tests no longer require an uppercase `.workspace-cache/CURRENT` selector.

Current direct verifier inspection of `.build-cache/generations`, `.build-cache/objects`, `.workspace-cache/generations`, records, and `snapshot.json` is aligned with paths explicitly specified in the instruction. Current-selection pathname, request-journal layout, claim files, lock files, lease files, and private staging layout are not prescribed.

## Automated-rubric status

**Outstanding.** The static shell checks are not the same as Terminal-Bench's LLM implementation-rubric reviewer. Do not state that the implementation rubric has passed until an authoritative automated review has been run or Klavis accepts an equivalent review process.

## Deadline decision

If interrupted current-tree frontier evidence is incomplete, the highest-value pre-final-tree cleanup is likely:

1. remove the optional duplicative task-local README (making `task_readme` N/A), then
2. requalify the resulting task tree once, and
3. run the authoritative implementation rubric before spending the final model matrices.

Do **not** perform that tree change until existing `5620526f...` evidence is inspected, because any formal task-tree change invalidates same-tree qualification/frontier evidence.
