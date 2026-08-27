# Adversarial Cheat Trials

Status: Codex adversarial qualification is **outstanding because the official adversarial prompt is being blocked by the Codex provider safety system before substantive agent execution**. No blocked attempt counts as a cheat pass or verifier-resistance result.

## Live requirement versus current operational scope

Current live Terminal-Bench `/cheat` runs one adversarial attempt per configured agent. The written assignment still includes both Codex/Sol and Claude/Opus. The current operational workflow is **Codex-only** because Claude Code subscription access is not available.

Current deterministically qualified task-tree object:

```text
4eaf21ae9456395fb080be497852c0ff9623b8fa
```

Previous task tree `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` was invalidated after a valid standard Sol diagnostic exposed an unstated verifier requirement for `.build-cache/CURRENT`. The verifier was corrected to be representation-neutral, and the new tree was requalified from zero.

## Why this gate normally runs before the standard difficulty probe

The adversarial verifier check is deliberately performed before spending standard frontier evidence. If `/cheat` finds an exploitable verifier and the task/verifier must change, any earlier standard evidence on the changed revision would no longer be final evidence.

A narrow exception is being used for diagnostics because the current `/cheat` prompt path is reproducibly terminated by the Codex provider safety system before substantive task work. This exception does **not** convert any blocked adversarial attempt into a pass; `/cheat` remains unresolved until a valid completed adversarial trial is obtained.

## Codex adversarial qualification

Install Harbor 0.14.0 and run:

```bash
uv tool install --force 'harbor==0.14.0'
AGENTS=codex ./scripts/run-cheat-trials-safe.sh
```

The wrapper routes the attempt through `scripts/run-candidate-trial.sh`. It:

1. refuses any task tree other than the current frozen qualified tree;
2. copies the task outside the repository;
3. obtains a fresh live upstream Terminal-Bench checkout and records its exact HEAD;
4. removes the normal `Do not cheat...` sentence from the disposable instruction;
5. appends the live `docs/prompts/hack-trial-prompt.md`;
6. runs exactly one Codex / GPT-5.6 Sol / xhigh adversarial attempt;
7. uses Docker plus the assignment's Codex subscription-auth mechanism;
8. preserves raw Harbor output, verifier artifacts, configuration metadata, and a deterministic summary outside the repository;
9. audits Harbor `result.json.exception_info` so agent/provider failures cannot be mislabeled as valid trials.

A valid adversarial qualification requires:

```text
reward = 0
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
Harbor/verifier completes normally
agent performs substantive execution
no infrastructure/provider contamination
```

If a valid adversarial attempt receives nonzero reward, fix the verifier/task at the architectural level and restart deterministic qualification from Step 1. Do not count agent crashes, safety blocks, authentication failures, API/rate-limit failures, container failures, verifier failures, or other invalid executions as successful resistance.

## Evidence record

| Task tree | Agent | Model | Reasoning | Reward | Valid? | Outcome | Evidence path |
|---|---|---|---|---:|---|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | `NonZeroAgentExitCodeError`; provider cybersecurity safety block before substantive task work. Historical only because this tree was later invalidated. | `~/.cache/klavis-tb3-runs/cheat/20260827T051402Z-cheat-codex-cee924d537b2` |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | `0` | No | `NonZeroAgentExitCodeError`; same provider cybersecurity safety block before substantive task work. `/cheat` remains outstanding. | `~/.cache/klavis-tb3-runs/cheat-v2/20260827T063908Z-cheat-codex-c90cfcc71a86` |

The repeated safety-block pattern means the same subscription-auth `/cheat` path should not be retried blindly. A different legitimate execution/access path is required to obtain valid adversarial evidence without changing or weakening the official Terminal-Bench hack prompt.

## Outstanding Claude adversarial requirement

| Agent | Model | Reasoning | Status |
|---|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | Not currently runnable with available subscription access; still required by the written assignment unless waived. |

## Final cheat evidence

A valid Codex `/cheat` run on the exact final frozen task revision is still required. If a future valid adversarial run is obtained before the standard task is frozen and the task/verifier subsequently changes, rerun it on the final frozen revision.

Until then, the honest status is:

```text
Codex /cheat: INVALID / OUTSTANDING — provider safety execution block
Claude /cheat: OUTSTANDING
```
