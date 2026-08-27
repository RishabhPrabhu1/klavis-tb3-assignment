# Validation

Status: the current strengthened request-protocol task is **pending deterministic qualification**. No frontier evidence has been collected on this exact tree.

## Current task revision

```text
f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8
```

Machine-readable status is in `results/preflight-status.json`.

Do not count any frontier result unless its recorded task-tree hash matches the exact tree under evaluation and that tree has first passed deterministic qualification.

## Why qualification restarted

Historical development established two important facts:

1. `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` contained an unstated verifier representation requirement and was invalidated.
2. `4eaf21ae9456395fb080be497852c0ff9623b8fa` fixed that verifier issue, passed deterministic qualification, and was then cleanly solved by GPT-5.6 Sol/xhigh with reward 1 and 37/37 tests.

That solve triggered a task-level redesign around exactly-once request IDs. The first redesign tree `3ddb933ae848f6912210371c6afc210ceea3f373` was then superseded before frontier testing when static review found missing composition coverage.

The current tree `f90cf...` adds:

- request-ID validation;
- duplicate-request coalescing;
- waiting duplicate takeover after owner death;
- cross-target reuse rejection;
- committed response-loss recovery at `request:after-publish`;
- replay after later commits and GC of the original generation;
- publication-time reconciliation when a build that started before the request commit later replaces the request generation.

## Required deterministic qualification

The local qualification script must pass, on the exact current tree:

```bash
TB3_REPO="$HOME/.cache/klavis-tb3-terminal-bench" \
  bash scripts/run-corrected-tree-local-qualification.sh
```

It runs:

1. live Terminal-Bench static checks;
2. full Oracle/reference verifier;
3. core/publication mutation matrix;
4. lifecycle/GC mutation matrix;
5. exactly-once request mutation matrix.

The request mutation matrix currently includes:

| Mutant | Defect |
|---|---|
| `replay-recommits` | Re-executes a committed request instead of replaying its original result. |
| `allow-cross-target-replay` | Allows one request ID to be reused for a different target. |
| `global-request-claim` | Serializes disjoint request IDs behind one global ownership lock. |
| `post-publish-is-precommit` | Places the response-loss failpoint before logical publication. |
| `invocation-start-only-recovery` | Reconciles stranded request state only at command start, allowing an already-in-flight later publisher to erase the recoverable request generation before journaling it. |

All mutations must be rejected. A surviving mutant is a verifier weakness and blocks frontier testing.

## Harbor zero-model gate

Only after local deterministic qualification is green, run Harbor 0.14.0 Oracle/NOP on the exact tree using a home-backed evidence path on macOS/Colima.

Required result:

```text
Oracle reward = 1
NOP reward = 0
sol_calls = 0
```

No standard or adversarial model trial should be spent before this gate passes.

## Live Terminal-Bench source-of-truth baseline

Previously rechecked at upstream HEAD:

```text
b2d4a935cfb1a6f621f611ea69421039cfccd158
```

At that revision the defaults specify:

- three standard trials per agent;
- `codex` / `openai/gpt-5.6-sol` / `reasoning_effort=xhigh`;
- `claude-code` / `anthropic/claude-opus-5` / `reasoning_effort=max`;
- live `/run` and `/cheat` install Harbor 0.14.0;
- `/cheat` applies the live `docs/prompts/hack-trial-prompt.md` transform.

Recheck upstream before final frontier evidence if Terminal-Bench advances.

## Frontier validity policy

Authentication errors, subscription/quota exhaustion, provider safety terminations, model unavailability, Docker/Harbor failures, verifier execution failures, and unrelated timeouts are invalid trials and never count as model failures.

A valid reward-0 standard result must be inspected for cause. Only a genuine task-substantive architectural/conceptual failure is a candidate for freezing. A clean solve triggers another task-level redesign and complete requalification.

## Current gate order

1. deterministic qualification of `f90cf...` — **next**;
2. live TB3 source-of-truth refresh if needed;
3. Harbor Oracle=1/NOP=0 with zero Sol calls;
4. valid current-tree `/cheat` attempt;
5. one valid Sol/xhigh standard difficulty probe;
6. freeze/redesign decision;
7. three valid Sol/xhigh trials on the frozen tree;
8. final valid `/cheat` evidence;
9. Claude/Opus evidence unless waived;
10. final documentation, fresh-clone reproduction, and audit.

The previous provider-safety-blocked `/cheat` runs and quota-exhausted standard run are historical invalid evidence only.
