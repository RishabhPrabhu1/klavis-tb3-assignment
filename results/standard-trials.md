# Standard Trials

Status: the previous cross-project workspace snapshot tree was **cleanly solved** by Codex / GPT-5.6 Sol / xhigh and is disqualified. A new optimistic `workspace-build` transaction tree is under deterministic qualification; no frontier trial may run against it yet.

## Live requirement versus current operational scope

Current Terminal-Bench defaults require three standard trials each for:

| Agent | Model | Reasoning | Required trials |
|---|---|---|---:|
| `claude-code` | `anthropic/claude-opus-5` | `max` | 3 |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | 3 |

Current operational evidence collection is Codex-only because Claude Code subscription access is unavailable. Full written-assignment compliance must not be claimed unless Claude evidence is later obtained or the requirement is waived.

## Superseded workspace snapshot tree — valid solve

Tree:

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

That tree was deterministically qualified at 58/58 with 32/32 non-equivalent mutants rejected and Harbor Oracle/NOP = 1/0 with zero Sol calls. Its same-tree `/cheat` attempt was invalid because of the provider cybersecurity safety classifier, but its ordinary standard difficulty probe was fully valid:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 1.0
verifier = 58 passed / 0 failed
```

Evidence:

```text
~/.cache/klavis-tb3-runs/workspace-standard-probe/20260827T155729Z-standard-codex-cca1a50c3204
```

Codex implemented the intended project-generation, request, reader/writer, GC, workspace stable-cut, workspace exactly-once, and transitive-reclamation architecture without suspicious verifier shortcuts. This was a clean intended solve and therefore required another task-level redesign.

## Current optimistic transaction redesign

Current task tree:

```text
bff3b135d88174ac463d6e35a6cc30c4066dd8ea
```

This tree adds `workspace-build`, an optimistic write transaction over a subset of workspace members. The expensive member builds run privately outside workspace/project publication locks. At commit the implementation must validate workspace write-set versions, ordinary project-current versions, and the exact manifest/source observations used by each private build. Stale attempts retry.

On success, written members become new immutable private project generations without moving ordinary project `CURRENT`. The workspace commit merges only those members into the **latest** workspace state, so disjoint transactions preserve one another while overlapping writes retry. New crash boundaries distinguish pre-commit imported-but-unreachable project history from committed post-publication response loss. Exactly-once replay must survive later overlapping transactions, workspace GC of the original workspace snapshot, and project GC of the original private generation.

Required zero-model qualification for this exact tree:

- live TB3 static checks;
- full Oracle/reference verifier, expected 66 tests;
- 14 core mutants;
- 6 lifecycle/GC mutants;
- 5 project request mutants;
- 7 workspace snapshot/cross-layer mutants;
- 8 optimistic workspace transaction mutants;
- 40/40 total mutants rejected;
- Harbor Oracle=1 / NOP=0 / `sol_calls=0`.

Until that passes, `/cheat`, standard Sol, final matrices, and Claude trials are blocked.

## Frontier policy for the transaction tree

1. Qualify `bff3b135d88174ac463d6e35a6cc30c4066dd8ea` deterministically with zero model calls.
2. Attempt same-tree Codex `/cheat` once. Provider/auth/runtime exceptions remain invalid.
3. If `/cheat` is again provider-safety blocked, retain audited same-tree evidence and use the explicit one-off standard diagnostic exception.
4. Run one Sol/xhigh standard difficulty probe.
5. A valid reward-1 solve causes another redesign.
6. Freeze only on a valid reward-0 result whose primary failure is genuinely conceptual/architectural rather than a local bug, ambiguity, verifier defect, timeout, or provider failure.
7. Only after freeze collect the required 3/3 standard failures per required model/config and valid adversarial reward-0 evidence.

## Historical evidence

- `42cba8ad00bebf316048d1470033c1742a20ec97`: exactly-once tree; standard run formally invalid due quota, but preserved candidate passed 48/48 and was treated only as near-solve development evidence.
- `4eaf21ae9456395fb080be497852c0ff9623b8fa`: valid clean Sol/xhigh solve at 37/37; superseded.

## Frozen Codex matrix

Not started.

| Agent | Model | Reasoning | Trial | Reward | Valid? | Classification |
|---|---|---|---:|---:|---|---|
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 1 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 2 | Pending | Pending | Pending |
| `codex` | `openai/gpt-5.6-sol` | `xhigh` | final 3 | Pending | Pending | Pending |
