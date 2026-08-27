# Validation

Status: the current task tree is qualified through live static checks, local Oracle regression, verifier-determinism checks, mutation testing, Docker build, and Harbor Oracle/NOP under both the validation and agent-trial Harbor versions. The remaining empirical gates are the required frontier standard trials and adversarial trials.

## Frozen task revision

- Qualified task tree: `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4`
- Qualification workflow commit recorded by CI: `f6f1bc4989c6cdee98b618d0374b3a289006a20f`
- Machine-readable qualification record: `results/preflight-status.json`
- Subsequent repository commits have changed only trial runners and reviewer-facing documentation; the task tree remains exactly `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4`.

Do not count any frontier result unless its recorded task-tree hash matches that value.

## Qualification result

`results/preflight-status.json` records:

```text
preflight=success
harbor_docker=success
qualified=true
```

The preflight phase completed:

- current Terminal-Bench checkout and tooling setup;
- live static checks;
- local Oracle regression;
- repeated verifier-determinism checks;
- core and lifecycle mutation suites.

The Harbor/Docker phase completed:

- task Docker environment build;
- Oracle = 1 and NOP = 0 under Harbor 0.18.0;
- Oracle = 1 and NOP = 0 under Harbor 0.14.0.

Harbor 0.18.0 covers the current validation/review tooling generation. Harbor 0.14.0 is the version used by the live `/run` and `/cheat` workflows and by the assignment's subscription-auth agent commands.

## Mutation coverage

The qualified verifier rejects independent defects across incremental correctness, publication, concurrency, stable-input validation, reader lifetime, and garbage collection.

### Core/publication mutants

| Mutant | Defect |
|---|---|
| `starter` | Leaves the original non-transactional implementation in place. |
| `always-rebuild` | Destroys unchanged cache reuse. |
| `ignore-upstream` | Misses required-target output invalidation. |
| `ignore-definition` | Misses target-definition invalidation. |
| `retain-unreached-outputs` | Leaves outputs from an earlier broader snapshot visible. |
| `non-atomic-narrow-prune` | Narrows the visible snapshot through an unsafe in-place transition. |
| `publish-in-place` | Publishes target outputs independently instead of as one snapshot. |
| `no-selector` | Never exposes a committed snapshot selector. |
| `aborted-cache-reusable` | Allows interrupted-attempt state to become reusable as if committed. |
| `stale-base-commit` | Commits from a stale starting snapshot and loses concurrent reusable state. |
| `no-input-revalidation` | Commits without validating the stable input view. |
| `ignore-manifest-revalidation` | Misses a manifest race before publication. |
| `ignore-source-revalidation` | Misses a source-input race before publication. |
| `failpoint-only-staging` | Appears safe only under the cooperative failure hook rather than normal execution. |

### Lifecycle/GC mutants

| Mutant | Defect |
|---|---|
| `commit-seq-constant` | Violates strictly increasing committed generation order. |
| `gc-never-delete-generations` | Never reclaims obsolete generations. |
| `gc-ignore-reader-pins` | Reclaims a generation held by a live snapshot reader. |
| `gc-trust-stale-scan` | Deletes based on an unsafe stale GC scan. |
| `gc-sweep-active-writer` | Reclaims state still needed by an active build. |
| `gc-never-sweep-objects` | Never reclaims unreachable content-addressed objects. |

All of these mutations are rejected by the qualified verifier.

## Implementation-rubric review

`results/implementation-rubric-review.md` records the repository-side criterion audit. It reports no known fail criterion; the remaining concerns are empirical frontier difficulty and the reviewer burden created by an orchestration-heavy concurrency verifier.

This record is not represented as an official Terminal-Bench `/review` run. The final submission should preserve that distinction.

## Current Terminal-Bench frontier configuration

At the live upstream head checked on August 26, 2026, `.github/harbor-run-defaults.yml` specifies:

- 3 trials per agent;
- `claude-code` / `anthropic/claude-opus-5` / `reasoning_effort=max`;
- `codex` / `openai/gpt-5.6-sol` / `reasoning_effort=xhigh`;
- live workflow environment default `modal`;
- live workflow post-run analysis enabled.

The Klavis assignment separately provides subscription-auth examples using Docker. The local trial runners deliberately use Docker plus those subscription credentials so the required frontier models can be run without API-key billing. They preserve raw Harbor/verifier evidence and do not count infrastructure-invalid runs as model failures.

## Next gate: one Sol diagnostic

Before spending the full six-run standard matrix, validate the exact frozen task path without any Sol call:

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Required result: Oracle reward 1, NOP reward 0, and `sol_calls=0`.

Then run exactly one GPT-5.6 Sol/xhigh diagnostic on the same task tree:

```bash
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
./scripts/run-codex-strong-test.sh
```

A valid reward-0 result advances the task to trajectory review: verify that the failure is a genuine stated systems invariant rather than ambiguity, verifier behavior, timeout, authentication, or infrastructure. A clean solve is difficulty evidence and means the task does not yet satisfy the Klavis standard-trial gate.

## Final standard matrix

Only after the diagnostic is defensible, run the required matrix:

```bash
./scripts/run-standard-trials.sh
```

The acceptance condition is six valid genuine failures: three Opus 5/max and three GPT-5.6 Sol/xhigh. Authentication errors, rate limits, model unavailability, Harbor/Docker failures, verifier failures, and infrastructure timeouts are invalid and must not be counted.

## Adversarial matrix

The current live `/cheat` transform removes the ordinary anti-cheat sentence and appends `docs/prompts/hack-trial-prompt.md`. Reproduce it from a fresh upstream checkout:

```bash
git clone --depth 1 https://github.com/harbor-framework/terminal-bench.git /tmp/terminal-bench
uv tool install --force 'harbor==0.14.0'
TB3_REPO=/tmp/terminal-bench ./scripts/run-cheat-trials.sh
```

Run one valid adversarial attempt for each required agent. Every adversarial reward must be `0`.

## Remaining gates

1. Run the zero-Sol frozen-path preflight.
2. Run one valid Sol/xhigh diagnostic and classify the result.
3. If the diagnostic supports the task's difficulty, run the full 3+3 standard matrix.
4. Run the one-per-agent adversarial matrix; every reward must be 0.
5. Record exact evidence paths and genuine failure classifications in `results/standard-trials.md`, `results/cheat-trials.md`, and `results/failure-analysis.md`.
6. Before submission, refresh the upstream commit/config reference one final time and verify that the task tree used by every counted trial is still the frozen qualified tree.
