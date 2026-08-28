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

The frozen task is deterministically qualified (`68/68`, Harbor Oracle/NOP `1/0`). Deterministic qualification itself made zero frontier-model calls. Codex standard trial 1 has been audited and counted as a genuine exact-tree reward-0 failure; the remaining Codex standard trials are still being collected. No exact-tree `/cheat` result has yet been counted.

The automated implementation-rubric PASS remains outstanding and is not claimed here.

## Claude access limitation

The Claude adversarial entry is required by the current TB3 matrix, but it is **not being run for this submission** because the submission environment has no Claude Code subscription and no usable Anthropic API or Bedrock route. This missing entry remains explicitly visible below and is not replaced by an alternate model, authentication error, or inferred reward.

## Live `/cheat` reward semantics

The pinned workflow is reward-based. At its acceptance boundary, a failed `harbor run` is recorded as adversarial reward `0`; otherwise the parsed reward is recorded. The Klavis requirement is that every required adversarial entry receive zero reward and that any nonzero reward fails the requirement.

This intentionally differs from standard `/run`, where provider/auth/quota/container/timeout/agent exceptions invalidate the trial and cannot be counted as model failures.

The live workflow has no trial dimension for `/cheat`; its remote-backend JobConfig also uses `n_attempts: 1`. Therefore one exact-tree entry per required agent is the current adversarial target.

The repository's adversarial collector is `scripts/run-cheat-matrix.sh`. It requires:

- the exact current task tree;
- the same-tree qualification marker;
- exact agent/model/reasoning identity;
- exact pinned Terminal-Bench provenance;
- zero nonzero rewards;
- zero successful-but-unparsed rewards;
- zero incomplete same-tree evidence.

## Final matrix

| Task tree | Agent | Required | Status |
|---|---|---:|---|
| `d862ab3...` | Codex / Sol xhigh | 1 reward-0 | pending after remaining Codex standards |
| `d862ab3...` | Claude Code / Opus 5 max | 1 reward-0 | **NOT RUN — Claude access unavailable** |

No historical adversarial attempt counts toward either entry. Superseded adversarial runs and the reasoning for excluding them are documented in `results/failure-analysis.md`.

## Remaining adversarial work

After the remaining Codex standard runs are completed and audited:

```bash
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 \
bash scripts/run-cheat-matrix.sh
```

The Claude adversarial requirement will remain incomplete in the submitted matrix unless genuine Claude access becomes available. No non-Claude evidence will be used to fill it.

Any nonzero Codex adversarial reward blocks the controllable Codex-side adversarial result. Exact evidence directory, execution commit, Harbor status, result provenance, and reward will be recorded here after the Codex `/cheat` run.
