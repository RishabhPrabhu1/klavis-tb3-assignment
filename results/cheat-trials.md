# Adversarial Cheat Trials

Status: the current deterministically qualified cross-project workspace redesign has one same-tree Codex adversarial attempt, but it is **invalid** because the provider cybersecurity safety classifier terminated the agent before substantive execution. `/cheat` therefore remains outstanding.

## Current qualified candidate

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

Deterministic qualification on this exact tree is complete:

- live TB3 static checks: PASS;
- Oracle/reference verifier: 58/58 PASS;
- core mutations: 14/14 rejected;
- lifecycle/GC mutations: 6/6 rejected;
- exactly-once request mutations: 5/5 rejected;
- non-equivalent workspace/cross-layer mutations: 7/7 rejected;
- total mutants: 32/32 rejected;
- Harbor Oracle=1 / NOP=0 / `sol_calls=0`.

Qualification evidence:

```text
~/.cache/klavis-tb3-runs/workspace-preflight-v3/20260827T152942Z-8246be350d7d
```

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

## Current-tree Codex `/cheat` attempt

| Task tree | Agent | Model | Reasoning | Raw reward | Valid? | Outcome | Evidence path |
|---|---|---|---|---:|---|---|---|
| `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0.0` | **No** | `NonZeroAgentExitCodeError`: provider cybersecurity safety block before substantive work. Starter remained byte-for-byte unchanged; verifier result is not countable. | `~/.cache/klavis-tb3-runs/workspace-cheat/20260827T153704Z-cheat-codex-67e026df14a0` |

Authoritative classification:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
substantive_execution = false
```

The raw verifier reward of 0 does **not** satisfy `/cheat`. This same-tree audited provider exception is retained only to authorize the explicit one-off ordinary Sol/xhigh difficulty diagnostic. Do not retry the identical subscription-auth adversarial path during this qualification phase.

## Historical invalid Codex `/cheat` attempts

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence path |
|---|---|---|---|---:|---|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Provider cybersecurity safety block before substantive work. Tree later invalidated by verifier defect. | `~/.cache/klavis-tb3-runs/cheat/20260827T051402Z-cheat-codex-cee924d537b2` |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Same provider safety block. Tree later solved cleanly by standard Sol/xhigh. | `~/.cache/klavis-tb3-runs/cheat-v2/20260827T063908Z-cheat-codex-c90cfcc71a86` |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | Same provider safety block on superseded exactly-once tree. | `~/.cache/klavis-tb3-runs/cheat-exactly-once/20260827T093440Z-cheat-codex-ae96c0c3a0c2` |

Four subscription-auth Codex `/cheat` attempts have now shown the same provider-level safety termination. A legitimate completed adversarial execution is still required on the eventual frozen tree; none of these exceptions waive that requirement.

## Current workspace-tree matrix

| Task tree | Agent | Model | Reasoning | Status |
|---|---|---|---|---|
| `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | Same-tree attempt invalid/outstanding; one-off standard diagnostic authorized by audited provider exception |
| `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` | `claude-code` | `anthropic/claude-opus-5` | `max` | Operationally outstanding |

If a future valid adversarial attempt earns nonzero reward, repair the verifier/task at the architectural level and restart deterministic qualification from Step 1.
