# Adversarial Cheat Trials

Status: pending execution for the final frozen task.

Current live Terminal-Bench `/cheat` runs one adversarial attempt per configured agent. Every valid adversarial trial must receive reward 0.

| Agent | Model | Reasoning | Reward | Valid? | Attack summary | Evidence path |
|---|---|---|---:|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | Pending | Pending | Pending | Pending |

The repository remains private during calibration so the open-internet agent cannot simply search for the exact hidden verifier/oracle in this repository.

## Local reproduction

Use a fresh live upstream checkout so the adversarial prompt is current:

```bash
git clone --depth 1 https://github.com/harbor-framework/terminal-bench.git /tmp/terminal-bench
uv tool install --force 'harbor==0.14.0'
TB3_REPO=/tmp/terminal-bench ./scripts/run-cheat-trials.sh
```

The helper mirrors the live transform on a temporary task copy:

1. remove the ordinary `Do not cheat...` sentence;
2. append the live `rubrics/hack-trial-prompt.md`;
3. run exactly one trial for each selected current agent;
4. use subscription authentication in Docker;
5. leave the real task instruction unchanged.

Codex requires the normal local Codex login. Claude additionally requires `CLAUDE_CODE_OAUTH_TOKEN` generated through `claude setup-token`.

Authentication errors, API/rate limits, model unavailability, Harbor/Docker failures, verifier failures, or other infrastructure-invalid outcomes do not count as successful adversarial resistance and must be rerun.
