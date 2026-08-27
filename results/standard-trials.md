# Standard Trials

Status: final standard evidence has not yet been collected for the redesigned task.

## Live requirement versus current operational scope

Current live Terminal-Bench defaults still specify three standard trials each for:

| Agent | Model | Reasoning | Live required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

The current operational workflow is **Codex-only** because Claude Code subscription access is not available. Therefore Codex qualification can be completed now, but the repository must not claim full assignment compliance with the Claude requirement unless that requirement is later satisfied or waived.

Live `/run` uses Harbor 0.14.0. The local Codex runner uses Docker plus the subscription-auth mechanism documented by the Klavis assignment.

## Frozen task

```text
d84a5bf3df6a2c3ed7a523c7fee072936f4029e4
```

Do not count any trial with a different task-tree object.

## Required ordering

Do **not** launch the standard difficulty probe until deterministic/Harbor qualification, the Codex path check, and Codex `/cheat` qualification have succeeded. See `results/execution-plan.md`.

### Zero-Sol path check

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Required result: Oracle reward 1, NOP reward 0, `sol_calls=0`.

### One Sol/xhigh difficulty probe

Only after Codex `/cheat` qualification succeeds:

```bash
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
./scripts/run-codex-strong-test.sh
```

The wrapper:

- refuses a dirty or mismatched task tree;
- requires Harbor 0.14.0 and a working Docker daemon;
- requires Codex subscription auth at `~/.codex/auth.json`;
- runs one Harbor `codex` / `openai/gpt-5.6-sol` / `xhigh` trial;
- does not invoke `harbor analyze`;
- preserves raw Harbor/verifier evidence and deterministic metadata outside the repository.

If this is a clean solve, redesign the task at the task level and restart qualification. Do not collect additional standard trials on a task already demonstrated solvable and do not add trajectory-specific gotchas.

If it is a valid reward-0, inspect the trajectory and count it only if the failure is task-substantive and aligned with the intended systems invariant rather than ambiguity, timeout, authentication, verifier behavior, or infrastructure.

## Frozen Codex matrix

After a defensible reward-0 probe, freeze the exact task revision. The qualifying probe may count as trial 1 only if it used that exact frozen task/configuration and otherwise satisfies the assignment conditions. Complete three valid Codex trials total.

```bash
AGENTS=codex N_ATTEMPTS=3 ./scripts/run-standard-trials.sh
```

The standard wrapper defaults to Codex-only and refuses any task tree other than the qualified tree.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Evidence path | Failure classification |
|---|---|---|---:|---:|---|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending | Pending |

Target: **0/3 genuine Codex/Sol passes**.

## Outstanding Claude requirement

| Agent | Model | Reasoning | Status |
|---|---|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | Not currently runnable with available subscription access; still required by the written assignment unless waived. |

## Historical runs excluded from final evidence

Earlier diagnostics were useful for benchmark development but do not count toward the final matrix:

- an API-key/Modal GitHub workflow stopped before any model ran because repository provider credentials were absent;
- an early Sol run tested an obsolete task revision;
- a later Sol/xhigh run on a pre-concurrency revision exposed verifier artifacts involving an unstated cache-object filename convention;
- a clean Sol solution to the earlier single-generation transactional-publication design motivated the concurrency/stable-input redesign.

Authentication errors, rate limits, model unavailability, Harbor/Docker failures, verifier infrastructure failures, and unrelated infrastructure timeouts are invalid trials and are never counted as model failures.
