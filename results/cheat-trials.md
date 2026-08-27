# Adversarial Cheat Trials

Status: no valid adversarial evidence exists for the current cross-project workspace redesign. The previously qualified exactly-once tree was superseded after a formally invalid Sol run nevertheless produced a preserved candidate that passed its full 48-test verifier, so that tree is treated only as non-qualifying near-solve development evidence.

## Current candidate

```text
6fa80f75cb1addd96765c240943ceaa1a71bbd2e
```

This tree is **pending deterministic qualification**. Do not launch `/cheat` until live static checks, the full Oracle/reference verifier, all four mutation matrices, and Harbor Oracle/NOP have passed on this exact tree.

The workspace redesign adds a second immutable snapshot layer spanning multiple independently published projects. It requires a real linearizable cross-project cut, exactly-once workspace capture requests, long-lived workspace-reader pins, workspace GC, and project-GC protection of project generations referenced by retained workspace snapshots.

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

## Superseded exactly-once-tree Codex attempt

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence |
|---|---|---|---|---:|---|---|---|
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0.0` | **No** | `NonZeroAgentExitCodeError`: provider cybersecurity safety block before substantive work; unchanged starter graded. | `~/.cache/klavis-tb3-runs/cheat-exactly-once/20260827T093440Z-cheat-codex-ae96c0c3a0c2` |

That tree's standard diagnostic was also formally invalid because of a subscription quota exit, although the preserved candidate passed 48/48. Neither run counts for the workspace redesign.

## Historical invalid attempts

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence path |
|---|---|---|---|---:|---|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Provider cybersecurity safety block before substantive work. Tree later invalidated by verifier defect. | `~/.cache/klavis-tb3-runs/cheat/20260827T051402Z-cheat-codex-cee924d537b2` |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Same provider cybersecurity safety block before substantive work. Tree later solved cleanly by standard Sol/xhigh and redesigned. | `~/.cache/klavis-tb3-runs/cheat-v2/20260827T063908Z-cheat-codex-c90cfcc71a86` |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Same provider safety termination on the superseded exactly-once tree. | `~/.cache/klavis-tb3-runs/cheat-exactly-once/20260827T093440Z-cheat-codex-ae96c0c3a0c2` |

Three subscription-auth Codex `/cheat` attempts have shown the same provider-level safety termination. Do not blindly retry the identical path. A legitimate completed adversarial execution is still required on the eventual frozen tree.

## Current workspace-tree matrix

| Task tree | Agent | Model | Reasoning | Status |
|---|---|---|---|---|
| `6fa80f75cb1addd96765c240943ceaa1a71bbd2e` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | Blocked until deterministic qualification |
| `6fa80f75cb1addd96765c240943ceaa1a71bbd2e` | `claude-code` | `anthropic/claude-opus-5` | `max` | Blocked until deterministic qualification / operationally outstanding |

If a future valid adversarial attempt earns nonzero reward, repair the verifier/task at the architectural level and restart deterministic qualification from Step 1.
