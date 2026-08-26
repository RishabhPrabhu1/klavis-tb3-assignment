# Standard Trials

Status: final frontier matrix not yet executed for the redesigned task.

The assignment requires three **valid** standard trials for each current default agent to receive reward 0 because the model genuinely fails the task:

| Agent | Model | Reasoning | Required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

Live `/run` uses Harbor 0.14.0. The local wrapper uses Docker plus the subscription-auth mechanisms documented by the Klavis assignment.

## Usage-conserving diagnostic

Before spending the six final attempts, run one Codex diagnostic against the exact frozen task revision:

```bash
uv tool install --force 'harbor==0.14.0'
AGENTS=codex N_ATTEMPTS=1 ./scripts/run-standard-trials.sh
```

Do not change the task during that trial. If it is a valid reward-0, inspect the trajectory and confirm the failure is caused by an explicitly stated benchmark invariant. If it is a clean solve, treat that as difficulty evidence rather than adding a trajectory-specific test.

Claude can be run separately when subscription OAuth is available:

```bash
export CLAUDE_CODE_OAUTH_TOKEN='...'
AGENTS=claude N_ATTEMPTS=1 ./scripts/run-standard-trials.sh
```

## Historical runs excluded from final evidence

Earlier diagnostics were useful for benchmark development but **do not count** toward the final matrix:

- an API-key/Modal GitHub workflow stopped before any model ran because repository provider credentials were absent;
- an early Sol run tested an obsolete task revision;
- a later clean Sol/xhigh run on the pre-concurrency task officially received reward 0 but its only failures were verifier artifacts involving an unstated cache-object filename convention;
- that clean run also established that Sol could solve the earlier single-generation transactional-publication problem, which motivated the deliberate concurrency/stable-input redesign.

The obsolete API-key workflow and trigger have been removed from the repository.

## Final matrix record

Fill this only with valid trials on the exact final task tree:

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Failure classification |
|---|---|---|---:|---:|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | Pending | Pending | Pending | Pending |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | Pending | Pending | Pending | Pending |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending | Pending |

Authentication errors, rate limits, model unavailability, Harbor/Docker failures, verifier infrastructure failures, and unrelated infrastructure timeouts are invalid trials and are never counted as model failures.
