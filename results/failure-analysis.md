# Failure Analysis

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

This is the only task tree whose model results may count toward the final Klavis matrix.

Deterministic qualification is complete:

```text
static checks:      PASS
Oracle/reference:   68/68
Harbor Oracle/NOP:  1/0
model calls during deterministic qualification: 0
```

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected 40/40 development mutation controls. The frozen successor changes only verifier teardown/reaping hygiene in `tests/conftest.py`; it reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP.

Automated implementation-rubric acceptance remains outstanding. It was **not run in this submission because Claude access is unavailable**; no source-level assessment or alternate model is treated as an automated PASS. The required Claude Code / Opus 5 standard and adversarial results were likewise not executed and remain explicitly incomplete.

## Standard-trial validity

A `/run` trial counts as a model failure only when all of the following hold:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
verifier completed normally
```

Authentication, provider/quota, timeout, container, Harbor, verifier, or other execution failures do not count as standard model failures.

For `/cheat`, the pinned live Terminal-Bench workflow is reward-based: every task × agent adversarial entry must receive reward `0`; any nonzero reward fails the requirement. This acceptance rule is intentionally distinct from standard `/run` validity.

## Failure categories

- `F1` — conceptual/architectural implementation failure.
- `F2` — localized implementation/debugging failure under an otherwise viable approach.
- `F3` — specification ambiguity or reasonable interpretation mismatch; repair the task.
- `F4` — verifier defect or hidden representation assumption; repair the verifier.
- `F5` — runtime/container/infrastructure failure.
- `F6` — auth/provider/model/tooling failure.
- `F7` — other invalid/non-difficulty evidence, including suspicious shortcut behavior.

Only F1/F2-style genuine candidate failures under a clear contract can satisfy the standard-failure requirement. F3-F7 do not.

## Final-tree counted trials

The exact-tree Codex collector completed with `valid_sol_xhigh_failures=3`, `target=3`, and `status=SOL_MATRIX_COMPLETE` on execution commit `90ba6964ae64fa04be2e58162c59b0be186023d8`.

### Codex / GPT-5.6 Sol / xhigh — standard trial 1

```text
evidence: ~/.cache/klavis-tb3-runs/transaction-standard-probe/20260828T013339Z-85607-standard-codex-90ba6964ae64
runtime: 32m46s
Harbor exit status: 0
authoritative reward: 0.0
verifier: 62 passed / 6 failed / 0 skipped
```

Primary failures: selective cache invalidation plus GC/reclamation behavior around concurrent commits/readers, live-writer private objects, stale writer bases, and crashed-writer leases.

Classification: **F1/F2 genuine implementation failure**. These are explicit observable requirements in `instruction.md`, not source-layout assumptions. No provider/auth/quota, Harbor, verifier, hidden-representation, or specification contamination was observed. **Counts as Codex standard failure 1/3.**

### Codex / GPT-5.6 Sol / xhigh — standard trial 2

```text
evidence: ~/.cache/klavis-tb3-runs/transaction-standard-final/20260828T020940Z-87647-standard-codex-90ba6964ae64
runtime: 31m00s
Harbor exit status: 0
authoritative reward: 0.0
verifier: 64 passed / 4 failed / 0 skipped
```

Failed tests:

- `test_build_cache.py::test_unrelated_input_and_target_definition_invalidate_selectively`
- `test_reclamation_interleavings.py::test_gc_preserves_private_objects_of_live_writer`
- `test_reclamation_interleavings.py::test_gc_can_reclaim_writer_base_without_losing_later_commit_state`
- `test_reclamation_interleavings.py::test_crashed_writer_lease_does_not_prevent_later_object_reclamation`

Classification: **F1/F2 genuine implementation failure**. All four checks exercise explicit selective-invalidation and reclamation/writer-liveness invariants already validated as representation-neutral. Harbor completed normally with no trial exceptions. **Counts as Codex standard failure 2/3.**

### Codex / GPT-5.6 Sol / xhigh — standard trial 3

```text
evidence: ~/.cache/klavis-tb3-runs/transaction-standard-final/20260828T024042Z-89033-standard-codex-90ba6964ae64
runtime: 30m31s
Harbor exit status: 0
authoritative reward: 0.0
verifier: 54 passed / 14 failed / 0 skipped
```

Failure surface:

- exactly-once durability of stranded committed requests across later publication and GC;
- preservation of stranded request state by an older in-flight ordinary publisher;
- commit-order and KEEP-budget reclamation;
- live-reader pinning, killed-reader release, and last-reader lifetime;
- GC revalidation after concurrent commit and reader acquisition;
- paused-writer protection and later sweep;
- interrupted-GC recovery;
- live-writer private-object protection;
- safe stale-writer-base reclamation;
- eventual reclamation after a crashed writer lease.

Classification: **F1/F2 genuine implementation failure**. Every listed area corresponds directly to the documented exactly-once, reader/GC, KEEP, crash-recovery, writer-protection, and reclamation contract. No provider/auth/quota, Harbor, verifier, hidden-representation, or specification contamination was observed. **Counts as Codex standard failure 3/3.**

## Codex standard conclusion

The frozen task has the required **3/3 valid GPT-5.6 Sol/xhigh standard reward-0 failures**.

## Codex adversarial conclusion

The same frozen task also completed the Codex `/cheat` requirement on execution commit `90ba6964ae64fa04be2e58162c59b0be186023d8` with `openai/gpt-5.6-sol`, `xhigh`, and pinned Terminal-Bench revision `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480`.

```text
reward: 0.0
reward_zero=1
target=1
nonzero=0
unparsed=0
incomplete=0
wrong_tb3_provenance=0
status=CHEAT_MATRIX_COMPLETE
```

The Harbor result included `NonZeroAgentExitCodeError`; under the pinned adversarial workflow, `/cheat` acceptance is reward-based rather than governed by the standard-run validity rule. The exact-tree collector therefore records the Codex adversarial requirement as **1/1 COMPLETE — reward 0**. Full details are in `results/cheat-trials.md`.

## Historical calibration

### Workspace snapshot design — solved

Tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` produced a clean GPT-5.6 Sol/xhigh solve (`reward = 1`, `58 passed / 0 failed`). Classification: valid solve; the task was strengthened.

