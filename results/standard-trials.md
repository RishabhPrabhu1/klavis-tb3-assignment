# Standard Trials

Status: final standard evidence has not yet been collected for the corrected task.

## Live requirement versus current operational scope

Current live Terminal-Bench defaults specify three standard trials each for:

| Agent | Model | Reasoning | Live required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

The current operational workflow is **Codex-only** because Claude Code subscription access is not available. Therefore Codex qualification can be developed now, but the repository must not claim full assignment compliance with the Claude requirement unless that requirement is later satisfied or waived.

Live `/run` uses Harbor 0.14.0. The local Codex runner uses Docker plus the subscription-auth mechanism documented by the Klavis assignment.

## Current qualified task

```text
4eaf21ae9456395fb080be497852c0ff9623b8fa
```

The previous tree `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` is invalidated and excluded from final evidence because a diagnostic exposed an unstated verifier representation requirement.

Do not count any standard trial with a different task-tree object.

## Deterministic prerequisites

The current tree has passed:

- live TB3 static checks;
- 37/37 full Oracle verifier tests;
- 14/14 core mutation rejections;
- 6/6 lifecycle/GC mutation rejections;
- Harbor Oracle reward 1;
- Harbor NOP reward 0;
- zero Sol calls during deterministic qualification.

## Difficulty-probe policy

Normally a standard difficulty probe follows a valid reward-0 `/cheat` trial. The official adversarial prompt has instead triggered the Codex provider cybersecurity classifier before substantive task work on both the old and corrected task trees. Those `/cheat` attempts are invalid and remain outstanding.

A narrowly scoped ordinary standard diagnostic is therefore permitted while the blocked `/cheat` evidence is preserved and audited. This exception is only for measuring task difficulty and does **not** satisfy the adversarial requirement.

For any standard attempt:

- provider/auth/runtime/agent exceptions invalidate the trial;
- reward 0 alone does not count as task difficulty evidence;
- a valid reward-0 must be classified from the trajectory as genuine architectural failure rather than ambiguity, verifier defect, timeout, or a narrow implementation mistake;
- a valid reward-1 means the task was solved and requires task-level redesign before any more standard trials.

## Corrected-tree diagnostic attempts

| Agent | Model | Reasoning | Attempt | Reward | Valid? | Evidence path | Classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | diagnostic 1 | 0.0 | **No** | `~/.cache/klavis-tb3-runs/standard-diagnostic-v2/20260827T065421Z-standard-codex-4dbbc90f4f93` | F6 provider/access failure: subscription usage limit terminated Codex before any patch was successfully applied |

### Diagnostic 1 details

The agent authenticated and performed partial analysis for approximately nine minutes. It identified the intended immutable-generation and short-lock architecture and began preparing an implementation. A patch application failed before modifying the starter, then Codex reported that the subscription usage limit had been reached and exited with code 1. Harbor recorded `NonZeroAgentExitCodeError`; the evidence auditor therefore classifies the run as `completed-with-exceptions` with `qualification_valid=false`.

The candidate `buildsys` files remained byte-for-byte equal to the starter. The verifier's 6 passed / 31 failed result is therefore a score for the unchanged starter, not for a completed Sol solution. This run must never be counted toward the required 0/3 matrix.

## Frozen Codex matrix

The final matrix has **not** started. Only after a valid standard probe demonstrates a genuine intended-crux failure should the exact task revision be frozen for final evidence collection.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Failure classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending | Pending |

Target: **0/3 genuine Codex/Sol passes**, with all three trials valid and uninterrupted.

## Next action

After Codex subscription capacity is available again, rerun exactly one ordinary Sol/xhigh diagnostic on task tree `4eaf21ae9456395fb080be497852c0ff9623b8fa`. Do not change the task or verifier because of the usage-limit failure. Do not start the final 3-trial matrix until that diagnostic completes normally and its failure, if any, is classified as genuine architectural difficulty.

## Outstanding requirements

- A valid corrected-tree Codex `/cheat` reward-0 trial is still required; safety-blocked attempts do not count.
- Claude Code / Opus 5 max standard and adversarial evidence remains outstanding under the written assignment unless waived.

Authentication errors, rate limits, subscription limits, model unavailability, Harbor/Docker failures, verifier infrastructure failures, and provider safety terminations are invalid trials and are never counted as model failures.
