# Standard Trials

Status: final standard evidence has **not** started for the current qualified exactly-once request-protocol tree. One ordinary Sol/xhigh difficulty diagnostic is now authorized because the same-tree Codex `/cheat` attempt was audited invalid due to a provider safety termination.

## Live requirement versus current operational scope

Current live Terminal-Bench defaults specify three standard trials each for:

| Agent | Model | Reasoning | Live required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

The current operational workflow is Codex-only because Claude Code subscription access is not available. The repository must not claim full written-assignment compliance unless the Claude requirement is later satisfied or waived.

## Current qualified redesign

```text
42cba8ad00bebf316048d1470033c1742a20ec97
```

Qualification on this exact tree:

- live static checks: PASS;
- reference/oracle verifier: 48/48 PASS;
- core mutations: 14/14 rejected;
- lifecycle/GC mutations: 6/6 rejected;
- exactly-once request mutations: 5/5 rejected;
- Harbor Oracle=1 / NOP=0 / `sol_calls=0`.

## New difficulty crux

The task now adds durable exactly-once `--request-id` semantics on top of the snapshot/concurrency/GC architecture. A committed request must replay its original report without another publication across duplicate concurrency, owner crashes, post-publication response loss, later commits, GC of its original generation, and a race where an already-running ordinary build publishes after the stranded request.

## Same-tree `/cheat` blocker

The current-tree Codex `/cheat` attempt at:

```text
~/.cache/klavis-tb3-runs/cheat-exactly-once/20260827T093440Z-cheat-codex-ae96c0c3a0c2
```

was audited as:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
```

The provider cybersecurity safety classifier terminated Codex before substantive work. Reward 0 is invalid and `/cheat` remains outstanding.

Because this is audited same-tree evidence of an external execution blocker, `scripts/run-standard-diagnostic-safe.sh` may be used for **one** ordinary standard difficulty diagnostic with `ALLOW_CHEAT_SAFETY_BLOCK=1`. This exception does not waive or satisfy `/cheat`.

## Current-tree frontier policy

1. Deterministic qualification is complete.
2. Same-tree `/cheat` was attempted and is invalid/outstanding due to provider safety termination.
3. Run exactly one valid Codex / GPT-5.6 Sol / xhigh standard diagnostic.
4. If Sol solves, redesign again and restart qualification.
5. If Sol earns reward 0, inspect the trajectory; freeze only for a genuine conceptual/architectural failure rather than a typo, local bug, ambiguity, verifier defect, timeout, or infrastructure issue.
6. Do not begin the final 3-trial matrix until a defensible freeze decision is made.

## Frozen Codex matrix

Not started.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Failure classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending | Pending |

Target: 0/3 genuine Codex/Sol passes on the eventual frozen tree.

## Historical diagnostics

The previous qualified tree `4eaf21ae9456395fb080be497852c0ff9623b8fa` was solved cleanly by Sol/xhigh: reward 1.0, 37/37 tests, no exceptions. That solve motivated the exactly-once redesign and cannot count toward this tree.

An earlier diagnostic on that tree was invalid because the Codex subscription usage limit ended the turn before implementation.

## Outstanding requirements

- One valid Sol/xhigh difficulty probe on the current tree.
- If frozen, three valid Codex/Sol xhigh standard failures total.
- Valid Codex `/cheat` reward 0 on the final frozen tree.
- Claude Code / Opus 5 max standard and adversarial evidence remains outstanding under the written assignment unless waived.
