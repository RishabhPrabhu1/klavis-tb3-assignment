# Instruction-to-Test Coverage

This matrix tracks the current `tasks/build-snapshot-publish/instruction.md`. Expected build bytes are derived independently in verifier-owned `tests/reference.py`; candidate code executes as an unprivileged user.

## Project build and publication

| Contract requirement | Primary verifier coverage | Negative/mutation evidence |
|---|---|---|
| Public `build --project --target --report` interface and target closures | ordinary build/cache/recovery suites across `app`, `package`, `fingerprint`, `alpha`, `beta`, alternate graph | hard-coded graph/final-target implementations fail |
| `bundle`, recursive `@include`, `concat`, `sha256` semantics | build cache, input stability, recovery contract | independent clean reference derives bytes |
| Exact report schema/order/dependencies/output SHA | shared `_assert_report` | exact key/order/type assertions |
| Selective caching and invalidation | direct/transitive input, new include, target-definition, unrelated change cases | core mutants: always rebuild, ignore upstream/definition/revalidation |
| Missing/corrupt materialized outputs recover | build-cache recovery tests | starter/in-place behavior insufficient |
| Each successful publication exposes exactly reached output closure | narrow `app`/`package`, recovery tests | retain-unreached-output mutant |
| Old/new snapshot atomicity, never a mixture | failpoints + Linux publication observer | publish-in-place/no-selector/failpoint-only mutations |
| Interrupted attempt does not publish/erase another commit | concurrent builds/recovery | stale/aborted-state mutants |
| Disjoint target closure progresses while another build is paused | concurrent build tests | project-wide evaluation lock fails progress |
| Stale-base writer preserves still-valid cache records from concurrent commit | paused `alpha` / completed `beta` composition | stale-base-commit mutant |
| Manifest/source view revalidated immediately before publication | input/manifest stability tests | no revalidation mutants |

## Project generation, readers, and GC

The contract specifies project generations, records, `snapshot.json`, object naming, and `commit_seq`; verifier inspection of those small schemas is contractual. Ordinary project current itself is observed through the public `read` interface rather than a selector pathname or transaction-private metadata convention.

| Contract requirement | Primary verifier coverage |
|---|---|
| Positive unique/increasing project `commit_seq` | lifecycle/reclamation harness |
| Reader pins exactly one ordinary-current generation and returns pinned bytes | reclamation reader tests + public current-token probe |
| Killed reader immediately stops pinning | killed-reader test |
| Multiple readers pin until last exits | last-reader test |
| GC retains current + live pins + KEEP history | reclamation tests |
| KEEP is additional to live pins | keep-budget tests |
| GC revalidates concurrent project commit | paused GC / concurrent commit |
| GC revalidates reader acquired during scan | paused GC / reader race |
| Active writer state is not reclaimed | writer-during-GC test |
| Crashed/interrupted GC remains recoverable | `gc:after-generations` recovery |
| Quiescent object store equals retained-record reachability | object-reclamation assertions |

## Exactly-once project requests

| Contract requirement | Primary verifier coverage | Mutation evidence |
|---|---|---|
| REQUEST_ID validation | invalid ID cases | starter fails |
| First success binds target + exact report | exact replay test | replay-recommits |
| Same ID/different target -> status 2/no state change | cross-target case | allow-cross-target-replay |
| Live owner retains ownership while duplicate waits | paused owner + follower case | ownership semantics |
| Precommit owner crash leaves ID reusable | `request:after-claim` | state-machine mutants |
| Concurrent duplicates commit once | duplicate owner/follower | request claim mutants |
| Waiting duplicate takes over immediately after owner death | killed-owner tests | process lifetime required |
| Disjoint request IDs progress | paused request + other request | global-request-claim |
| `request:after-publish` is committed response loss | post-publish recovery | post-publish-is-precommit |
| Replay survives later publications + GC | stranded request case | journal cannot live only in generation |
| Older in-flight publisher preserves stranded request before replacing generation | ordinary-build publication race | invocation-start-only-recovery |

## Workspace snapshots

The contract specifies immutable workspace generations with `snapshot.json`, workspace `commit_seq`, and member metadata. It intentionally does **not** prescribe a current-selector pathname; verifier current-state helpers resolve the highest committed workspace sequence.

