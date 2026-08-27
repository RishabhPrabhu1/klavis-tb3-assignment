# Current TB3 Implementation-Rubric Self-Review

This is a source-level preflight, **not** a claim that Terminal-Bench's automated implementation-rubric reviewer has passed the task. The live rubric and live review workflow at Terminal-Bench HEAD `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` remain authoritative.

Current candidate task tree:

```text
5620526fada6eebea16910fc62bf71746aaa40ea
```

## Important static/rubric interaction

The live implementation rubric describes task-local `README.md` as optional and says a duplicative README should fail `task_readme`. However, the **live static check** `scripts/checks/check-task-fields.sh` requires every task to contain `README.md` with these four headings:

```text
## Difficulty explanation
## Solution explanation
## Verification explanation
## Relevant experience
```

Therefore **do not delete the task README**. Deletion would make the rubric criterion N/A in isolation but would fail the mandatory static pipeline. The correct cleanup, if a new task tree is unavoidable, is to keep a short reviewer/maintainer-context README with those four headings while removing duplicated contract/solution prose.

## Current risk summary

Most criteria are strong at source level. Four reviewer-facing risks deserve attention:

1. **`task_readme` — HIGH CONFIDENCE RISK.** The current ~12 KB task README repeats substantial instruction, solution, verification, and metadata content. The live rubric explicitly says that duplication is a FAIL condition.
2. **`expert_time_estimate` / `solvable` — MODERATE RISK.** `expert_time_estimate_hours = 6.0`, while the live rubric defines this as a best-case fully prepared expert and says a working solution should be implementable in a few hours at most. A 3.5-hour estimate is more consistent with the 4-hour agent timeout and the existence of a working reference implementation.
3. **`outcome_verified` — MODERATE RISK.** Most requirements are behavioral, but one transaction sentence currently instructs the candidate to acquire named classes of publication locks in canonical order. The verifier needs the resulting serialization/progress/deadlock properties, not one particular lock API. Outcome-oriented wording is safer.
4. **`instruction_concision` — MODERATE/HIGH RISK.** `instruction.md` is ~18 KB because the contract composes several state machines. Most of the length is genuine tested semantics rather than fluff, but the live rubric strongly prefers brief human-written instructions. This risk cannot be eliminated merely by cosmetic rewriting without potentially losing test/instruction alignment.

A prepared but **not applied** script exists at `scripts/apply-deadline-rubric-cleanup.sh`. It is pinned to `5620526f...` and currently proposes only:

- outcome-neutral wording for the commit-coordination requirement;
- replacing the duplicative task README with concise required reviewer-context sections;
- changing expert best-case estimate from 6.0h to 3.5h.

It intentionally does not rewrite the whole instruction or alter tests/reference semantics.

Do not apply it until interrupted same-tree Work evidence is inspected. Any task-file edit changes the task tree and invalidates existing same-tree qualification/frontier evidence.

## Criterion review

