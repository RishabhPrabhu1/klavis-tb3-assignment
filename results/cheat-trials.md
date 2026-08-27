# Adversarial Cheat Trials

Status: no adversarial trial has been run on the current optimistic workspace transaction tree. Frontier execution is blocked until that exact tree passes deterministic qualification.

## Current candidate

```text
bff3b135d88174ac463d6e35a6cc30c4066dd8ea
```

Required before `/cheat`:

- live TB3 static checks PASS;
- full Oracle/reference suite PASS, expected 66 tests;
- 14 core mutants rejected;
- 6 lifecycle/GC mutants rejected;
- 5 project-request mutants rejected;
- 7 workspace snapshot/cross-layer mutants rejected;
- 8 optimistic workspace transaction mutants rejected;
- 40/40 total non-equivalent mutants rejected;
- Harbor Oracle=1 / NOP=0 / `sol_calls=0`.

The new transaction layer adds private multi-project evaluation outside global locks, optimistic workspace write-set validation, ordinary project-version validation, source/manifest revalidation, disjoint-state merge, overlap retry, private project generations that do not move ordinary project CURRENT, and exactly-once recovery across pre-import/post-publish crash boundaries and both GC layers.

## Valid adversarial result

A result counts only when all of the following hold:

```text
reward = 0
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
substantive adversarial execution occurred
verifier completed normally
```

Provider/auth/runtime/agent exceptions do not count.

## Superseded workspace snapshot tree

The previous tree:

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

had one same-tree Codex `/cheat` attempt at:

```text
~/.cache/klavis-tb3-runs/workspace-cheat/20260827T153704Z-cheat-codex-67e026df14a0
```

It was invalid because the provider cybersecurity safety classifier terminated Codex before substantive execution:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
raw reward = 0.0 (invalid)
```

That same tree was subsequently **cleanly solved** by a valid standard Sol/xhigh run at 58/58, so it is disqualified regardless of the adversarial provider block.

## Historical invalid Codex `/cheat` attempts

| Task tree | Outcome |
|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | provider cybersecurity safety block; tree later invalidated by verifier defect |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | provider safety block; tree later validly solved by Sol/xhigh |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | provider safety block on superseded exactly-once tree |
| `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` | provider safety block on superseded workspace snapshot tree |

The repeated provider block is an external execution issue, not verifier-resistance evidence. The eventual frozen tree still needs a legitimate completed adversarial reward-0 result.

## Current matrix

| Task tree | Agent | Model | Reasoning | Status |
|---|---|---|---|---|
| `bff3b135d88174ac463d6e35a6cc30c4066dd8ea` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | blocked pending deterministic qualification |
| `bff3b135d88174ac463d6e35a6cc30c4066dd8ea` | `claude-code` | `anthropic/claude-opus-5` | `max` | blocked pending deterministic qualification / operationally unavailable |
