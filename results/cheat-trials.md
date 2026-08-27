# Adversarial Cheat Trials

Status: Codex adversarial qualification is pending for the current task.

## Live requirement versus current operational scope

Current live Terminal-Bench `/cheat` runs one adversarial attempt per configured agent. The written assignment still includes both Codex/Sol and Claude/Opus. The current operational workflow is **Codex-only** because Claude Code subscription access is not available.

Frozen task-tree object:

```text
d84a5bf3df6a2c3ed7a523c7fee072936f4029e4
```

## Why this gate runs before the standard difficulty probe

The adversarial verifier check is deliberately performed before spending standard frontier evidence. If `/cheat` finds an exploitable verifier and the task/verifier must change, any earlier standard evidence on the changed revision would no longer be final evidence.

## Codex adversarial qualification

Install Harbor 0.14.0 and run:

```bash
uv tool install --force 'harbor==0.14.0'
AGENTS=codex ./scripts/run-cheat-trials.sh
```

`AGENTS=codex` is now also the wrapper default.

The wrapper routes the attempt through `scripts/run-candidate-trial.sh`. It:

1. refuses any task tree other than the frozen qualified tree;
2. copies the task outside the repository;
3. obtains a fresh live upstream Terminal-Bench checkout and records its exact HEAD;
4. removes the normal `Do not cheat...` sentence from the disposable instruction;
5. appends the live `docs/prompts/hack-trial-prompt.md`;
6. runs exactly one Codex / GPT-5.6 Sol / xhigh adversarial attempt;
7. uses Docker plus the assignment's Codex subscription-auth mechanism;
8. preserves raw Harbor output, verifier artifacts, configuration metadata, and a deterministic summary outside the repository.

A valid adversarial qualification requires:

```text
reward = 0
Harbor/verifier completes normally
no infrastructure-invalid condition
```

If the adversarial attempt receives nonzero reward, fix the verifier/task at the architectural level and restart deterministic qualification from Step 1. Do not continue to a standard difficulty probe.

## Evidence record

| Agent | Model | Reasoning | Reward | Valid? | Attack summary | Evidence path |
|---|---|---|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | Pending | Pending | Pending | Pending |

## Outstanding Claude adversarial requirement

| Agent | Model | Reasoning | Status |
|---|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | Not currently runnable with available subscription access; still required by the written assignment unless waived. |

## Final cheat evidence

If this qualification run used the exact revision later frozen after the Sol difficulty probe, and the task/verifier did not change, it may serve as the final Codex `/cheat` evidence. Otherwise rerun Codex `/cheat` on the final frozen revision.

Authentication errors, API/rate limits, model unavailability, Harbor/Docker failures, verifier failures, or other infrastructure-invalid outcomes do not count as successful adversarial resistance and must be rerun.