| Criterion | Self-review | Notes |
|---|---|---|
| `verifiable` | PASS | Independent reference output logic, deterministic pause/failpoint schedules, reference solution, 66-test Oracle target, 40 non-equivalent mutants. |
| `solvable` | PASS WITH METADATA RISK | Working reference exists and prior strong agents implemented the architecture within one trial; 6h best-case expert estimate is the concern, not demonstrated solvability. |
| `difficult` | PENDING EMPIRICAL | Earlier workspace design was solved; optimistic multi-project transaction design is the current calibration object. |
| `interesting` | PASS | Build/release transaction consistency and crash recovery have direct real-world systems value. |
| `outcome_verified` | PASS WITH WORDING RISK | Tests execute behavior and allow representation freedom; one lock-order sentence is more prescriptive than necessary. |
| `anti_cheat_robustness` | PASS SOURCE-LEVEL | Separate verifier, unprivileged candidate processes, no verifier truth in agent image. Final `/cheat` matrices remain required empirically. |
| `task_security` | PASS | No credential collection/exfiltration, host escape, obfuscated payloads, or unrelated destructive behavior. |
| `functional_verification` | PASS | Runtime behavior only; verifier does not grep candidate source for implementation keywords. |
| `deterministic_reproducible` | PASS PENDING CURRENT-TREE RERUN | Deterministic barriers/failpoints, no task-relevant live services, verifier dependencies baked/pinned. |
| `essential_difficulty` | PASS | Difficulty is concurrency/recovery/reclamation composition, not formatting or arbitrary precision. |
| `test_instruction_alignment` | PASS WITH REVIEW COMPLEXITY | Contract is intentionally detailed because concurrency/crash behaviors are directly exercised. Test files are longer than rubric's ideal but assertions map to explicit invariants. |
| `novel` | PASS | Novel composition in custom codebase, not a memorized textbook exercise. |
| `agentic` | PASS | Multi-file implementation, process interaction, debugging, repeated terminal execution. |
| `reviewable` | PASS | Named behaviors, reference solution, deterministic schedules, metadata explanations, and contract-coverage record. |
| `instruction_concision` | **RISK** | ~18 KB. Mostly normative behavior, but substantially longer than rubric preference. |
| `difficulty_explanation_quality` | PASS | Metadata identifies optimistic transaction conflict/merge/recovery crux and real systems context. |
| `solution_explanation_quality` | PASS | `task.toml` summarizes private-evaluation/short-commit strategy and crash recovery at a high level. |
| `verification_explanation_quality` | PASS | Metadata explains concrete behavioral schedules and mutation coverage. |
| `category_and_tags` | PASS | `Software / Systems`; specific build/concurrency/transaction tags. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive kebab-case and three tokens. |
| `resource_configuration` | PASS | Agent 14400s, verifier 900s, 1 CPU/2 GiB/10 GiB; below current 8-hour TB3 cap and difficulty is reasoning rather than compute. |
| `task_readme` | **HIGH-CONFIDENCE RISK** | README is statically required but current content substantially duplicates other task sources. Keep it, compress it. |
| `expert_time_estimate` | **RISK** | 6.0h may conflict with best-case/few-hours guidance; prepared cleanup uses 3.5h. |
| `task_toml_schema` | PASS | Recognized metadata/verifier/agent/environment fields only. |
| `no_extraneous_files` | PASS | Core scaffold and environment fixtures are used; task README is statically required. |
| `artifact_efficiency` | PASS | Only `/app/buildsys/` crosses to verifier. |
| `verifier_execution_isolation` | PASS | Separate verifier; candidate subprocesses drop privilege; process cleanup is explicit. |
| `binary_reward` | PASS | Verifier success is binary pytest completion. |
| critical identifier/typo checks | PASS SOURCE-LEVEL | Current command/path/metadata names are internally consistent in audited files. |

## Representation-neutrality audit

Two verifier assumptions were discovered during development and corrected rather than counted as model failures:

- transaction-private project history is no longer mistaken for ordinary project current;
- workspace transaction tests no longer require an uppercase `.workspace-cache/CURRENT` selector.

Current direct verifier inspection of `.build-cache/generations`, `.build-cache/objects`, `.workspace-cache/generations`, records, and `snapshot.json` is aligned with paths explicitly specified in the instruction. Current-selector pathname, request-journal layout, claim files, lock files, lease files, and private staging layout are not prescribed.

## Automated-rubric execution

The live TB3 review workflow currently installs **Harbor 0.18.0 specifically for implementation autoreview**, even though `/run` and `/cheat` use Harbor 0.14.0. It invokes `harbor exec` with the live `docs/prompts/task-implementation.toml`, shared reviewer instruction, `claude-code`, and `sonnet`.

`scripts/run-implementation-rubric-bedrock.sh` mirrors that shape for the zero-spend Bedrock path and is pinned to the current TB3 HEAD. Its parser now honors the upstream verdict shape `checks.<criterion>.outcome = pass|fail|not_applicable`.

**Automated rubric status remains outstanding.** Do not state that the implementation rubric passed until a valid authoritative-equivalent review completes with zero failed criteria.

## Deadline decision rule

1. First inspect/resume interrupted evidence on exact tree `5620526f...`.
2. If that tree produced a valid genuine reward-0 model failure and time is extremely tight, weigh preserving the evidence against the known rubric risks before changing any task file.
3. If the current evidence is incomplete, invalid, or a clean solve, apply the prepared minimal rubric cleanup before the next qualification so we do not spend another full frontier cycle on a tree likely to fail autoreview.
4. After any cleanup: commit once, record new task tree, repin execution guards, run full zero-model qualification, then run the rubric and frontier gates on that exact tree.
