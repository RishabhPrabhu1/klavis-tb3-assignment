# Standard Trials

Status: final frontier matrix not yet executed for the redesigned task.

The assignment requires three **valid** standard trials for each current default agent to receive reward 0 because the model genuinely fails the task:

| Agent | Model | Reasoning | Required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

Live `/run` uses Harbor 0.14.0. The local wrappers use Docker plus the subscription-auth mechanisms documented by the Klavis assignment.

## Usage-conserving Sol diagnostic

The Sol diagnostic must not be launched from an outer Codex session. `scripts/run-codex-strong-test.sh` invokes Harbor directly, so GPT-5.6 Sol/xhigh is used only by the actual Harbor candidate agent. The wrapper does not call `harbor analyze`; result collection and verifier parsing are deterministic shell/Python work.

Current frozen task-tree object:

```text
851f444971267df16b307fb2070588577e76c302
```

First run the zero-Sol local infrastructure preflight. It uses Harbor 0.14.0 Oracle and NOP only and makes **zero** GPT-5.6 Sol calls:

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=851f444971267df16b307fb2070588577e76c302 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Required result: Oracle reward 1, NOP reward 0, and `sol_calls=0` in the emitted preflight evidence.

Only after that passes, run exactly one Sol/xhigh diagnostic:

```bash
EXPECTED_TASK_TREE=851f444971267df16b307fb2070588577e76c302 \
./scripts/run-codex-strong-test.sh
```

The wrapper:

- refuses a dirty task tree;
- verifies Harbor is exactly 0.14.0;
- verifies Docker and Codex subscription authentication before the model starts;
- copies the task outside the repository before execution;
- requests one Harbor `codex` / `openai/gpt-5.6-sol` / `xhigh` trial only;
- never invokes `harbor analyze`;
- preserves raw Harbor output, verifier artifacts, the exact command, repository SHA, task-tree hash, and a deterministic summary outside the repository.

Do not change the task during that trial. If it is a valid reward-0, inspect the trajectory and confirm the failure is caused by an explicitly stated benchmark invariant. If it is a clean solve, treat that as difficulty evidence rather than adding a trajectory-specific test.

Claude can be run separately when subscription OAuth is available using the corresponding direct Harbor path; do not wrap it in an additional frontier-model session.

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
