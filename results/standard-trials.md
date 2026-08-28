# Standard Trials

## Required configuration

Klavis requires three genuine standard `/run` failures for each configuration:

| Agent | Model | Reasoning | Required |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |

A standard trial counts only when execution completes normally, the exact task tree is qualified, the verifier runs normally, there is no provider/auth/quota/container/timeout/agent exception, and reward is `0` because of candidate behavior.

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

Deterministic qualification before model execution:

```text
static checks = PASS
Oracle/reference = 68/68
Harbor Oracle/NOP = 1/0
model calls during qualification = 0
```

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected 40/40 development mutation controls. The frozen successor changes only verifier teardown/reaping hygiene in `tests/conftest.py` and reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP.

The automated implementation-rubric PASS remains outstanding and is not claimed here.

## Provider availability for this submission

The required Codex standard matrix was completed on the exact frozen tree.

Claude-dependent execution is not available in the submission environment: there is no Claude Code subscription and no usable Anthropic API or Bedrock route. Accordingly, the three Claude Code / Opus 5 standard trials were **not run for this submission**. They remain visible below because they are part of the required TB3 matrix; their absence is disclosed rather than replaced with a different model or counted provider failure.

## Final exact-tree matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | **COUNTED — valid reward 0** |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | **COUNTED — valid reward 0** |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | **COUNTED — valid reward 0** |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | **NOT RUN — Claude access unavailable** |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | **NOT RUN — Claude access unavailable** |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | **NOT RUN — Claude access unavailable** |

The exact-tree Codex collector completed with:

```text
execution_commit=90ba6964ae64fa04be2e58162c59b0be186023d8
task_tree=d862ab3cc79718e959e9cc7ec1b792540990a24d
valid_sol_xhigh_failures=3
target=3
status=SOL_MATRIX_COMPLETE
```

### Codex standard trial 1

```text
execution commit: 90ba6964ae64fa04be2e58162c59b0be186023d8
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
agent/model: codex / openai/gpt-5.6-sol
reasoning: xhigh
environment: docker
Harbor: 0.14.0
runtime: 32m46s
Harbor exit status: 0
execution_class: valid-completed-trial
qualification_valid: true
result_exception_types: []
authoritative reward: 0.0
verifier: 62 passed / 6 failed / 0 skipped
```

Evidence directory:

```text
~/.cache/klavis-tb3-runs/transaction-standard-probe/20260828T013339Z-85607-standard-codex-90ba6964ae64
```

Failed tests:

- `test_build_cache.py::test_unrelated_input_and_target_definition_invalidate_selectively`
- `test_reclamation.py::test_gc_revalidates_after_concurrent_commit`
- `test_reclamation.py::test_gc_revalidates_reader_pin_acquired_during_scan`
- `test_reclamation_interleavings.py::test_gc_preserves_private_objects_of_live_writer`
- `test_reclamation_interleavings.py::test_gc_can_reclaim_writer_base_without_losing_later_commit_state`
- `test_reclamation_interleavings.py::test_crashed_writer_lease_does_not_prevent_later_object_reclamation`

Post-run evidence audit reported:

```text
execution=valid-completed-trial
result_exceptions=none
reward=0.0
reward_error=none
```

The failures exercise requirements stated directly in `instruction.md`: selective cache invalidation; GC revalidation against concurrent commits/readers; temporary protection of live-writer objects; reclamation after dead work; and preservation of later committed reusable state when stale writer bases are reclaimed. Trial 1 therefore counts as a genuine candidate implementation failure.

### Codex standard trial 2

```text
execution commit: 90ba6964ae64fa04be2e58162c59b0be186023d8
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
agent/model: codex / openai/gpt-5.6-sol
reasoning: xhigh
environment: docker
Harbor: 0.14.0
runtime: 31m00s
Harbor exit status: 0
execution_class: valid-completed-trial
qualification_valid: true
result_exception_types: []
authoritative reward: 0.0
verifier: 64 passed / 4 failed / 0 skipped
```

