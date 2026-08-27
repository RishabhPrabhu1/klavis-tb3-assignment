# Standard Trials

Status: final standard evidence has **not** started for the current cross-project workspace redesign. The tree is fully deterministically qualified. Its one same-tree Codex `/cheat` attempt was invalid because the provider cybersecurity safety classifier terminated the agent before substantive execution; `/cheat` remains outstanding. That audited same-tree exception now authorizes exactly one ordinary Sol/xhigh difficulty diagnostic.

## Live requirement versus current operational scope

Current live Terminal-Bench defaults specify three standard trials each for:

| Agent | Model | Reasoning | Live required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

The current operational workflow is Codex-only because Claude Code subscription access is not available. The repository must not claim full written-assignment compliance unless the Claude requirement is later satisfied or waived.

## Current qualified workspace redesign

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

Qualification on this exact tree:

- live static checks: PASS;
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

## Same-tree adversarial prerequisite

The current-tree Codex adversarial attempt at:

```text
~/.cache/klavis-tb3-runs/workspace-cheat/20260827T153704Z-cheat-codex-67e026df14a0
```

is formally invalid:

```text
execution_class = completed-with-exceptions
qualification_valid = false
result_exception_types = [NonZeroAgentExitCodeError]
substantive_execution = false
```

Cause: provider cybersecurity safety termination. The raw verifier reward of 0 is not countable and `/cheat` remains outstanding. This evidence is used only by `run-standard-diagnostic-safe.sh` as the explicitly audited exception permitting one ordinary difficulty probe.

## New difficulty crux

The task composes project snapshot publication and exactly-once project request semantics with a second immutable workspace snapshot layer spanning multiple independently published projects.

The new requirements include:

- `workspace-capture` must record a real simultaneous cut across every project in its canonical plan rather than reading member currents sequentially;
- during the stable-cut pause, ordinary publishers to every listed project must wait while unlisted projects remain independent;
- workspace capture request IDs are exactly-once, support waiting-owner takeover, and recover from post-publication response loss;
- because the workspace publication lock spans entry reconciliation through selector replacement, one entry reconciliation is sufficient for previously stranded workspace requests; the separate project-level publication-reconciliation race remains required and tested;
- long-lived workspace readers pin one historical workspace generation and transitively pin every referenced project generation;
- workspace GC retains current + live-reader pins + newest KEEP additional history;
- project GC must preserve any project generation referenced by any retained workspace snapshot and reclaim it once the workspace reference retires.

This is a cross-resource transaction/reclamation problem rather than another single-project interleaving.

## Superseded development evidence

The exactly-once tree `42cba8ad00bebf316048d1470033c1742a20ec97` had a standard diagnostic that was formally invalid because Codex hit its subscription usage limit, but the preserved candidate passed 48/48. That remains non-qualifying near-solve development evidence only and contributed zero valid trials. The earlier tree `4eaf21ae9456395fb080be497852c0ff9623b8fa` was a valid clean Sol/xhigh solve at 37/37 and is historical evidence only.

## Workspace-tree frontier policy

1. Current tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` is deterministically qualified.
2. Current-tree Codex `/cheat` has been attempted exactly once and is invalid/outstanding due provider safety.
3. Do not retry the identical `/cheat` path in this phase.
4. Run exactly one ordinary Codex/Sol xhigh standard difficulty probe through `run-standard-diagnostic-safe.sh` using the audited current-tree adversarial exception.
5. If that standard run is invalid because of provider/quota/runtime failure, it contributes zero trials and does not justify redesign or freeze.
6. If it is a valid reward-1 solve, redesign again and restart deterministic qualification.
7. If it is a valid reward-0 result, classify every failure cluster and freeze only if the primary cause is genuinely conceptual/architectural rather than a narrow bug, ambiguity, verifier defect, or infrastructure issue.
8. On the eventual frozen tree, collect the required 3/3 valid standard failures per required model/config.

## Frozen Codex matrix

Not started.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 3 | Pending | Pending | Pending | Pending |

Target: 0/3 genuine Codex/Sol passes on the eventual frozen tree.

## Outstanding requirements

- One valid Sol/xhigh difficulty result on the current workspace tree before any freeze decision.
- Three valid Codex/Sol xhigh standard failures on the eventual frozen tree.
- Valid Codex `/cheat` reward 0 on the final frozen tree.
- Claude Code / Opus 5 max standard and adversarial evidence remains outstanding under the written assignment unless waived.
