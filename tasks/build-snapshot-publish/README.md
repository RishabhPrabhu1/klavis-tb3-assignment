# Build Snapshot Publication

## Difficulty explanation

The starter already contains the ordinary incremental-build mechanics: recursive bundles, target dependencies, action keys, cache hits, selective invalidation, and deterministic output generation. The repair is a systems-state problem above that layer. Successful project builds must publish coherent snapshots across crashes and concurrent writers, long-lived readers must retain the generation they acquired, garbage collection must reclaim obsolete generations and objects safely, and request-ID builds must provide exactly-once semantics across duplicate invocations and response-loss crashes.

The project request protocol changes the transaction model rather than adding an isolated edge case. A committed request must replay its exact original report without another publication even after later source or manifest changes. Concurrent duplicates must converge on one commit, a dead pre-commit owner must be immediately replaceable without wall-clock leases, and disjoint request IDs must still make progress. If a request process dies after publication but before report delivery, a retry must recover that committed result; recovery must survive later publications and GC of the original generation. Project publication-time reconciliation is required so an ordinary build that started before a lost-response request cannot later overwrite the only recoverable copy of that request result.

The workspace snapshot layer adds cross-resource consistency. `workspace-capture` publishes an immutable workspace generation containing one generation from every project in its plan. Those member generations must form a real simultaneous cut: during the deterministic stable-cut pause, ordinary publications to every listed project must wait rather than allowing a sequential reader to manufacture a combination of member generations that never coexisted. Workspace capture requests are exactly-once and crash recoverable. Long-lived `workspace-read` operations pin the workspace generation they acquired, retained workspace snapshots transitively protect referenced project generations from project GC, and `workspace-gc` has current/pinned/KEEP retention semantics.

### Optimistic workspace build transactions

The final layer is `workspace-build`. Its plan is JSON of the form:

```json
{
  "members": {
    "left": {"project": "left", "target": "app"},
    "right": {"project": "right", "target": "digest"}
  }
}
```

Each member name is a workspace member, each project is a direct child of the workspace root, and one project may appear at most once in one transaction. `workspace-build` requires an existing workspace snapshot and updates only the named members while carrying forward the newest committed state of every disjoint member.

The expensive member builds **must not run while holding the workspace commit lock or project publication locks**. They are private optimistic work. The transaction records the workspace member versions and project-current versions on which it started, builds each requested target privately, and records the manifest/input values actually used. At the commit edge it acquires the workspace lock and all written-project publication locks in deterministic canonical order, then validates:

- each written workspace member is still the same generation observed at the start of the attempt;
- each written project's ordinary current generation is still the same version observed at the start of the attempt;
- the manifest and every source input used by the private build are unchanged.

If any validation fails, the entire workspace-build attempt retries from a fresh base. A stale prepared result may never be committed merely because its bytes happen to look plausible.

If validation succeeds, each updated member is installed as a new immutable **private project generation** with a strictly increasing project `commit_seq`. These generations do not move the individual project's ordinary `CURRENT`/`out` view. They become visible as a unit only through one new workspace generation and one atomic workspace selector replacement. The final workspace snapshot starts from the latest workspace state at commit time and overwrites only the transaction's written members. Therefore two disjoint transactions that staged from the same old workspace state must merge rather than lose one another's updates. Two overlapping transactions cannot both commit from the same stale member version: the later committer must retry.

A successful `workspace-build` report is:

```text
request_id   exact request id
snapshot     committed workspace generation token
attempts     number of optimistic attempts used by this successful request
updated      metadata for members written by this transaction
members      complete member map of the committed workspace snapshot
```

Each `updated` member contains its `project`, private project `generation`, project `commit_seq`, requested `target`, and build `outputs`. The `members` map is the complete committed workspace view and at minimum carries `project`, `generation`, and `commit_seq` for each member. A transaction-generated project generation is ordinary immutable project history for reader/GC purposes, but it is not the project's ordinary current generation.

`workspace-build` uses the same exactly-once workspace request namespace. A request ID is permanently bound to the exact canonical transaction plan. Concurrent duplicates converge on one committed transaction. A dead pre-commit owner is immediately replaceable without wall-clock leases. `workspace-build:after-import` is a pre-commit failpoint: imported private project generations may remain as unreachable history, but the request is not consumed and the workspace selector is unchanged. `workspace-build:after-publish` is a post-commit response-loss failpoint: the workspace generation is already committed, and retry must return the exact original report without rebuilding or publishing again. That replay must remain possible after later workspace transactions, workspace GC of the original workspace generation, and project GC of the original private project generations.

