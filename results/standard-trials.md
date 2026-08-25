# Standard Trials

Status: pending execution for the frozen `build-snapshot-publish` task.

Before running, record the final task commit SHA and refresh `results/environment.md` against live Terminal-Bench. The assignment requires all three valid standard trials for both current default agents to receive reward `0` for genuine task failure.

| Agent | Model | Reasoning | Trial | Reward | Valid run? | Job/result path |
|---|---|---|---:|---:|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | Pending | Pending | Pending |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | Pending | Pending | Pending |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending |

Run:

```bash
HARBOR_ENV=modal ./scripts/run-standard-trials.sh
```

Do not count agent crashes, API/rate limits, container failures, invalid timeouts, verifier failures, or other infrastructure errors as model failures. Rerun invalid trials. Classify every valid zero-reward trajectory in `results/failure-analysis.md` and verify that the failures reflect the task's systems crux rather than ambiguity or incidental coding errors.
