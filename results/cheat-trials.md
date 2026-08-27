# Adversarial Cheat Trials

Status: no valid adversarial evidence exists for the current strengthened request-protocol redesign. All prior Codex `/cheat` attempts are historical and invalid.

## Current candidate

```text
f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8
```

This tree is pending deterministic qualification. Do not launch `/cheat` until it passes static checks, the full Oracle, all mutation matrices, and Harbor Oracle/NOP.

The earlier request-protocol tree `3ddb933ae848f6912210371c6afc210ceea3f373` was superseded before frontier testing after verifier review added composition coverage for waiting-owner takeover and a publication race involving an already-in-flight ordinary build.

## Live requirement versus current operational scope

Current live Terminal-Bench `/cheat` runs one adversarial attempt per configured agent. The written assignment still includes both Codex/Sol and Claude/Opus. The current operational workflow is Codex-only because Claude Code subscription access is not available.

The wrapper uses Harbor 0.14.0, Docker, subscription auth, the current upstream `docs/prompts/hack-trial-prompt.md`, and audited `result.json.exception_info` evidence. A valid adversarial result requires:

```text
reward = 0
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
agent performs substantive execution
verifier completes normally
```

Provider/auth/runtime/agent exceptions are invalid and never count as verifier resistance.

## Historical adversarial attempts

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence path |
|---|---|---|---|---:|---|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Provider cybersecurity safety block before substantive work. Tree later invalidated by verifier defect. | `~/.cache/klavis-tb3-runs/cheat/20260827T051402Z-cheat-codex-cee924d537b2` |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Same provider cybersecurity safety block before substantive work. Tree later solved cleanly by standard Sol/xhigh and redesigned. | `~/.cache/klavis-tb3-runs/cheat-v2/20260827T063908Z-cheat-codex-c90cfcc71a86` |

Neither attempt can be reused for the current tree. The repeated safety-block pattern means the same subscription-auth adversarial path should not be retried blindly; a legitimate execution path that can run the official prompt to completion is still required.

## Current-tree adversarial matrix

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Evidence |
|---|---|---|---|---:|---|---|
| `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | Pending | Pending | Pending |
| `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8` | `claude-code` | `anthropic/claude-opus-5` | `max` | Pending | Pending | Pending |

If a valid adversarial attempt earns nonzero reward, repair the verifier/task at the architectural level and restart deterministic qualification from Step 1.

## Final status requirements

A valid Codex `/cheat` reward-0 run on the exact final frozen tree is required. Claude adversarial evidence also remains required by the written assignment unless waived.
