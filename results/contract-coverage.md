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

The contract explicitly specifies project generations under `.build-cache/generations/TOKEN/`, records, `snapshot.json`, objects, and `commit_seq`; verifier inspection of those paths is therefore contractual rather than a hidden representation assumption.

| Contract requirement | Primary verifier coverage |
|---|---|
| Positive unique/increasing project `commit_seq` | lifecycle/reclamation harness |
| Reader pins exactly one generation and returns pinned bytes | reclamation reader tests |
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
| Precommit owner crash leaves ID reusable | `request:after-claim` | state-machine mutants |
| Concurrent duplicates commit once | duplicate owner/follower | request claim mutants |
| Waiting duplicate takes over immediately after owner death | killed-owner tests | process lifetime required |
| Disjoint request IDs progress | paused request + other request | global-request-claim |
| `request:after-publish` is committed response loss | post-publish recovery | post-publish-is-precommit |
| Replay survives later publications + GC | stranded request case | journal cannot live only in generation |
| Older in-flight publisher preserves stranded request before replacing generation | ordinary-build publication race | invocation-start-only-recovery |

## Workspace snapshots

The contract explicitly specifies immutable workspace generations under `.workspace-cache/generations/TOKEN/` with `snapshot.json`, workspace `commit_seq`, and member metadata. It intentionally does **not** prescribe a `CURRENT` pathname; verifier current-state helpers resolve the highest committed workspace sequence.

| Contract requirement | Primary verifier coverage | Workspace mutation evidence |
|---|---|---|
| `workspace-capture` exact plan/request replay | workspace capture replay | replay-recaptures |
| Request ID bound to canonical member map | cross-plan reuse | allow-cross-plan-replay |
| Post-publish response loss survives later capture + workspace GC | lost-response workspace test | postpublish-is-precommit |
| Stable simultaneous listed-project cut | deterministic `workspace:after-member:left` with both publishers blocked | no-stable-cut-locks |
| Unlisted/disjoint work remains independent | stable-cut and disjoint-request cases | global request claim mutation |
| Workspace duplicate owner death takeover | waiting duplicate takeover | request ownership behavior |
| Workspace reader pins historical workspace + project generation | live workspace reader test | ignore-reader-pins |
| Workspace KEEP is additional to live reader pins | workspace keep-budget test | ignore-reader-pins |
| Retained workspace snapshots transitively protect project generations | project GC protection test | project-gc-ignore-workspace-references |
| Project generation becomes reclaimable after last workspace reference retires | workspace retirement + project GC | cross-layer mutation suite |

## Optimistic `workspace-build` transactions

| Contract requirement | Primary verifier coverage | Transaction mutation evidence |
|---|---|---|
| Private member generation is published only through workspace; ordinary project current unchanged | `test_workspace_build_publishes_private_member_generations_without_moving_project_currents` | transaction-current/private-generation mutants |
| Transaction-private project history is explicitly marked `workspace_transaction: true` | same test directly inspects documented `snapshot.json` marker | prevents current/history ambiguity |
| Expensive private stage holds no global workspace/project publication lock | paused left transaction while disjoint right transaction completes | global-stage-lock mutant |
| Disjoint transactions merge against latest workspace state instead of clobbering | disjoint staged transactions | stale-whole-workspace merge mutant |
| Overlapping workspace write-set change forces whole retry | competing transaction during pause | write-version-validation mutant |
| Source change during private stage forces retry/fresh output | source mutation during stage | source-validation mutant |
| Ordinary project publication during stage invalidates transaction | ordinary build while transaction paused | project-version-validation mutant |
| `workspace-build:after-import` is precommit; workspace unchanged; orphan import reclaimable; request reusable | precommit import crash test | import-boundary mutant |
| `workspace-build:after-publish` is committed response loss | postpublish response-loss test | postpublish-boundary mutant |
| Replay survives later overlapping transaction, workspace GC, and project GC of original private generation | postpublish replay-after-reclamation test | durable replay/reclamation mutants |
| Request ID binds exact transaction plan | cross-plan transaction test | cross-plan replay mutant |
| Successful report includes attempts, updated write set, complete members and private-generation metadata | transaction success/replay assertions | schema/behavior coverage |

The transaction suite currently contains eight focused non-equivalent mutants. Together with 14 core, 6 lifecycle/GC, 5 project-request, and 7 workspace-snapshot mutants, deterministic qualification expects **40/40 mutants rejected**.

## Representation-neutrality audit

Two prior verifier defects were found and corrected before freeze:

1. `lifecycle_harness.current_token()` originally equated newest project history generation with ordinary current. Transaction-private generations made that invalid. Current helper filters the contractually documented `workspace_transaction: true` marker before selecting ordinary current by `commit_seq`.
2. `workspace_txn_harness.workspace_snapshot()` originally required `.workspace-cache/CURRENT`. The contract does not require that selector pathname. Current helper resolves the current workspace generation semantically by workspace `commit_seq`.

Current verifier paths that remain directly inspected are explicitly prescribed by the instruction (`.build-cache/generations`, `.build-cache/objects`, `.workspace-cache/generations`, `snapshot.json`, records). Request-journal, lock-file, reader-lease, selector-name, and request-claim representations are not fixed by verifier tests.

## Verifier trust boundary

- `[verifier].environment_mode = "separate"`; tests/reference/reward are verifier-image-owned.
- Candidate implementation runs as `nobody`; source/reference fixtures remain verifier-controlled.
- Candidate process groups and detached candidate-UID descendants are cleaned after invocations.
- Intentional concurrent sibling processes are excluded from cleanup until their tests complete.
- Tests assert public behavior and explicitly documented durable storage, not hidden request/lock representations.
- `tests/test.sh` performs no runtime network installation; verifier dependencies are pinned in `tests/Dockerfile`.
- `/logs/verifier` and reward generation remain verifier-owned.

The mutation matrix is development evidence that each major invariant is load-bearing. Final standard and adversarial agent matrices remain required external evidence.
