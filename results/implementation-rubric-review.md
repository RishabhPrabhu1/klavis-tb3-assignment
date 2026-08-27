# Current TB3 Implementation-Rubric Self-Review

This is a source-level preflight, **not** a claim that Terminal-Bench's automated implementation-rubric reviewer has passed the task. The live rubric and live review workflow at Terminal-Bench HEAD `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` remain authoritative.

Current qualified candidate task tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

## Current status

The previously identified reviewer-facing cleanup has been applied and the resulting task tree has been requalified from scratch:

```text
TB3 static checks: PASS
Oracle/reference:  66/66
mutations:         40/40 rejected
Harbor Oracle:     1.000
Harbor NOP:        0.000
```

The cleanup did not alter `environment/`, `solution/`, or `tests/`. It only:

- compressed the statically required task README to non-duplicative reviewer context;
- aligned the best-case prepared-expert estimate to 3.5 hours;
- made a few coordination requirements outcome-oriented rather than prescribing a particular lock implementation;
- strengthened difficulty metadata with real-world role and synthetic-fixture provenance.

## Current risk summary

Most criteria are strong at source level. Remaining reviewer risks are narrower:

1. **`instruction_concision` — MODERATE RISK.** `instruction.md` remains long because it composes project publication, request replay, workspace capture, workspace transactions, reader lifetimes, and two reclamation layers. The length is mostly normative tested semantics rather than filler; further shortening risks creating test/instruction gaps.
2. **`difficult` — PENDING FINAL EMPIRICAL CALIBRATION.** Earlier simpler designs were solved by Sol. The current optimistic transaction tree is qualified, and the first same-tree frontier probe is now the active calibration gate.
3. **Automated implementation-rubric execution — OUTSTANDING.** The live reviewer uses Claude Code/Sonnet through Harbor 0.18.0. A source-level audit is not a substitute for that required review.

The earlier high-confidence `task_readme`, `expert_time_estimate`, and prescriptive `outcome_verified` risks were addressed before final qualification.

## Criterion review

| Criterion | Self-review | Notes |
|---|---|---|
| `verifiable` | PASS | Deterministic pause/failpoint schedules, independent reference logic, 66-test Oracle, 40 non-equivalent development mutants. |
| `solvable` | PASS | Working reference passes 66/66; 3.5h best-case expert estimate is aligned with few-hours guidance. |
| `difficult` | PENDING EMPIRICAL | Current optimistic multi-project transaction design is the final calibration object. |
| `interesting` | PASS | Build/release transaction consistency and crash recovery have direct systems-engineering value. |
| `outcome_verified` | PASS | Requirements now state observable serialization/progress/atomicity outcomes rather than a mandatory lock API. |
| `anti_cheat_robustness` | PASS SOURCE-LEVEL | Separate verifier, no verifier truth in agent image, candidate cannot modify verifier container. Final `/cheat` runs remain required empirically. |
| `task_security` | PASS | No credential exfiltration, host escape, obfuscation, or unrelated destructive behavior. |
| `functional_verification` | PASS | Verifier executes behavior; no candidate-source keyword/regex grading. |
| `deterministic_reproducible` | PASS | Exact current tree passed deterministic qualification; dependencies/tooling are pinned/baked and no task-relevant live service is required. |
| `essential_difficulty` | PASS | Difficulty is concurrency/recovery/reclamation reasoning, not formatting minutiae. |
| `test_instruction_alignment` | PASS WITH REVIEW COMPLEXITY | Tested concurrency/crash requirements map to explicit contract invariants; the surface is large but deliberate. |
| `novel` | PASS | Custom composition of multiple state machines, not a standard textbook exercise. |
| `agentic` | PASS | Requires repository exploration, multi-file implementation, process coordination, debugging, and repeated execution. |
| `reviewable` | PASS | Reviewer README, task metadata, reference implementation, deterministic schedules, and contract-coverage records expose rationale and behavior. |
| `instruction_concision` | MODERATE RISK | Long contract, but most prose defines observable semantics directly exercised by tests. |
| `difficulty_explanation_quality` | PASS | Names optimistic transaction conflict/merge/recovery crux, professional analogue, and synthetic fixture provenance. |
| `solution_explanation_quality` | PASS | Summarizes one valid private-evaluation/short-commit implementation without making it normative. |
| `verification_explanation_quality` | PASS | Describes behavioral schedules, crash boundaries, and mutation negative controls. |
| `category_and_tags` | PASS | `Software / Systems` with specific concurrency/transactions/build-system tags. |
| `task_name` | PASS | `build-snapshot-publish` is descriptive kebab-case. |
| `resource_configuration` | PASS | Within current TB3 8h cap; task difficulty is reasoning rather than compute. |
| `task_readme` | PASS SOURCE-LEVEL | Required README now contains concise reviewer context and avoids duplicating the full contract/reference. |
| `expert_time_estimate` | PASS SOURCE-LEVEL | 3.5h best-case prepared-expert estimate. |
| `task_toml_schema` | PASS | Static checks passed recognized fields/schema. |
| `no_extraneous_files` | PASS | Task-local files are used or statically required reviewer documentation. |
| `artifact_efficiency` | PASS | Only the necessary agent artifact surface crosses to the separate verifier. |
| `verifier_execution_isolation` | PASS | Separate verifier and explicit process cleanup. |
| `binary_reward` | PASS | Reward is binary verifier completion. |
| critical identifier/typo checks | PASS SOURCE-LEVEL | Current static checks and manual audit found no unresolved naming/path inconsistencies. |

## Representation-neutrality audit

Two verifier assumptions discovered during development were corrected rather than counted as model failures:

- transaction-private project history is no longer mistaken for ordinary project current;
- workspace transaction tests no longer require an uppercase `.workspace-cache/CURRENT` selector.

Current selection is resolved using documented generation metadata. Request-journal paths, selector filenames, lock filenames, lease representation, and staging layout are not prescribed.

## Automated-rubric execution

The live TB3 review workflow uses **Harbor 0.18.0** specifically for implementation autoreview, even though `/run` and `/cheat` use Harbor 0.14.0. It runs an ephemeral review task against `docs/prompts/task-implementation.toml` with Claude Code/Sonnet and requires a complete per-criterion verdict set.

`scripts/run-implementation-rubric-bedrock.sh` is the planned local equivalent for the zero-spend Bedrock route and records exact task-tree/upstream provenance.

**Automated rubric status remains outstanding. Do not state that the implementation rubric passed until a valid review completes with zero failed criteria.**

## Deadline decision rule

1. Preserve the qualified `fc064cac...` task tree while frontier calibration is running.
2. If the same-tree Sol probe returns a valid reward 0 from a real candidate implementation error under the clear contract, freeze immediately.
3. If it returns a clean solve, allow at most one targeted semantic strengthening before another full qualification cycle.
4. Do not alter task files for cosmetic rubric concerns while valid frontier evidence is being collected.
5. Run the automated implementation-rubric review on the frozen exact tree before final submission.
