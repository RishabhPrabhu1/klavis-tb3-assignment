# Standard Trials

## Required configuration

Klavis requires three clean standard `/run` failures for each configuration:

| Agent | Model | Reasoning | Required |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |

A standard trial counts only when the exact task tree is qualified, execution completes normally with no provider/auth/quota/container/timeout/agent exception, the verifier runs normally, and reward is `0` because of candidate behavior.

## Current candidate

```text
316aaf9804a82cc43e6075a657f3effda0c5717c
```

Final exact-tree qualification and implementation-rubric review are pending. **No trial below the final-tree table is allowed to count toward the required six-run matrix.**

## Difficulty calibration — predecessor tree

Tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

This predecessor passed static checks, Oracle/reference `66/66`, all `40/40` development mutants, and Harbor Oracle/NOP `1/0`. A GPT-5.6 Sol/xhigh standard probe then produced:

```text
reward = 0
45 passed / 21 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
runtime = 29m44s
```

The failures were distributed across project publication, exactly-once durability, readers/GC, reclamation interleavings, interrupted-work recovery, and workspace transaction replay. This establishes that the underlying runtime task is difficult enough.

It is **historical calibration only** because later rubric review found verifier/schema/process issues. The current successor keeps the same starter/reference runtime implementation but changes verifier observation/documentation, so final model trials must be rerun on `316aaf...` exactly.

## Earlier verifier-defect probe

Tree `40cbd34104e1f0a549be23b46ef70655b728cece` produced a clean reward-0 Sol run with 61/66 tests, but all five failures were masked by an undocumented `.workspace-cache/CURRENT` verifier assumption. Classification: F4 verifier defect; not difficulty evidence.

## Earlier valid solve

Tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` was solved cleanly by Sol/xhigh with reward 1 and 58/58 tests. That result motivated the later optimistic workspace-transaction design and does not count toward the final matrix.

## Final exact-tree matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `316aaf...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | pending qualification/rubric |
| `316aaf...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | pending freeze |
| `316aaf...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | pending freeze |
| `316aaf...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | pending provider access/freeze |
| `316aaf...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | pending provider access/freeze |
| `316aaf...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | pending provider access/freeze |

## Freeze policy

After exact-tree deterministic qualification and implementation-rubric acceptance:

1. run exactly one guarded Sol/xhigh probe with `scripts/run-one-qualified-sol-probe.sh`;
2. valid reward 0 from a genuine implementation failure permits immediate freeze;
3. reward 1 means the exact tree does not satisfy the required failure matrix;
4. specification/verifier/infrastructure/provider failures do not count and must not be reinterpreted as model difficulty;
5. after freeze, `scripts/run-deadline-sol-matrix.sh` collects only the additional Sol failures needed to reach three and stops on any solve or invalid run.

Claude standard evidence remains externally blocked until a zero-out-of-pocket eligible Opus 5 provider route is available. Repository tooling supports Claude Code through Bedrock but does not assume ordinary AWS Free Tier credits cover third-party Anthropic spend.
