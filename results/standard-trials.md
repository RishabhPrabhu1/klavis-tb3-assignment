# Standard Trials

## Required configuration

Klavis requires three valid standard `/run` trials for each configuration:

| Agent | Model | Reasoning | Required |
|---|---|---|---:|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |

All six must genuinely fail the verifier. Provider/auth/quota/container/timeout/agent exceptions do not count.

## Current candidate

```text
5620526fada6eebea16910fc62bf71746aaa40ea
```

Status: **pending same-tree deterministic qualification and frontier measurement**.

This is the optimistic multi-project `workspace-build` transaction design. Expensive member evaluation is private and must not hold global publication locks; commit uses coordinated validation, imports transaction-private project generations, merges written members into the latest workspace state, and publishes one immutable workspace generation. Disjoint transactions must progress and merge while overlapping/stale transactions retry. Exactly-once request replay and bounded cross-layer reclamation compose with the existing project/workspace protocols.

The task contract intentionally does not prescribe internal selector pathnames. The current verifier observes ordinary project/workspace current state semantically by generation metadata/commit sequence.

## Immediately previous transaction probe — not difficulty evidence

Previous tree:

```text
40cbd34104e1f0a549be23b46ef70655b728cece
```

Deterministic qualification:

```text
Oracle/reference: 66/66
mutations:        40/40 rejected
Harbor Oracle:    1
Harbor NOP:       0
Sol calls:        0
```

A standard Codex / GPT-5.6 Sol / xhigh probe then completed validly:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
verifier = 61 passed / 5 failed
```

The candidate implemented a substantial coherent project/workspace transaction architecture. All five failing tests were masked by one verifier representation assumption: `workspace_txn_harness.workspace_snapshot()` required `.workspace-cache/CURRENT`, while the contract allowed any atomic selector representation and the candidate used lowercase `.workspace-cache/current`.

Classification: **F4 verifier defect (secondary F3/F2 representation mismatch), not a legitimate model failure**. The helper was changed to resolve current workspace state semantically. The resulting corrected task tree is `5620526f...`.

## Prior valid solve

Tree:

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

That cross-project workspace snapshot design was deterministically qualified at 58/58 with 32/32 non-equivalent mutants rejected and Harbor Oracle/NOP = 1/0. A valid Sol/xhigh probe then scored reward 1.0 with 58/58 tests. It is therefore disqualified and retained only as historical evidence.

Evidence:

```text
~/.cache/klavis-tb3-runs/workspace-standard-probe/20260827T155729Z-standard-codex-cca1a50c3204
```

## Deadline policy

For the corrected `5620526f...` tree:

1. Pass same-tree static, 66/66 Oracle, 40/40 mutation, Harbor Oracle=1/NOP=0 with zero Sol calls.
2. Run one same-tree standard Sol/xhigh difficulty probe through the guarded frontier workflow.
3. A valid reward 1 means the candidate is still solvable and cannot be frozen.
4. A valid reward 0 caused by a real candidate implementation error under the clear contract is sufficient for deadline freeze. It does not need to be artificially escalated into a model-specific architectural trap.
5. Verifier/specification/infrastructure/provider failures remain invalid and must be repaired or rerun as appropriate.
6. After reviewer freeze approval, `CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh` collects only the additional valid Sol failures needed to reach three and stops immediately on a solve or invalid execution.

## Current standard matrix

| Task tree | Agent | Model | Reasoning | Trial | Status |
|---|---|---|---|---:|---|
| `5620526f...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | probe / potential final 1 | pending |
| `5620526f...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 2 | pending freeze |
| `5620526f...` | `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 3 | pending freeze |
| `5620526f...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 1 | pending access/freeze |
| `5620526f...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 2 | pending access/freeze |
| `5620526f...` | `claude-code` | `anthropic/claude-opus-5` | `max` | 3 | pending access/freeze |

Claude subscription OAuth is unavailable locally. A zero-out-of-pocket Amazon Bedrock route is being retained as the alternative access path; any final run must still preserve Claude Code + actual Opus 5 + max reasoning + Docker + auditable Harbor evidence.
