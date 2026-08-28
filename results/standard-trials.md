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

## Final exact-tree matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | **running — unaudited; not counted** |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | pending trial-1 audit |
| `d862ab3...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | pending trial-1 audit |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | pending provider access |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | pending provider access |
| `d862ab3...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | pending provider access |

The currently running Codex invocation uses the exact frozen task tree and required `codex / openai/gpt-5.6-sol / xhigh` configuration. It is intentionally not represented as a completed or qualifying result until Harbor output, exception state, verifier counts, reward, and failure cause are reviewed.

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

After a legitimate first exact-tree reward-0 failure is accepted, the remaining Codex standard runs can be collected with:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

Exact evidence directories, pass/fail counts, failed tests, execution commit, and classifications will be inserted after each completed run.