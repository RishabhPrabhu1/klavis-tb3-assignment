# Adversarial Cheat Trials

## Requirement

At Terminal-Bench HEAD `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480`, Docker `/cheat` runs one matrix entry per `(task × agent_config)` with no three-trial dimension. The final frozen task therefore needs one adversarial run for each required configuration:

| Agent | Model | Reasoning | Required |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 reward-0 run |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 1 reward-0 run |

This differs deliberately from standard `/run`, where provider/auth/quota/container/timeout/agent exceptions invalidate a trial and three genuine verifier failures per agent are required.

## Live TB3 reward semantics

The pinned `/cheat` workflow is reward-based. Its Docker job does the equivalent of:

```text
if harbor run succeeds:
    reward = parsed Mean, default 0
else:
    reward = 0
```

It then records that adversarial reward. The written Klavis requirement likewise says every adversarial trial must have reward 0 and any nonzero reward fails.

Therefore a `/cheat` agent exception or provider safety refusal is **not evaluated under the stricter standard `/run` validity rule**. If the exact required adversarial run records reward `0`, it satisfies the live `/cheat` reward condition; any nonzero reward means the verifier was defeated.

## Current candidate

```text
316aaf9804a82cc43e6075a657f3effda0c5717c
```

Final exact-tree qualification/freeze is pending. No historical adversarial run counts toward this final tree.

## Historical Codex safety behavior

Codex adversarial attempts have repeatedly exited through OpenAI's cybersecurity safety classifier with `NonZeroAgentExitCodeError` and reward `0`. Earlier local bookkeeping labeled those runs invalid because it reused standard-trial validity rules. Review of the actual TB3 `/cheat` workflow showed that this was stricter than the source of truth: the workflow explicitly maps a failed `harbor run` to adversarial reward 0.

A predecessor-tree Codex attempt on `fc064cac...` showed the same pattern:

```text
reward = 0
result exception = NonZeroAgentExitCodeError
classification in old local audit = safety block
```

That run remains historical because the task tree changed, but the outcome confirms the expected adversarial provider behavior. Final Codex `/cheat` still needs one exact-tree run after freeze.

## Final matrix

| Task tree | Agent | Required | Status |
|---|---|---:|---|
| `316aaf...` | Codex / Sol xhigh | 1 reward-0 | pending qualification/freeze |
| `316aaf...` | Claude Code / Opus 5 max | 1 reward-0 | pending provider access/freeze |

Final collection uses `scripts/run-deadline-cheat-matrix.sh`, which mirrors the live reward semantics and stops on any nonzero/unparsed/incomplete exact-tree adversarial result.

## Claude access

The required configuration remains Claude Code / `anthropic/claude-opus-5` / max. Direct paid Anthropic access is not assumed. Repository tooling can route Claude Code through Amazon Bedrock and includes a bounded entitlement smoke test, but a zero-out-of-pocket eligible provider entitlement is still an external prerequisite.

## Outstanding adversarial work

After exact-tree qualification and freeze:

1. run one Codex `/cheat` attempt on the final tree and require recorded reward 0;
2. run one Claude Code / Opus 5 / max `/cheat` attempt on the final tree and require recorded reward 0;
3. any nonzero adversarial reward blocks submission readiness.
