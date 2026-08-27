# Standard Trials

## Required configuration

Klavis requires three valid standard `/run` trials for each configuration:

| Agent | Model | Reasoning | Required |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |

All six must genuinely fail the verifier. Provider/auth/quota/container/timeout/agent exceptions do not count.

## Current qualified candidate

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

Exact-tree deterministic qualification is complete:

```text
TB3 static checks: PASS
Oracle/reference:  66/66
mutations:         40/40 rejected
Harbor Oracle:     1.000
Harbor NOP:        0.000
frontier calls:    0 during qualification
```

Qualification evidence:

```text
~/.cache/klavis-tb3-runs/transaction-preflight/20260827T213154Z-d2837bf220bd
```

The candidate is the optimistic multi-project `workspace-build` transaction design. Expensive member evaluation is private and does not globally serialize publication; commit validates workspace-member versions, ordinary project-current versions, manifests, and exact source observations. Disjoint transactions must progress and merge while overlapping/stale transactions retry. Transaction-private project generations do not move ordinary project current, and exactly-once replay composes with later replacement and bounded workspace/project reclamation.

A guarded same-tree Codex/Sol/xhigh standard probe is currently the next difficulty measurement. No valid standard result on `fc064cac...` is recorded in this ledger yet.

## Historical transaction probe — verifier defect, not difficulty evidence

Tree:

```text
40cbd34104e1f0a549be23b46ef70655b728cece
```

A valid Codex / GPT-5.6 Sol / xhigh probe scored reward 0 with 61/66 tests. All five failures were masked by one verifier representation assumption: `workspace_txn_harness.workspace_snapshot()` required `.workspace-cache/CURRENT`, while the contract allowed any atomic selector representation and the candidate used lowercase `.workspace-cache/current`.

Classification: **F4 verifier defect**, not a legitimate model failure. The helper was subsequently made representation-neutral.

## Prior valid solve

Tree:

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

That cross-project workspace snapshot design was deterministically qualified at 58/58 with 32/32 non-equivalent mutants rejected and Harbor Oracle/NOP = 1/0. A valid Sol/xhigh probe then scored reward 1.0 with 58/58 tests. It is disqualified and retained only as historical evidence.

Evidence:

```text
~/.cache/klavis-tb3-runs/workspace-standard-probe/20260827T155729Z-standard-codex-cca1a50c3204
```

## Deadline freeze policy

For `fc064cac...`:

1. Deterministic qualification is complete.
2. Run one same-tree Sol/xhigh standard probe through the guarded frontier workflow.
3. A valid reward 1 means the candidate remains solvable and cannot be frozen.
4. A valid reward 0 caused by a real candidate implementation error under the clear contract is sufficient for deadline freeze; it does not need to be artificially escalated into a special architectural trap.
5. Verifier/specification/infrastructure/provider failures remain invalid.
6. After reviewer freeze approval, the final matrix runner collects only the additional valid standard failures needed to reach three and stops on any solve or invalid execution.

## Current standard matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `fc064cac...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | probe / potential final 1 | running/pending result |
| `fc064cac...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 2 | pending freeze |
| `fc064cac...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 3 | pending freeze |
| `fc064cac...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | pending access/freeze |
| `fc064cac...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | pending access/freeze |
| `fc064cac...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | pending access/freeze |

Claude subscription OAuth is unavailable locally. The zero-out-of-pocket fallback is Claude Code through Amazon Bedrock, provided AWS Free Tier/credits permit actual Opus 5 access without requiring a paid-plan upgrade. Final evidence must still preserve Claude Code + actual Opus 5 + max reasoning + Docker + auditable Harbor output.
