# Instruction-to-Test Coverage

This matrix tracks the current `tasks/build-snapshot-publish/instruction.md`. Expected build bytes are derived by the independent verifier-side `tests/reference.py`; candidate code runs separately as an unprivileged user.

| Instruction requirement | Runtime coverage | Negative evidence |
|---|---|---|
| Public `build --project --target --report` interface and requested-target behavior | all tests; explicit non-default `package`, `app`, `alpha`, `beta`, and alternate-graph targets | hard-coded final-target implementations fail closure/report assertions |
| `bundle`, recursive `@include`, `concat`, and `sha256` semantics | initial build, transitive edit/new include, alternate graphs, stable-input retry | independent clean reference model derives expected bytes |
| Exact report shape, DFS `requires` order, source-dependency semantics, output paths and SHA-256 | `_assert_report` on every successful invocation | exact-key/order/type/dependency assertions |
| Repeat build caches unchanged work | initial/repeat and post-recovery repeats | `always-rebuild` |
| Direct/transitive input changes selectively invalidate affected work | transitive edit, new include, concurrency/input-stability cases | `ignore-upstream` |
| Target-definition changes selectively invalidate | target-definition test; manifest-stability tests | `ignore-definition` |
| Unrelated source changes do not rebuild targets | unrelated-input test | `always-rebuild` |
| Missing/corrupt materialized outputs recover deterministically | `test_materialized_output_recovery` | ordinary in-place starter behavior is insufficient for the broader snapshot contract |
| Successful invocation exposes exactly its reached target closure | narrow `app` and `package` snapshots; concurrent `alpha`/`beta` snapshots | `retain-unreached-outputs` |
| Reader never observes a mixed old/new producer/downstream snapshot | cooperative failpoints across sample and alternate graphs; Linux normal-build publication observer | `starter`, `publish-in-place`, `failpoint-only-staging`, `no-selector` |
| Failpoint exit does not commit work produced only by the interrupted attempt | post-failpoint recovery on sample and alternate graphs | `aborted-cache-reusable` |
| Previously committed unaffected cache state survives recovery | all interruption recovery cases | `always-rebuild`, `aborted-cache-reusable` |
| Concurrent successful invocations are serializable | deterministic paused `alpha` + completing `beta` sequence | `stale-base-commit` |
| A paused invocation cannot prevent a disjoint reached closure from completing | deterministic pausepoint concurrency test | implementations holding project-wide exclusion during evaluation time out/fail the concurrent `beta` build |
| A stale-base later commit preserves still-valid cache state committed concurrently | after `beta` commits and older `alpha` resumes, later full build must cache both leaves | `stale-base-commit` |
| An interrupted concurrent writer cannot publish or erase another successful commit | paused/failpoint `alpha` with successful concurrent `beta` | starter/in-place and aborted-state designs fail visible/cache assertions |
| Successful build reflects a stable source-input view, including apparent cache hits | source-only change after paused cache-hit evaluation | `no-input-revalidation`, `ignore-source-revalidation` |
| Successful build reflects a stable manifest view | manifest-only change after paused cache-hit evaluation | `no-input-revalidation`, `ignore-manifest-revalidation` |
| A stale rebuilt attempt is retried against fresh manifest/source state and discovers new transitive inputs | built-path pause followed by manifest output-path change plus new recursive include | `no-input-revalidation`; separate manifest/source mutants are independently rejected by the focused tests |
| Deterministic pause hook remains functional and does not block disjoint progress | all concurrency/stability tests | missing/broken pause hook fails deterministic synchronization |
| Task is not tied to the visible sample graph | non-default closures, alternate six-target graph, separate concurrent graph, runtime manifest/source rewrites | graph/name-hard-coded solutions fail behavior-derived expectations |

## Verifier trust boundary

These mechanisms protect grading rather than add hidden task requirements:

- `[verifier].environment_mode = "separate"`; tests, reference truth, and reward logic are verifier-image-owned.
- Candidate implementation is executed as `nobody`; verifier/reference state remains root-owned.
- Candidate project source/manifest fixtures are verifier-controlled while cache/output namespaces remain writable by the candidate process.
- Candidate filesystem mutation helpers also drop to the candidate UID.
- Candidate process groups and detached candidate-UID descendants are terminated/reaped after each invocation.
- The normal-publication observer freezes candidate descendants before inspecting the visible snapshot.
- `/logs/verifier` and reward generation remain verifier-owned.
- `tests/test.sh` performs no runtime network installation; verifier dependencies are pinned in `tests/Dockerfile`.

The mutation matrix is development evidence that each major behavioral invariant is load-bearing. Final `/cheat` trials are still required external evidence against an actively adversarial agent.
