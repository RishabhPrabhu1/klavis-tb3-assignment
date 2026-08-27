# Adversarial Cheat Trials

## Requirement

Current Terminal-Bench defaults set `trials: 3` for the shared `/run` and `/cheat` configuration. Therefore the frozen task needs **three adversarial trials per required agent/model configuration**, and every valid adversarial trial must receive reward 0.

Required final adversarial matrix:

| Agent | Model | Reasoning | Required reward-0 trials |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |

A cheat result counts only when:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
verifier completed normally
```

Provider/auth/quota/runtime/agent exceptions do not count even when the raw verifier reward is 0.

## Current candidate

```text
5620526fada6eebea16910fc62bf71746aaa40ea
```

Status: no completed adversarial evidence yet on this exact corrected tree. Same-tree deterministic qualification is the first gate.

## Prior Codex provider-safety behavior

Codex `/cheat` has repeatedly been terminated by OpenAI's cybersecurity safety classifier before substantive adversarial execution. These runs are preserved as infrastructure/provider evidence only; none satisfies the adversarial requirement.

Historical invalid attempts include:

| Task tree | Outcome |
|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `NonZeroAgentExitCodeError`; provider safety block; tree later invalidated |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | provider safety block; tree later validly solved |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | provider safety block on superseded exactly-once design |
| `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` | provider safety block on superseded workspace snapshot design |
| `40cbd34104e1f0a549be23b46ef70655b728cece` | same provider-safety pattern during the transaction-design cycle; not valid adversarial evidence |

The guarded frontier runner may use an audited same-tree cybersecurity safety block only as permission to proceed to one ordinary difficulty probe. It never reclassifies the raw reward as a cheat pass.

## Current matrix

| Task tree | Agent | Trial | Status |
|---|---|---:|---|
| `5620526f...` | Codex / Sol xhigh | 1 | pending same-tree qualification / guarded attempt |
| `5620526f...` | Codex / Sol xhigh | 2 | pending freeze |
| `5620526f...` | Codex / Sol xhigh | 3 | pending freeze |
| `5620526f...` | Claude Code / Opus 5 max | 1 | pending access/freeze |
| `5620526f...` | Claude Code / Opus 5 max | 2 | pending access/freeze |
| `5620526f...` | Claude Code / Opus 5 max | 3 | pending access/freeze |

## Claude access

The Klavis document's preferred no-API-price route is Claude Code OAuth obtained by `claude setup-token`. That route requires an eligible paid Claude subscription, which is not available locally.

Claude Code also officially supports Amazon Bedrock. Bedrock exposes the required model as `anthropic.claude-opus-5`; a zero-out-of-pocket AWS Free Tier/credit route will be tested after the task is frozen. Any Bedrock result must still preserve the required Claude Code agent, actual Opus 5 model, max reasoning, Docker environment, and auditable Harbor result.

## Outstanding adversarial work

The final frozen tree still needs:

1. three valid completed Codex `/cheat` reward-0 trials;
2. three valid completed Claude Code / Opus 5 / max `/cheat` reward-0 trials.

If Codex continues to be blocked by the provider safety classifier, those attempts must be documented as invalid and the written Klavis requirement remains technically outstanding unless the evaluator explicitly accepts the provider limitation.
