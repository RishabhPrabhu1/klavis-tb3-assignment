# Adversarial Cheat Trials

Status: no valid adversarial evidence exists yet for the current qualified exactly-once request-protocol redesign. The current-tree Codex `/cheat` attempt was invalid because the provider cybersecurity safety classifier terminated the agent before substantive execution.

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

## Validity rule

A valid adversarial result requires all of:

```text
reward = 0
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
agent performs substantive execution
verifier completes normally
```

Provider/auth/runtime/agent exceptions are invalid and never count as verifier resistance.

## Current-tree Codex attempt

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence |
|---|---|---|---|---:|---|---|---|
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0.0` | **No** | `NonZeroAgentExitCodeError`: provider cybersecurity safety block before substantive work; unchanged starter graded. | `~/.cache/klavis-tb3-runs/cheat-exactly-once/20260827T093440Z-cheat-codex-ae96c0c3a0c2` |

Authoritative audit fields:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
```

The verifier did run and produced 6 passed / 42 failed, but those results reflect the unchanged starter and are not interpretable as an adversarial outcome.

This same-tree invalid evidence permits the explicitly audited one-off standard difficulty diagnostic while `/cheat` remains outstanding. It does **not** satisfy or waive the adversarial requirement.

## Historical invalid attempts

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence path |
|---|---|---|---|---:|---|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Provider cybersecurity safety block before substantive work. Tree later invalidated by verifier defect. | `~/.cache/klavis-tb3-runs/cheat/20260827T051402Z-cheat-codex-cee924d537b2` |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Same provider cybersecurity safety block before substantive work. Tree later solved cleanly by standard Sol/xhigh and redesigned. | `~/.cache/klavis-tb3-runs/cheat-v2/20260827T063908Z-cheat-codex-c90cfcc71a86` |

Three separate subscription-auth Codex `/cheat` attempts have now shown the same provider-level safety termination. Do not blindly retry the identical path. A legitimate completed adversarial execution is still required for final compliance.

## Remaining adversarial matrix

| Task tree | Agent | Model | Reasoning | Status |
|---|---|---|---|---|
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | Invalid/currently blocked; valid reward-0 run still required |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `claude-code` | `anthropic/claude-opus-5` | `max` | Outstanding |

If a future valid adversarial attempt earns nonzero reward, repair the verifier/task at the architectural level and restart deterministic qualification from Step 1.
