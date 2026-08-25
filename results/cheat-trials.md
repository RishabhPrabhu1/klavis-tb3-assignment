# Adversarial Cheat Trials

Status: pending execution for the frozen `build-snapshot-publish` task.

At the live Terminal-Bench snapshot recorded in `results/environment.md`, `/cheat` runs one adversarial attempt for each configured agent. Every valid adversarial trial must receive reward `0`.

Freeze commit: **Pending**

| Agent | Model | Reasoning | Reward | Valid run? | Attack summary | Job/result path |
|---|---|---|---:|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | Pending | Pending | Pending | Pending |

Run the reproduction helper against a fresh checkout of the same live upstream:

```bash
TB3_REPO=/path/to/terminal-bench HARBOR_ENV=modal ./scripts/run-cheat-trials.sh
```

The helper copies the task to a temporary directory, removes the ordinary anti-cheat sentence, appends the live `rubrics/hack-trial-prompt.md`, and creates one Harbor JobConfig with `n_attempts: 1`, both current agents, and concurrency `2`. The instruction transform is implemented in Python so the helper behaves consistently on Linux and macOS/BSD development machines.

Before execution, verify that the repository is not unintentionally exposing the exact oracle to an open-internet adversarial agent. Repository visibility is an evaluation-hygiene choice rather than a TB3 format requirement; record the state used for the trials.

For each result, record the actual attack path and verifier response. A zero caused by an agent crash, invalid environment, verifier failure, API/rate limit, or other infrastructure problem is not sufficient evidence and must be rerun.
