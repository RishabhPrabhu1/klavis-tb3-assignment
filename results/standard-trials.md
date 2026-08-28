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

Deterministic status before frontier execution:

```text
static checks = PASS
Oracle/reference = 68/68
Harbor Oracle/NOP = 1/0
frontier model calls = 0
```

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected 40/40 development mutation controls. The frozen successor changes only verifier teardown/reaping hygiene in `tests/conftest.py` and reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP.

The automated implementation-rubric PASS is a separate pre-frontier gate and is not claimed here until same-tree evidence exists.

## Final exact-tree matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | pending rubric gate |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | pending first-trial freeze decision |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | pending first-trial freeze decision |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | pending rubric gate/provider access |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | pending rubric gate/provider access |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | pending rubric gate/provider access |

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

Earlier tree `40cbd34104e1f0a549be23b46ef70655b728cece` produced reward 0 but its failures depended on an undocumented workspace selector; it is classified as verifier-defect evidence and does not count. Earlier tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` was cleanly solved and motivated the later task strengthening.

## Execution policy

1. Require same-tree deterministic qualification and automated implementation-rubric PASS.
2. Launch the first frozen-tree Sol probe with `scripts/run-next-frontier-step.sh` / `scripts/run-one-qualified-sol-probe.sh`.
3. Inspect a reward-0 result before freezing: only a genuine implementation failure counts.
4. A reward-1 result means the frozen tree does not satisfy the required matrix.
5. Specification/verifier defects or infrastructure/provider failures do not count.
6. After a legitimate first reward-0 failure is accepted, `CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh` collects only the remaining Codex failures required to reach 3/3 and stops on any solve or invalid run.
7. Claude final trials use the exact same task tree and strict validity policy.

Exact evidence directories, pass/fail counts, failed tests, execution commit, and classifications must be inserted into this ledger after each final trial.