Evidence directory:

```text
~/.cache/klavis-tb3-runs/transaction-standard-final/20260828T020940Z-87647-standard-codex-90ba6964ae64
```

Failed tests:

- `test_build_cache.py::test_unrelated_input_and_target_definition_invalidate_selectively`
- `test_reclamation_interleavings.py::test_gc_preserves_private_objects_of_live_writer`
- `test_reclamation_interleavings.py::test_gc_can_reclaim_writer_base_without_losing_later_commit_state`
- `test_reclamation_interleavings.py::test_crashed_writer_lease_does_not_prevent_later_object_reclamation`

These are the same explicit cache/GC/writer-liveness invariants exercised in the accepted first run. Harbor completed normally with no trial exceptions and reward `0`. Trial 2 counts as a genuine candidate implementation failure.

### Codex standard trial 3

```text
execution commit: 90ba6964ae64fa04be2e58162c59b0be186023d8
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
agent/model: codex / openai/gpt-5.6-sol
reasoning: xhigh
environment: docker
Harbor: 0.14.0
runtime: 30m31s
Harbor exit status: 0
execution_class: valid-completed-trial
qualification_valid: true
result_exception_types: []
authoritative reward: 0.0
verifier: 54 passed / 14 failed / 0 skipped
```

Evidence directory:

```text
~/.cache/klavis-tb3-runs/transaction-standard-final/20260828T024042Z-89033-standard-codex-90ba6964ae64
```

Failed tests:

- `test_exactly_once_requests.py::test_stranded_committed_request_survives_later_commit_and_gc`
- `test_exactly_once_requests.py::test_inflight_ordinary_build_preserves_stranded_request_before_replacing_current`
- `test_reclamation.py::test_gc_enforces_commit_order_and_keep_budget`
- `test_reclamation.py::test_live_reader_pins_old_generation_then_releases_it`
- `test_reclamation.py::test_killed_reader_does_not_pin_storage_forever`
- `test_reclamation.py::test_gc_revalidates_after_concurrent_commit`
- `test_reclamation.py::test_gc_revalidates_reader_pin_acquired_during_scan`
- `test_reclamation.py::test_gc_does_not_break_paused_writer_and_later_sweeps_objects`
- `test_reclamation.py::test_interrupted_gc_preserves_current_and_live_reader_then_recovers`
- `test_reclamation.py::test_keep_budget_is_in_addition_to_pinned_history`
- `test_reclamation.py::test_generation_remains_pinned_until_last_reader_exits`
- `test_reclamation_interleavings.py::test_gc_preserves_private_objects_of_live_writer`
- `test_reclamation_interleavings.py::test_gc_can_reclaim_writer_base_without_losing_later_commit_state`
- `test_reclamation_interleavings.py::test_crashed_writer_lease_does_not_prevent_later_object_reclamation`

These failures correspond directly to documented exactly-once durability, reader pinning, KEEP accounting, concurrent-GC revalidation, interrupted-GC recovery, writer protection, and eventual reclamation requirements. Harbor completed normally with no trial exceptions and reward `0`. Trial 3 counts as a genuine candidate implementation failure.

No historical-tree trial counts toward these six required standard entries. Historical calibration and superseded verifier-defect runs are documented once in `results/failure-analysis.md`.

## Acceptance procedure

For exact-tree standard invocations:

1. Preserve raw Harbor output and result files.
2. Audit evidence from authoritative Harbor `result.json` state.
3. Require `execution_class = valid-completed-trial`, `qualification_valid = true`, no result exceptions, and authoritative reward `0`.
4. Inspect verifier failures to rule out specification ambiguity, verifier defects, or infrastructure/provider contamination.
5. Only then count the trial.

The Codex requirement is now complete at **3/3 valid reward-0 standard failures**. The Claude rows remain `NOT RUN` because genuine Claude access is unavailable; provider failures or alternate models are not used to fill those slots.
