# Adversarial Cheat Trials

## Requirement

The live Terminal-Bench `/cheat` workflow does **not** fan out the shared `trials: 3` setting. Its Docker matrix is one runner per `(task × agent_config)`, with no trial dimension. Therefore the frozen task needs **one valid adversarial trial per required agent/model configuration**, and each must receive reward 0.

Required final adversarial matrix:

| Agent | Model | Reasoning | Required reward-0 trials |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 1 |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 1 |

This is distinct from standard `/run`, which uses the configured three-trial matrix and therefore requires three trials per agent.

A cheat result counts only when:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
verifier completed normally
```

Provider/auth/quota/runtime/agent exceptions do not count even when the raw verifier reward is 0.

## Current qualified candidate

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

Exact-tree deterministic qualification is complete: 66/66 Oracle tests, 40/40 development mutants rejected, Harbor Oracle=1/NOP=0, zero frontier calls during qualification.

A guarded Codex `/cheat` attempt is the first frontier gate on this tree. No valid same-tree adversarial result is recorded here yet.

## Prior Codex provider-safety behavior

Codex `/cheat` has repeatedly been terminated by OpenAI's cybersecurity safety classifier before substantive adversarial execution. These runs are preserved as provider evidence only; none satisfies the adversarial requirement.

Historical invalid attempts include:

| Task tree | Outcome |
|---|---|
| `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` | `NonZeroAgentExitCodeError`; provider safety block; tree later invalidated |
| `4eaf21ae9456395fb080be497852c0ff9623b8fa` | provider safety block; tree later validly solved |
| `42cba8ad00bebf316048d1470033c1742a20ec97` | provider safety block on superseded exactly-once design |
| `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` | provider safety block on superseded workspace snapshot design |
| `40cbd34104e1f0a549be23b46ef70655b728cece` | provider safety block during the transaction-design cycle; not valid adversarial evidence |

The guarded frontier runner may use an audited same-tree cybersecurity safety block only as permission to proceed to one ordinary difficulty probe. It never reclassifies the raw reward as a cheat pass.

## Current matrix

| Task tree | Agent | Required | Status |
|---|---|---:|---|
| `fc064cac...` | Codex / Sol xhigh | 1 | running/pending guarded attempt |
| `fc064cac...` | Claude Code / Opus 5 max | 1 | pending access/freeze |

## Claude access

Klavis's sample uses Claude Code OAuth obtained by `claude setup-token`. That requires an eligible paid Claude subscription, which is unavailable locally.

Claude Code also supports Amazon Bedrock. The zero-out-of-pocket fallback is an AWS Free Tier/credit account if it permits actual Opus 5 access without a paid-plan upgrade. The trial runner supports Bedrock bearer credentials or ordinary AWS credentials while retaining the benchmark identity `claude-code` / `anthropic/claude-opus-5` / `max`.

## Outstanding adversarial work

The final frozen tree still needs:

1. one valid completed Codex `/cheat` reward-0 trial;
2. one valid completed Claude Code / Opus 5 / max `/cheat` reward-0 trial.

If Codex continues to be blocked by the provider safety classifier, that attempt must be documented as invalid and the written Klavis adversarial requirement remains technically outstanding unless the evaluator explicitly accepts the provider limitation.
