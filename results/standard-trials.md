# Standard Trials

Status: the previous corrected task was solved cleanly by Sol/xhigh and has been redesigned again. Final standard evidence has **not** started for the strengthened request-protocol tree.

## Live requirement versus current operational scope

Current live Terminal-Bench defaults specify three standard trials each for:

| Agent | Model | Reasoning | Live required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

The current operational workflow is Codex-only because Claude Code subscription access is not available. The repository must not claim full written-assignment compliance unless the Claude requirement is later satisfied or waived.

## Current redesign candidate

```text
f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8
```

This tree is **pending deterministic qualification**. No standard trial may count until static checks, the full Oracle, all mutation matrices, and Harbor Oracle/NOP have passed on this exact tree.

The earlier request-protocol tree `3ddb933ae848f6912210371c6afc210ceea3f373` was superseded before frontier testing after verifier review found a missing publication race and waiting-duplicate takeover coverage.

## Why the prior qualified tree was rejected

The previously qualified tree:

```text
4eaf21ae9456395fb080be497852c0ff9623b8fa
```

was tested with a valid uninterrupted Codex / `openai/gpt-5.6-sol` / `xhigh` standard diagnostic. Sol completed a full architectural implementation in approximately 31 minutes of agent execution and earned:

```text
reward = 1.0
verifier = 37 passed / 0 failed / 0 skipped
execution_class = valid-completed-trial
qualification_valid = true
result exceptions = none
```

Its solution implemented immutable generations, content-addressed objects, atomic publication, stable-input retry, concurrent reusable-state merging, reader/writer kernel-lock liveness, GC revalidation, KEEP semantics, object reclamation, and interrupted-GC recovery. No suspicious shortcut or verifier exploitation was observed.

That clean solve means `4eaf...` is historical development evidence only.

## New difficulty crux

The current redesign adds optional build `--request-id` semantics requiring an exactly-once protocol across concurrent duplicate invocations and crashes. The first committed request ID must remain replayable without another publication even after later input changes, later commits, and GC of the original generation.

The strengthened verifier also composes the protocol with publication races:

- a waiting duplicate must take over after the live owner is killed;
- a build already in flight before a lost-response request commits may later publish, but it must preserve the durable request result before replacing the current generation;
- replay after that older generation is GC'd must still return the original report without changing the current snapshot;
- invalid request IDs must fail without committing state.

This changes the transaction model rather than adding trajectory-specific edge cases to the architecture Sol already solved.

## New-tree qualification policy

1. Re-run all deterministic qualification on `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8`.
2. Obtain Harbor Oracle=1/NOP=0 with zero frontier calls.
3. Attempt valid `/cheat` on the new tree; provider/auth/runtime exceptions remain invalid.
4. Run exactly one valid Sol/xhigh standard probe.
5. If Sol solves again, redesign again and restart qualification.
6. Only a genuine conceptual/architectural reward-0 failure permits freezing for the final 3-trial matrix.

## Frozen Codex matrix

Not started.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Failure classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending | Pending |

Target: 0/3 genuine Codex/Sol passes on the eventual frozen tree.

## Historical corrected-tree diagnostics

| Agent | Model | Reasoning | Attempt | Reward | Valid? | Classification |
|---|---|---|---:|---:|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | diagnostic 1 | 0.0 | No | F6: subscription usage limit ended the turn before a patch landed; unchanged starter was graded |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | diagnostic 2 | 1.0 | **Yes** | Clean solve; 37/37 tests; task-level redesign required |

Valid solve evidence for diagnostic 2:

```text
~/.cache/klavis-tb3-runs/standard-diagnostic-v3/20260827T072230Z-standard-codex-1b14fec32802
```

## Outstanding requirements

- Valid Codex `/cheat` reward 0 on the eventual frozen tree.
- Three valid Codex/Sol xhigh standard failures on the eventual frozen tree.
- Claude Code / Opus 5 max standard and adversarial evidence remains outstanding under the written assignment unless waived.

Authentication errors, rate limits, subscription limits, model unavailability, Harbor/Docker failures, verifier infrastructure failures, and provider safety terminations are invalid trials and never count as model failures.
