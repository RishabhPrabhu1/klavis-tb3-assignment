# Instruction-to-Test Coverage

This matrix tracks the current `tasks/build-snapshot-publish/instruction.md`. Expected build bytes are derived by the independent verifier-side `tests/reference.py`; candidate code runs separately as an unprivileged user.

| Instruction requirement | Runtime coverage | Negative evidence |
|---|---|---|
| Public ordinary `build --project --target --report` interface and requested-target behavior | all ordinary build tests; explicit non-default `package`, `app`, `alpha`, `beta`, and alternate-graph targets | hard-coded final-target implementations fail closure/report assertions |
| Public request build `build --project --target --request-id --report` interface | `test_exactly_once_requests.py` | starter request wrapper ignores request IDs and fails the request suite |
| Request-ID syntax constraints | invalid empty/control-character/overlength IDs fail without a committed generation | request wrapper cannot simply accept arbitrary identifiers |
| `bundle`, recursive `@include`, `concat`, and `sha256` semantics | initial build, transitive edit/new include, alternate graphs, stable-input retry | independent clean reference model derives expected bytes |
| Exact report shape, DFS `requires` order, source-dependency semantics, output paths and SHA-256 | `_assert_report` on ordinary invocations; request replay equality checks | exact-key/order/type/dependency assertions |
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
| Committed request replay returns the original report without another publication | replay after changed input/later request; generation/current/token set unchanged | `replay-recommits` |
| A committed request ID cannot be reused for a different target | focused cross-target replay test checks status 2 and unchanged committed state | `allow-cross-target-replay` |
| A pre-commit request-owner crash does not consume the request ID | `request:after-claim` failpoint followed by successful retry | failpoint placement/state-machine errors fail recovery |
| Concurrent duplicate request IDs converge on one publication | live owner paused after claim while duplicate waits; both successful callers receive the same report and only one generation exists | starter; replay/claim mutations |
| Waiting duplicate takes over after owner death without a wall-clock lease | owner is killed while follower is already blocked; follower proceeds and commits | process-lifetime ownership is required; stale time-based ownership would hang/fail |
| Disjoint request IDs make progress independently | paused request owner plus successful different request ID | `global-request-claim` |
| `request:after-publish` is a committed response-loss window | process exits 86 after publication; retry returns original result with no second generation | `post-publish-is-precommit` |
| Committed request state survives later publications and GC of its original generation | lost-response request, later request publication, `KEEP=0` GC, replay without current change | request state cannot live only in a reclaimable generation |
| Publication-time reconciliation protects a stranded request from a build that started earlier | ordinary `docs` build pauses before the request commits; lost-response `app` request commits; ordinary build later publishes; GC deletes old generation; replay must still succeed without a new publication | `invocation-start-only-recovery` |
| Deterministic request pause hook is functional and does not block disjoint progress | `request:after-claim` duplicate/disjoint/takeover cases | broken/global ownership fails deterministic synchronization or progress |
| Deterministic build/GC pause hooks remain functional | existing concurrency/stability/GC tests | missing/broken hooks fail synchronization |
| Task is not tied to the visible sample graph | non-default closures, alternate six-target graph, separate concurrent graph, runtime manifest/source rewrites | graph/name-hard-coded solutions fail behavior-derived expectations |

## Verifier trust boundary

These mechanisms protect grading rather than add hidden task requirements:

- `[verifier].environment_mode = "separate"`; tests, reference truth, and reward logic are verifier-image-owned.
- Candidate implementation is executed as `nobody`; verifier/reference state remains root-owned.
- Candidate project source/manifest fixtures are verifier-controlled while cache/output namespaces remain writable by the candidate process.
- Candidate filesystem mutation helpers also drop to the candidate UID.
- Candidate process groups and detached candidate-UID descendants are terminated/reaped after each invocation.
- Concurrent request tests deliberately defer generic UID cleanup where an intentional sibling candidate process is still live, preventing verifier-induced false failures.
- The normal-publication observer freezes candidate descendants before inspecting the visible snapshot.
- Request-record representation is not fixed by the verifier; tests assert public behavior, generation counts/current state, and replay durability rather than a hidden journal path.
- `/logs/verifier` and reward generation remain verifier-owned.
- `tests/test.sh` performs no runtime network installation; verifier dependencies are pinned in `tests/Dockerfile`.

The mutation matrix is development evidence that each major behavioral invariant is load-bearing. Final `/cheat` trials are still required external evidence against an actively adversarial agent.