Deterministic pausepoints include `workspace-build:after-stage:<member>` and `workspace-build:before-commit`. A transaction paused after staging a member must not prevent a disjoint workspace-build transaction from completing. This forbids solving the transaction layer by wrapping the entire operation in one global workspace lock. It also makes stale-base merge behavior observable: when a disjoint transaction commits while another is paused, the paused transaction may still commit in its first attempt, but its final workspace snapshot must preserve the disjoint update.

The central difficulty is therefore composition of several state machines: project publication, project request deduplication, workspace snapshot publication, workspace request deduplication, optimistic multi-project writes, version validation, process-lifetime liveness, project readers, workspace readers, and two reclamation layers. Retaining everything violates bounded GC; global serialization violates progress; sequential workspace capture violates linearizability; stale workspace transactions lose updates; and local-only project GC can destroy history that a retained workspace snapshot still names.

## Solution explanation

The oracle uses immutable project generations with short publication locks, stable-input revalidation, stale-base cache-state merge, monotonic commit sequences, process-lifetime reader/writer leases, and content-addressed objects. Project request IDs use per-request kernel locks and durable replay records. Committed project generations carry sufficient request metadata to recover the response-loss window, and later project publishers reconcile outgoing request-bearing state before replacing it.

The workspace capture layer uses a second immutable generation namespace under the workspace root. A capture obtains only its request claim, then under the workspace publication lock acquires every listed project's publication lock in deterministic canonical-path order. While that lock set is held it records every member current generation, producing a linearizable cross-project cut, then publishes one workspace generation atomically. Because the workspace lock is held continuously from entry reconciliation through selector replacement, one entry reconciliation is sufficient to rescue any previously stranded workspace request before replacement.

The `workspace-build` oracle separates evaluation from commit. It copies the project input tree into private staging, performs each target build there, and retains the exact manifest/input read set used by that build. No workspace/project commit lock is held during this expensive phase. At commit, it takes the workspace lock and the written project locks in canonical order, validates the workspace write-set versions, ordinary project versions, and source read sets, and retries the entire transaction if any are stale. On success it imports the private generations into each project with fresh project commit sequences, merges those written members into the newest workspace member map, and atomically publishes one workspace generation. An import crash leaves only unreachable project history; a response-loss crash is recoverable from request metadata embedded in the committed workspace snapshot.

Workspace request results are durable independently of workspace-generation retention. Workspace readers hold OS-backed leases on workspace generations and read directly from their referenced project generations. Workspace GC retains current, all live-reader-pinned snapshots, and newest KEEP additional history. Project GC takes the workspace lock before its project lock and treats project generations referenced by retained workspace generations as protected; after the workspace reference is retired, project GC may reclaim transaction-private generations normally.

This is one implementation strategy. The contract intentionally leaves selector names, request-journal paths, lock filenames, lease representation, staging layout, and private-build mechanism unspecified. The externally visible requirements are stable publication, exact reports, exactly-once replay, real cross-project cuts, optimistic transactional retry/merge semantics, liveness without wall-clock leases, snapshot pinning, and bounded safe reclamation.

## Verification explanation

Verifier-owned reference logic independently derives project output bytes and source dependencies. Existing suites retain incremental correctness, selective invalidation, exact project snapshots, crash consistency, concurrent publication, stale-base reuse, stable-input validation, project request replay/recovery, project reader lifecycle, project GC/reclamation, workspace capture/replay, stable-cut locking, workspace reader pins, and workspace GC coverage.

The transaction suite additionally checks:

- multi-member `workspace-build` publishes private project generations while leaving ordinary project currents unchanged;
- a transaction paused after private staging does not block a disjoint transaction;
- disjoint transactions merge the newest workspace state instead of losing one another's updates;
- an overlapping transaction retries when another transaction commits its written member first;
- source changes during private staging force a fresh attempt and fresh bytes;
- ordinary project publication of a written project invalidates the staged transaction version;
- `workspace-build:after-import` is pre-commit: the workspace does not move, the request is reusable, and orphan private generations are reclaimable;
- `workspace-build:after-publish` is post-commit: exact replay survives a later overlapping transaction, workspace GC of the original snapshot, and project GC of the original private generation;
- request IDs are bound to the exact transaction plan.

Development mutation matrices independently break project publication, project reclamation, project request, workspace snapshot, and workspace transaction invariants. Every non-equivalent mutant must be rejected before frontier testing. Candidate subprocesses remain unprivileged and verifier truth stays in the separate verifier image.

## Relevant experience

The task was developed from hands-on Python/TypeScript service and cloud-infrastructure work, supplemented by targeted research into incremental-build caching, crash consistency, idempotency, optimistic concurrency control, snapshot publication, cross-resource transactions, process-lifetime coordination, and safe reclamation. It does not claim prior ownership of a production build system.