| Contract requirement | Primary verifier coverage | Workspace mutation evidence |
|---|---|---|
| `workspace-capture` exact plan/request replay | workspace capture replay | replay-recaptures |
| Request ID bound to canonical member map | cross-plan reuse | allow-cross-plan-replay |
| Live capture owner retains ownership while duplicate waits | paused owner + follower | ownership behavior |
| Post-publish response loss survives later capture + workspace GC | lost-response workspace test | postpublish-is-precommit |
| Stable simultaneous listed-project cut | deterministic `workspace:after-member:left` with both publishers blocked | no-stable-cut-locks |
| Unlisted/disjoint work remains independent | stable-cut and disjoint-request cases | global request claim mutation |
| Workspace duplicate owner death takeover | waiting duplicate takeover | request ownership behavior |
| Workspace reader pins historical workspace + project generation | live workspace reader test | ignore-reader-pins |
| Workspace KEEP is additional to live reader pins | workspace keep-budget test | ignore-reader-pins |
| Retained workspace snapshots transitively protect project generations | project GC protection test | project-gc-ignore-workspace-references |
| Project generation becomes reclaimable after last workspace reference retires | workspace retirement + project GC | cross-layer mutation suite |

## `workspace-build` transactions

| Contract requirement | Primary verifier coverage | Transaction mutation evidence |
|---|---|---|
| Transaction member generation is visible through workspace while ordinary project current remains unchanged | `test_workspace_build_publishes_private_member_generations_without_moving_project_currents`; ordinary current observed via public `read` | transaction-current mutant |
| Staged work does not globally block disjoint workspace/project publication | paused left transaction while disjoint right transaction completes | global-stage-lock mutant |
| Disjoint transactions merge against latest workspace state instead of clobbering | disjoint staged transactions | stale-whole-workspace merge mutant |
| Overlapping workspace write-set change forces retry | competing transaction during pause | write-version-validation mutant |
| Source change during stage forces retry/fresh output | source mutation during stage | source-validation mutant |
| Ordinary project publication during stage invalidates transaction | ordinary build while transaction paused | project-version-validation mutant |
| `workspace-build:after-import` is precommit; workspace unchanged; orphan import reclaimable; request reusable | precommit import crash test | import-boundary/request-consumption mutant |
| `workspace-build:after-publish` is committed response loss | postpublish response-loss test | postpublish-boundary mutant |
| First replay can occur only after later overlapping transaction, workspace GC, and project GC of original workspace-only generation | deferred first replay validates stranded snapshot/report fields, followed by an identical second replay with no publication | durable replay/reclamation behavior |
| Request ID binds exact transaction plan | cross-plan transaction test | cross-plan behavior |
| Successful report includes attempts, updated write set, complete members and generation metadata | transaction success/replay assertions | schema/behavior coverage |

The transaction suite contains eight focused non-equivalent mutants. Together with 14 core, 6 lifecycle/GC, 5 project-request, and 7 workspace-snapshot mutants, the development mutation matrix contains 40 mutants. Mutation results are supporting negative controls; the authoritative submission gates are current TB3 static checks, exact-tree Oracle/Harbor validation, implementation rubric, and required agent matrices.

## Representation-neutrality audit

Three verifier assumptions were found and removed during development rather than counted as model failures:

1. Ordinary current was once inferred from newest project-history `commit_seq`; workspace-only transaction history makes that invalid. The verifier now asks the required public `read` interface which generation it acquired.
2. Workspace current was once read through `.workspace-cache/CURRENT`; current workspace state is now resolved by documented workspace `commit_seq`, so selector naming is private.
3. Transaction post-publish recovery once read a private `request_report` snapshot field. The current test performs no early replay; its first retry occurs only after later overlapping publication plus workspace/project reclamation and is validated against the stranded committed snapshot through public behavior.

The remaining directly inspected project/workspace generation and object fields are the small schemas explicitly documented by the instruction. Request journals, transaction markers, lock files, reader leases, selector names, and staging layouts are not required by verifier tests.

## Verifier trust boundary

- `[verifier].environment_mode = "separate"`; tests/reference/reward are verifier-image-owned.
- Candidate implementation runs as `nobody`; source/reference fixtures remain verifier-controlled.
- Candidate process invocations use verifier-owned stdout/stderr files rather than inherited pipes, start isolated sessions, record pre-launch candidate-UID baselines, and clean the process group plus newly created candidate-UID descendants on completion or timeout.
- Intentional concurrent sibling processes are excluded from cleanup until their tests complete.
- Tests assert public behavior and explicitly documented durable storage, not hidden request/lock/selector representations.
- `tests/test.sh` performs no runtime network installation; verifier dependencies are pinned in `tests/Dockerfile`.
- `/logs/verifier` and reward generation remain verifier-owned.

The mutation matrix is development evidence that each major invariant is load-bearing. Final standard and adversarial agent matrices remain required external evidence.
