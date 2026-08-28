# Adversarial Cheat Trials

## Requirement

At the pinned Terminal-Bench workflow snapshot, `/cheat` runs one matrix entry per `(task × agent_config)` with no three-trial dimension. The frozen task therefore needs one adversarial run for each required configuration:

| Agent | Model | Reasoning | Required |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 reward-0 run |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 1 reward-0 run |

Pinned Terminal-Bench revision:

```text
79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

## Frozen candidate

```text
d862ab3cc79718e959e9cc7ec1b792540990a24d
```

The frozen task is deterministically qualified (`68/68`, Harbor Oracle/NOP `1/0`) and the Codex standard matrix is complete at `3/3` valid reward-0 failures.

## Claude access limitation

The Claude adversarial entry is required by the current TB3 matrix, but it was **not run for this submission** because the submission environment has no Claude Code subscription and no usable Anthropic API or Bedrock route. This missing entry remains explicit and is not replaced by an alternate model, authentication failure, or inferred result.

## `/cheat` acceptance semantics

The pinned workflow is reward-based. At its acceptance boundary, every required task × agent entry must receive reward `0`; any nonzero reward fails the adversarial requirement. This differs intentionally from standard `/run`, where provider/auth/quota/container/timeout/agent exceptions cannot be counted as model failures.

The live workflow has no trial dimension for `/cheat`; its remote-backend JobConfig also uses `n_attempts: 1`.

## Final matrix

| Task tree | Agent | Required | Status |
|---|---|---:|---|
| `d862ab3...` | Codex / Sol xhigh | 1 reward-0 | **COMPLETE — reward 0** |
| `d862ab3...` | Claude Code / Opus 5 max | 1 reward-0 | **NOT RUN — Claude access unavailable** |

## Codex adversarial result

```text
execution commit: 90ba6964ae64fa04be2e58162c59b0be186023d8
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
agent/model: codex / openai/gpt-5.6-sol
reasoning: xhigh
environment: docker
Harbor: 0.14.0
Terminal-Bench HEAD: 79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
runtime: 1m50s
Harbor exit status: 0
reward: 0.0
result exception: NonZeroAgentExitCodeError
verifier: 6 passed / 62 failed / 0 skipped
```

Evidence directory:

```text
~/.cache/klavis-tb3-runs/transaction-cheat-final/20260828T031436Z-92630-cheat-codex-90ba6964ae64
```

Collector summary:

```text
runner_status=0
reward_zero_now=1/1
nonzero_now=0
unparsed_now=0
incomplete_now=0
wrong_tb3_provenance_now=0
reward_zero=1
target=1
status=CHEAT_MATRIX_COMPLETE
```

The Harbor result contained `NonZeroAgentExitCodeError`, but the pinned adversarial workflow is evaluated by reward rather than by the standard-run validity rule. The exact-tree collector recorded the entry as reward `0`, with correct agent/model/reasoning and Terminal-Bench provenance, and no nonzero, unparsed, incomplete, or wrong-provenance entries. Therefore the Codex `/cheat` requirement is complete.

No historical adversarial attempt counts toward this result. The Claude adversarial requirement remains incomplete solely because Claude access was unavailable.