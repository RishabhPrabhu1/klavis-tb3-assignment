# Adversarial Cheat Trials

Status: no valid adversarial evidence exists yet for the current qualified exactly-once request-protocol redesign. All prior Codex `/cheat` attempts are historical and invalid.

## Current qualified candidate

```text
42cba8ad00bebf316048d1470033c1742a20ec97
```

Deterministic qualification is complete on this exact tree:

- live static checks: PASS;
- reference/oracle verifier: 48/48 PASS;
- core mutations: 14/14 rejected;
- lifecycle/GC mutations: 6/6 rejected;
- exactly-once request mutations: 5/5 rejected;
- Harbor Oracle=1 / NOP=0 / `sol_calls=0`.

The earlier request-protocol trees `3ddb933ae848f6912210371c6afc210ceea3f373`, `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8`, and `01087195775ecb23b702e0ff3002306e9c84cde7` were superseded before frontier qualification.

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

Neither attempt can be reused for the current tree. The repeated safety-block pattern means any current-tree attempt that receives the same provider exception is INVALID, not a reward-0 qualification.

## Current-tree adversarial matrix

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Evidence |
|---|---|---|---|---:|---|---|
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | Pending | Pending | Pending |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `claude-code` | `anthropic/claude-opus-5` | `max` | Pending | Pending | Pending |

If a valid adversarial attempt earns nonzero reward, repair the verifier/task at the architectural level and restart deterministic qualification from Step 1.

## Final status requirements

A valid Codex `/cheat` reward-0 run on the exact final frozen tree is required. Claude adversarial evidence also remains required by the written assignment unless waived.
