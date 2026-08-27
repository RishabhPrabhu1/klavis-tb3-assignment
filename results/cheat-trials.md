# Adversarial Cheat Trials

## Requirement

Klavis requires adversarial `/cheat` trials for both required configurations, and every valid adversarial trial must receive reward 0.

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

| Task tree | Agent | Model | Reasoning | Status |
|---|---|---|---|---|
| `5620526f...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | pending same-tree qualification / guarded attempt |
| `5620526f...` | `claude-code` | `anthropic/claude-opus-5` | `max` | pending same-tree qualification and Claude access |

## Claude access

The Klavis document's preferred no-API-price route is Claude Code OAuth obtained by `claude setup-token`. That route requires an eligible paid Claude subscription, which is not available locally.

Claude Code also officially supports Amazon Bedrock. Bedrock exposes the required model as `anthropic.claude-opus-5`; a zero-out-of-pocket AWS Free Tier/credit route will be tested only after the task is frozen. Any Bedrock result must still preserve the required Claude Code agent, actual Opus 5 model, max reasoning, Docker environment, and auditable Harbor result.

## Outstanding adversarial work

The final frozen tree still needs:

1. a valid completed Codex `/cheat` reward-0 result, unless the hiring evaluator explicitly accepts the documented provider-safety limitation;
2. a valid completed Claude Code / Opus 5 / max `/cheat` reward-0 result.

Invalid safety/auth/provider runs must be documented but cannot be represented as satisfying the requirement.
