# Standard Trials

Status: pending execution in the current TB3 environment.

The assignment requires three genuine failures for each current default configuration:

| Agent | Model | Reasoning | Required trials | Result |
|---|---|---:|---:|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending |

Run:

```bash
./scripts/run-standard-trials.sh
```

Do not count agent crashes, API/rate limits, container failures, invalid timeouts, or other infrastructure errors as model failures. Save the Harbor job paths and classify every trajectory in `results/failure-analysis.md` after execution.
