# Validation

Status: the current task tree is qualified through live static checks, local Oracle regression, repeated verifier-determinism checks, mutation testing, Docker build, and Harbor Oracle/NOP under both the validation and agent-trial Harbor versions. The remaining empirical work is Codex execution-path validation, Codex `/cheat` qualification, one Sol difficulty probe, the frozen Sol evidence matrix, and final audit. Claude remains an outstanding written assignment requirement unless later satisfied or waived.

## Frozen task revision

- Qualified task tree: `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4`
- Qualification workflow commit recorded by CI: `f6f1bc4989c6cdee98b618d0374b3a289006a20f`
- Machine-readable qualification record: `results/preflight-status.json`
- Subsequent repository commits have changed trial runners and documentation only; the task tree remains exactly `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4`.

Do not count any frontier result unless its recorded task-tree hash matches that value.

## Qualification result

`results/preflight-status.json` records:

```text
preflight=success
harbor_docker=success
qualified=true
```

The deterministic phase completed:

- current Terminal-Bench checkout and tooling setup;
- live static checks;
- local Oracle regression;
- repeated verifier-determinism checks;
- core and lifecycle mutation suites.

The Harbor/Docker phase completed:

- task Docker environment build;
- Oracle = 1 and NOP = 0 under Harbor 0.18.0;
- Oracle = 1 and NOP = 0 under Harbor 0.14.0.

Harbor 0.18.0 covers the current validation/review tooling generation. Harbor 0.14.0 is used by live `/run` and `/cheat` and by the assignment's subscription-auth agent commands.

## Mutation coverage

The qualified verifier rejects defects across incremental correctness, transactional publication, concurrency, stable-input validation, reader lifetime, and garbage collection.

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

All listed mutations are rejected by the qualified verifier.

## Implementation-rubric review

`results/implementation-rubric-review.md` records the repository-side criterion audit. It reports no known fail criterion; the remaining concerns are empirical frontier difficulty and reviewer burden from an orchestration-heavy concurrency verifier.

This record is not represented as an official Terminal-Bench `/review` run.

## Live Terminal-Bench source-of-truth recheck

Rechecked upstream on 2026-08-26 at:

```text
b2d4a935cfb1a6f621f611ea69421039cfccd158
```

`.github/harbor-run-defaults.yml` specifies:

- 3 standard trials per agent;
- `codex` / `openai/gpt-5.6-sol` / `reasoning_effort=xhigh`;
- `claude-code` / `anthropic/claude-opus-5` / `reasoning_effort=max`;
- live `/run` and `/cheat` environment default `modal`;
- post-run analysis enabled.

The live `/run` and `/cheat` workflows install Harbor 0.14.0. The live `/cheat` transform removes the ordinary anti-cheat sentence and appends `docs/prompts/hack-trial-prompt.md` to the task instruction before the adversarial attempt.

The local subscription-auth runners intentionally use Docker while matching the required Codex model/reasoning settings. The current operational workflow is Codex-only because Claude Code subscription access is unavailable; this does not erase the assignment's outstanding Claude requirement.

## Active gate order

The authoritative operational sequence is recorded in `results/execution-plan.md`:

1. deterministic qualification — complete;
2. live TB3 source-of-truth recheck — complete;
3. Harbor Oracle/NOP qualification — complete;
4. local Codex execution/auth path check — pending;
5. Codex `/cheat` qualification — pending;
6. one genuine Sol/xhigh difficulty probe — pending;
7. decision/freeze gate — pending;
8. complete three valid Sol/xhigh trials total — pending;
9. final Codex `/cheat` evidence — pending;
10. documentation/final audit — pending.

## Next local gate: zero-Sol Codex path check

On the machine that holds Codex subscription credentials:

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Required result:

```text
Oracle reward = 1
NOP reward = 0
sol_calls = 0
```

This verifies the frozen task path, Docker/Harbor environment, and Codex-auth prerequisites without spending a Sol task trial.

## Next empirical gate: Codex `/cheat`

Only after the zero-Sol path check succeeds:

```bash
AGENTS=codex ./scripts/run-cheat-trials.sh
```

A valid normally completed adversarial run must receive reward 0. If it does not, fix the verifier/task and restart deterministic qualification before spending standard difficulty evidence.

## One Sol difficulty probe

Only after `/cheat` qualification is clean:

```bash
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
./scripts/run-codex-strong-test.sh
```

If Sol cleanly solves the task, redesign at the task level and return to deterministic qualification. Do not add model-specific gotchas and do not collect more standard trials on a demonstrated-solvable candidate.

If it is a valid reward-0, inspect the trajectory and verify the failure is caused by the intended systems invariant rather than ambiguity, verifier behavior, timeout, authentication, or infrastructure.

## Frozen Codex evidence

After a defensible genuine failure, freeze the exact revision and complete three valid Sol/xhigh trials total. The qualifying probe may count only if it used the same frozen task/configuration and is otherwise valid.

```bash
AGENTS=codex N_ATTEMPTS=3 ./scripts/run-standard-trials.sh
```

Target: Sol 0/3 genuine passes.

## Final adversarial evidence and audit

If the earlier Codex `/cheat` qualification used the exact revision later frozen and no task/verifier semantics changed, it may be retained as final Codex adversarial evidence; otherwise rerun it. Then record exact evidence paths and failure classifications in `results/standard-trials.md`, `results/cheat-trials.md`, and `results/failure-analysis.md`, run final deterministic/fresh-clone validation, refresh upstream provenance, and verify every documentation claim against preserved artifacts.
