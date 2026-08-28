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

Deterministic qualification before frontier execution:

```text
static checks = PASS
Oracle/reference = 68/68
Harbor Oracle/NOP = 1/0
frontier model calls during qualification = 0
```

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected 40/40 development mutation controls. The frozen successor changes only verifier teardown/reaping hygiene in `tests/conftest.py` and reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP.

The automated implementation-rubric PASS remains outstanding and is not claimed here.

## Provider availability for this submission

Codex authentication is available and the required Codex matrix is being completed on the exact frozen tree.

Claude-dependent execution is not available in the submission environment: there is no Claude Code subscription and no usable Anthropic API or Bedrock route. Accordingly, the three Claude Code / Opus 5 standard trials are **not being run for this submission**. They remain visible below because they are part of the required TB3 matrix; their absence is disclosed rather than replaced with a different model or counted provider failure.

## Final exact-tree matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | **COUNTED — valid reward 0** |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | pending |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | pending |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | **NOT RUN — Claude access unavailable** |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | **NOT RUN — Claude access unavailable** |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | **NOT RUN — Claude access unavailable** |

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

The failures exercise requirements stated directly in `instruction.md`: selective cache invalidation; GC revalidation against concurrent commits/readers; temporary protection of live-writer objects; reclamation after dead work; and preservation of later committed reusable state when stale writer bases are reclaimed. They are therefore classified as genuine candidate implementation failures rather than specification, verifier, provider, or infrastructure failures. Trial 1 counts toward the required Codex matrix.

No historical-tree trial counts toward these six entries.

## Difficulty calibration — historical only

Tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

That superseded tree passed its then-current static checks, Oracle/reference `66/66`, all `40/40` development mutants, and Harbor Oracle/NOP `1/0`. A GPT-5.6 Sol/xhigh standard probe produced:

```text
reward = 0
45 passed / 21 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
runtime = 29m44s
```

The failure was broad across publication, exactly-once durability, readers/GC, reclamation interleavings, interrupted-work recovery, and workspace transaction replay. Later verifier/schema/process corrections superseded that tree, so the run is difficulty calibration only.

Earlier tree `40cbd34104e1f0a549be23b46ef70655b728cece` produced reward 0 but its failures depended on an undocumented workspace selector; it is verifier-defect evidence and does not count. Earlier tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` was cleanly solved and motivated later task strengthening.

## Post-run acceptance procedure

For every exact-tree standard invocation:

1. Preserve the raw Harbor output and result files.
2. Run `scripts/audit-trial-evidence.py` against the evidence root.
3. Require `execution_class = valid-completed-trial`, `qualification_valid = true`, no result exceptions, and authoritative reward `0`.
4. Inspect verifier failures and the candidate implementation to rule out specification ambiguity, verifier defects, or infrastructure/provider contamination.
5. Only then mark the trial as counted and add a per-trial entry to `results/failure-analysis.md`.

With trial 1 accepted, the remaining Codex standard runs can be collected with:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

The Claude rows will remain `NOT RUN` unless genuine Claude access becomes available; provider failures or alternate models will not be used to fill those slots.

Exact evidence directories, pass/fail counts, failed tests, execution commit, and classifications will be inserted after each completed Codex run.