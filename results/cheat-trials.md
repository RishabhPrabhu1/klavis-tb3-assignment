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

The frozen task is deterministically qualified (`68/68`, Harbor Oracle/NOP `1/0`). Deterministic qualification itself made zero frontier-model calls. An exact-tree Codex **standard** invocation is currently running, but no final model result has yet been counted. No `/cheat` invocation has yet been counted on the frozen tree.

The automated implementation-rubric PASS remains outstanding and is not claimed here.

## Live `/cheat` reward semantics

The pinned workflow is reward-based. At its acceptance boundary, a failed `harbor run` is recorded as adversarial reward `0`; otherwise the parsed reward is recorded. The Klavis requirement is that every required adversarial entry receive zero reward and that any nonzero reward fails the requirement.

This intentionally differs from standard `/run`, where provider/auth/quota/container/timeout/agent exceptions invalidate the trial and cannot be counted as model failures.

The live workflow has no trial dimension for `/cheat`; its remote-backend JobConfig also uses `n_attempts: 1`. Therefore one exact-tree entry per required agent is the current adversarial target.

The repository's authoritative adversarial collector is `scripts/run-deadline-cheat-matrix.sh`. It requires:

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
| `d862ab3...` | Codex / Sol xhigh | 1 reward-0 | pending completion/audit of standard freeze decision |
| `d862ab3...` | Claude Code / Opus 5 max | 1 reward-0 | pending provider access |

No historical adversarial attempt counts toward either entry.

## Historical Codex safety behavior

On superseded trees, Codex `/cheat` attempts repeatedly exited through a cybersecurity safety classifier with `NonZeroAgentExitCodeError` and reward `0`. Earlier local bookkeeping incorrectly applied standard-trial validity rules to those adversarial attempts. Review of the pinned live `/cheat` workflow established that adversarial acceptance is reward-based instead.

Those runs remain historical because their task trees differ from `d862ab3...`. They provide no final matrix credit.

## Remaining adversarial work

After the Codex standard tree is accepted as frozen for the final matrix:

```bash
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 \
bash scripts/run-deadline-cheat-matrix.sh
```

If Claude access becomes available, the required Claude adversarial entry uses the same frozen tree and pinned upstream workflow. If access remains unavailable at delivery, that missing entry must be disclosed rather than inferred.

Any nonzero adversarial reward blocks full submission readiness. Exact evidence directory, execution commit, Harbor status, result provenance, and reward will be recorded here after each final run.