### Optimistic transaction predecessor — verifier defect

Tree `40cbd34104e1f0a549be23b46ef70655b728cece` returned reward 0 with 61 passed / 5 failed, but those failures depended on a verifier helper requiring `.workspace-cache/CURRENT`, which the contract did not prescribe. Classification: `F4`; the verifier was made representation-neutral and the run does not count.

### Difficulty calibration tree — genuine Sol failure

Tree `fc064cac2fb1241b68a98475dbc8ea04fbe579cc` passed its then-current deterministic qualification and produced a clean GPT-5.6 Sol/xhigh reward-0 run with `45 passed / 21 failed` in `29m44s`. Later verifier/schema/process review superseded that tree, so it remains difficulty calibration only.

## Corrections made before the frozen tree

Review of calibration and intermediate successors corrected fixed-path workspace-current observation, ordinary-current inference, private replay dependencies, undocumented committed-record assumptions, candidate-process isolation, response-loss ordering, duplicate ownership semantics, over-prescriptive transaction wording, exact retry-count assumptions, and verifier teardown zombie contamination. These were treated as task/verifier defects rather than model failures.

## Freeze rule for the final tree

For `d862ab3cc79718e959e9cc7ec1b792540990a24d`:

- valid standard reward `1` would fail the required standard-failure matrix;
- valid standard reward `0` caused by genuine candidate implementation error counts;
- `F3/F4` would require a new task-tree hash and complete requalification;
- `F5/F6/F7` does not count;
- the task tree remained frozen throughout standard and adversarial Codex evaluation;
- all controllable Codex evaluation is complete;
- full TB3 compliance still requires the Claude-dependent automated rubric, three Opus 5/max standard failures, and Claude reward-0 adversarial entry;
- because Claude access is unavailable, this submission remains explicitly incomplete on that portion rather than claiming full readiness.
