# Failure Analysis

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

This is the only task tree whose frontier results may count toward the final Klavis matrix.

Deterministic qualification is complete:

```text
static checks:      PASS
Oracle/reference:   68/68
Harbor Oracle/NOP:  1/0
frontier calls during deterministic qualification: 0
```

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected 40/40 development mutation controls. The frozen successor changes only verifier teardown/reaping hygiene in `tests/conftest.py`; it reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP.

Automated implementation-rubric acceptance remains outstanding. It is **not run in this submission because Claude access is unavailable**; no source-level assessment or alternate model is treated as an automated PASS. The required Claude Code / Opus 5 standard and adversarial results are likewise not being executed and remain explicitly incomplete.

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

### Codex / GPT-5.6 Sol / xhigh — standard trial 1

```text
execution commit: 90ba6964ae64fa04be2e58162c59b0be186023d8
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
evidence directory: ~/.cache/klavis-tb3-runs/transaction-standard-probe/20260828T013339Z-85607-standard-codex-90ba6964ae64
runtime: 32m46s
execution_class: valid-completed-trial
qualification_valid: true
result_exception_types: []
Harbor exit status: 0
authoritative reward: 0.0
verifier: 62 passed / 6 failed / 0 skipped
```

Failed tests:

- `test_build_cache.py::test_unrelated_input_and_target_definition_invalidate_selectively`
- `test_reclamation.py::test_gc_revalidates_after_concurrent_commit`
- `test_reclamation.py::test_gc_revalidates_reader_pin_acquired_during_scan`
- `test_reclamation_interleavings.py::test_gc_preserves_private_objects_of_live_writer`
- `test_reclamation_interleavings.py::test_gc_can_reclaim_writer_base_without_losing_later_commit_state`
- `test_reclamation_interleavings.py::test_crashed_writer_lease_does_not_prevent_later_object_reclamation`

Evidence audit:

```text
execution=valid-completed-trial
result_exceptions=none
reward=0.0
reward_error=none
```

Failure classification: **F1/F2 genuine implementation failure**. The cache failure checks selective invalidation explicitly required by the instruction. The remaining failures check GC/reclamation behavior that is also explicitly stated: GC must account for concurrent commits and readers, active work may temporarily protect otherwise-unreachable objects, dead work cannot protect storage forever, and reclaiming a stale writer's base must not destroy the later commit's reusable state. These are observable behavioral invariants rather than source-layout assumptions.

No evidence from this trial indicates provider/auth/quota contamination, Harbor failure, verifier failure, hidden representation requirements, or a specification mismatch. The six failures are therefore accepted as candidate-behavior failures and this trial **counts as Codex standard failure 1/3**.

## Historical calibration

### Workspace snapshot design — solved

Tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` produced a clean GPT-5.6 Sol/xhigh solve:

```text
reward = 1
58 passed / 0 failed
execution_class = valid-completed-trial
```

Classification: valid solve; the task was strengthened.

### Optimistic transaction predecessor — verifier defect

Tree `40cbd34104e1f0a549be23b46ef70655b728cece` returned reward 0 with 61 passed / 5 failed, but those failures depended on a verifier helper requiring `.workspace-cache/CURRENT`, which the contract did not prescribe.

Classification: `F4`. The workspace-current verifier was made representation-neutral. This run is not difficulty evidence and does not count.

### Difficulty calibration tree — genuine Sol failure

Tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

Historical deterministic qualification:

```text
static checks:        PASS
Oracle/reference:     66/66
mutants rejected:     40/40
Harbor Oracle/NOP:    1/0
```

GPT-5.6 Sol/xhigh result:

```text
reward = 0
45 passed / 21 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
runtime = 29m44s
```

The failures were broad across publication, exactly-once durability, readers/GC, reclamation interleavings, interrupted-work recovery, and workspace transaction behavior rather than a single formatting error.

Classification: genuine implementation failure for **difficulty calibration only**. Later verifier/schema/process review superseded the tree, so it does not fill any final matrix slot.

## Corrections made before the frozen tree

Review of the calibration tree and intermediate successors found and corrected:

- fixed-path workspace-current observation;
- incorrect ordinary-project-current inference from workspace-only history;
- private `request_report` replay dependency;
- undocumented committed-record schema expectations;
- incomplete candidate-process isolation;
- a response-loss test that replayed too early and could repair durability before the intended reclamation scenario;
- undocumented live-owner duplicate semantics;
- over-prescriptive transaction wording;
- an unnecessary exact retry-count assumption;
- verifier teardown zombie contamination.

These were treated as task/verifier defects, not as model failures.

## Freeze rule for the final tree

For `d862ab3cc79718e959e9cc7ec1b792540990a24d`:

- valid standard reward `1` means the required failure matrix is not met;
- valid standard reward `0` caused by genuine candidate implementation error can count;
- `F3/F4` requires a narrow task/verifier repair, a **new task-tree hash**, and complete requalification before further counted trials;
- `F5/F6/F7` is preserved as invalid evidence and does not count;
- the first legitimate exact-tree reward-0 failure has now been reviewed, so the task tree is frozen for the remainder of the standard/adversarial matrix;
- full TB3 compliance requires three valid Sol/xhigh failures, three valid Opus 5/max failures, and one zero-reward adversarial entry for each agent under the pinned live `/cheat` behavior;
- because Claude access is unavailable, this submission will intentionally remain incomplete on the Claude-dependent portion rather than claim full readiness.
