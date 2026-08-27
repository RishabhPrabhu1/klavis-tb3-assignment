# Standard Trials

Status: final standard evidence has **not** started for the current cross-project workspace redesign. The previously qualified exactly-once tree was superseded after a formally invalid Sol/xhigh diagnostic nevertheless left a preserved candidate that passed its full 48-test verifier. That run remains non-countable, but it was sufficient development evidence to justify a further architectural redesign rather than spending another trial to obtain a formal reward-1 solve.

## Live requirement versus current operational scope

Current live Terminal-Bench defaults specify three standard trials each for:

| Agent | Model | Reasoning | Live required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

The current operational workflow is Codex-only because Claude Code subscription access is not available. The repository must not claim full written-assignment compliance unless the Claude requirement is later satisfied or waived.

## Current workspace redesign candidate

```text
6fa80f75cb1addd96765c240943ceaa1a71bbd2e
```

This tree is **pending deterministic qualification**. No standard frontier trial may count until live TB3 static checks, the full Oracle/reference suite, the core/lifecycle/request/workspace mutation matrices, and Harbor Oracle/NOP have passed on this exact tree with zero frontier calls.

## New difficulty crux

The task now composes project snapshot publication and exactly-once request semantics with a second immutable workspace snapshot layer spanning multiple independently published projects.

The new requirements include:

- `workspace-capture` must record a real simultaneous cut across every project in its canonical plan rather than reading member currents sequentially;
- during the stable-cut pause, ordinary publishers to every listed project must wait while unlisted projects remain independent;
- workspace capture request IDs are exactly-once, support waiting-owner takeover, and recover from post-publication response loss;
- a later workspace publication must reconcile a stranded committed workspace request before the old workspace generation can be reclaimed;
- long-lived workspace readers pin one historical workspace generation and transitively pin every referenced project generation;
- workspace GC retains current + live-reader pins + newest KEEP additional history;
- project GC must preserve any project generation referenced by any retained workspace snapshot and reclaim it once the workspace reference retires.

This is a cross-resource transaction/reclamation problem rather than another single-project interleaving.

## Superseded exactly-once-tree development evidence

Tree:

```text
42cba8ad00bebf316048d1470033c1742a20ec97
```

It was deterministically qualified at 48/48 with 25/25 mutants rejected. Its standard diagnostic at:

```text
~/.cache/klavis-tb3-runs/exactly-once-standard-probe/20260827T094216Z-standard-codex-5eba253f7e10
```

was formally invalid:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
result.json reward = null
```

Codex hit its subscription usage limit after roughly 35 minutes and 74 trajectory steps. The preserved implementation nevertheless passed 48/48 verifier tests. This remains **non-qualifying near-solve development evidence only** and contributes zero valid trials.

The earlier tree `4eaf21ae9456395fb080be497852c0ff9623b8fa` was a valid clean Sol/xhigh solve at 37/37 and is historical evidence only.

## Workspace-tree frontier policy

1. Deterministically qualify `6fa80f75cb1addd96765c240943ceaa1a71bbd2e` from zero.
2. Obtain Harbor Oracle=1/NOP=0 with zero frontier calls.
3. Do not run `/cheat` or standard Sol until that exact tree passes.
4. After qualification, attempt same-tree adversarial execution once; provider/auth/runtime exceptions remain invalid.
5. Run one valid Sol/xhigh standard difficulty probe.
6. If Sol solves, redesign again and restart qualification.
7. Freeze only after a genuine conceptual/architectural reward-0 failure.

## Frozen Codex matrix

Not started.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 3 | Pending | Pending | Pending | Pending |

Target: 0/3 genuine Codex/Sol passes on the eventual frozen tree.

## Outstanding requirements

- Deterministic qualification of the current workspace tree.
- Genuine intended-crux Sol/xhigh failure before freezing.
- Three valid Codex/Sol xhigh standard failures on the eventual frozen tree.
- Valid Codex `/cheat` reward 0 on the final frozen tree.
- Claude Code / Opus 5 max standard and adversarial evidence remains outstanding under the written assignment unless waived.
