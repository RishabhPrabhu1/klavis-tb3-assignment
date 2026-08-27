# Standard Trials

Status: final standard evidence has **not** started for the current qualified exactly-once request-protocol tree. The first same-tree Sol/xhigh diagnostic was formally INVALID because the Codex process hit its subscription usage limit, but its preserved candidate implementation passed the full verifier 48/48 before the nonzero agent exit. That result is non-countable qualification evidence but strong development evidence that another architectural redesign is warranted before spending another Sol trial.

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

## Exactly-once difficulty crux

The task adds durable exactly-once `--request-id` semantics on top of the snapshot/concurrency/GC architecture. A committed request must replay its original report without another publication across duplicate concurrency, owner crashes, post-publication response loss, later commits, GC of its original generation, and a race where an already-running ordinary build publishes after the stranded request.

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

## Same-tree standard diagnostic: formally invalid, development-significant

Evidence:

```text
~/.cache/klavis-tb3-runs/exactly-once-standard-probe/20260827T094216Z-standard-codex-5eba253f7e10
```

Configuration:

```text
agent = codex
model = openai/gpt-5.6-sol
reasoning_effort = xhigh
mode = standard
task_tree = 42cba8ad00bebf316048d1470033c1742a20ec97
Harbor = 0.14.0
```

Authoritative validity:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
result.json reward = null
```

Cause: after roughly 35 minutes and 74 trajectory steps, Codex hit its subscription usage limit and exited 1. Therefore the run is **not a valid standard solve or failure and cannot count toward the required matrix**.

However, before that provider exit the agent had made a substantive five-file implementation (`cli.py`, `engine.py`, `lifecycle.py`, `request_protocol.py`, plus new `storage.py`), and the verifier completed:

```text
48 passed
0 failed
0 skipped
```

The aggregate reward artifact recorded 1, but this is subordinate to the per-trial exception and null reward and is not qualification evidence.

### Development interpretation

The 48/48 preserved candidate result strongly suggests Sol had already produced a verifier-complete solution before quota termination. We therefore do **not** freeze this tree and do **not** spend another frontier call merely to turn that near-solve into a countable reward-1 result. Instead the task should be strengthened again at the transaction-model level, then deterministically requalified from zero.

This interpretation is deliberately separated from formal qualification: the run remains INVALID and contributes zero valid trials.

## Frozen Codex matrix

Not started.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | diagnostic | N/A | No | `~/.cache/klavis-tb3-runs/exactly-once-standard-probe/20260827T094216Z-standard-codex-5eba253f7e10` | F6 provider quota; 48/48 non-qualifying near-solve |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 3 | Pending | Pending | Pending | Pending |

Target: 0/3 genuine Codex/Sol passes on the eventual frozen tree.

## Historical diagnostics

The previous qualified tree `4eaf21ae9456395fb080be497852c0ff9623b8fa` was solved cleanly by Sol/xhigh: reward 1.0, 37/37 tests, no exceptions. That clean solve motivated the exactly-once redesign.

An earlier diagnostic on that tree was invalid because the Codex subscription usage limit ended the turn before implementation.

## Outstanding requirements

- Strengthen the task again at the architectural level and repeat deterministic qualification.
- Obtain a genuine intended-crux Sol/xhigh failure before freezing.
- On the eventual frozen tree, obtain three valid Codex/Sol xhigh standard failures.
- Obtain valid Codex `/cheat` reward 0 on the final frozen tree.
- Claude Code / Opus 5 max standard and adversarial evidence remains outstanding under the written assignment unless waived.
