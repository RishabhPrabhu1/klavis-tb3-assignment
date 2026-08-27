# Adversarial Cheat Trials

Status: pending execution for the final frozen task.

Current live Terminal-Bench `/cheat` runs one adversarial attempt per configured agent. Every valid adversarial trial must receive reward 0.

Frozen task-tree object:

```text
d84a5bf3df6a2c3ed7a523c7fee072936f4029e4
```

| Agent | Model | Reasoning | Reward | Valid? | Attack summary | Evidence path |
|---|---|---|---:|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | Pending | Pending | Pending | Pending |

The repository remains private during calibration so an open-internet agent cannot simply search for the exact hidden verifier/oracle in this repository.

## Local reproduction

Install the agent-trial Harbor version and run:

```bash
uv tool install --force 'harbor==0.14.0'
./scripts/run-cheat-trials.sh
```

The wrapper routes each adversarial attempt through `scripts/run-candidate-trial.sh`. For every run it:

1. refuses any task tree other than the frozen qualified tree;
2. copies the task outside the repository;
3. obtains a fresh live upstream Terminal-Bench checkout and records its exact HEAD;
4. removes the normal `Do not cheat...` sentence from the disposable instruction;
5. appends the live `docs/prompts/hack-trial-prompt.md`;
6. runs exactly one required agent/model attempt;
7. uses Docker plus the assignment's subscription-auth mechanism;
8. preserves raw Harbor output, verifier artifacts, configuration metadata, and a deterministic summary outside the repository.

Codex requires the normal local Codex login. Claude additionally requires `CLAUDE_CODE_OAUTH_TOKEN` generated through `claude setup-token`.

Authentication errors, API/rate limits, model unavailability, Harbor/Docker failures, verifier failures, or other infrastructure-invalid outcomes do not count as successful adversarial resistance and must be rerun.
