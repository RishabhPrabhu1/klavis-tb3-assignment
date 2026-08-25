# Standard Trials

Status: pending execution for the frozen `build-snapshot-publish` task.

Before the final matrix, record the final task commit SHA and refresh `results/environment.md` against live Terminal-Bench. The assignment requires all three valid standard trials for both current default agents to receive reward `0` for genuine task failure.

A one-attempt diagnostic run for both agents is available first:

```bash
HARBOR_ENV=modal N_ATTEMPTS=1 JOB_NAME=build-snapshot-publish-diagnostic ./scripts/run-standard-trials.sh
```

## Diagnostic execution record

A private-repository diagnostic was triggered on 2026-08-25 at commit `00ddd90d8a91a15ef34d92d80bc118b3cf615172` through GitHub Actions run `32869754495`.

The privacy guard passed, confirming the workflow was running against a private repository. The run then stopped before any model trial because the standalone repository had none of the four credentials required by the current Modal trial configuration:

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `MODAL_TOKEN_ID`
- `MODAL_TOKEN_SECRET`

The model-trial step was skipped and no trajectory artifact was produced. This is an infrastructure-invalid attempt and **does not count** as a failure for either frontier model.

Once the four repository secrets are present, update `.github/frontier-diagnostic-trigger` to launch a fresh one-attempt diagnostic. If either agent solves the task cleanly, do not spend the final matrix yet; inspect the trajectory and reassess intrinsic difficulty. If both fail for the intended systems reason, freeze the task and run the required matrix with the script's default `N_ATTEMPTS=3`:

```bash
HARBOR_ENV=modal ./scripts/run-standard-trials.sh
```

| Agent | Model | Reasoning | Trial | Reward | Valid run? | Job/result path |
|---|---|---|---:|---:|---|---|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | Pending | Pending | Pending |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | Pending | Pending | Pending |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 2 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 | Pending | Pending | Pending |

Do not count agent crashes, API/rate limits, container failures, invalid timeouts, verifier failures, or other infrastructure errors as model failures. Rerun invalid trials. Classify every valid zero-reward trajectory in `results/failure-analysis.md` and verify that the failures reflect the task's systems crux rather than ambiguity or incidental coding errors.
