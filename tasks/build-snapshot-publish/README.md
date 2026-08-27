# Build Snapshot Publication

## Difficulty explanation

The starter already contains the ordinary incremental-build mechanics: recursive bundles, target dependencies, action keys, cache hits, selective invalidation, and deterministic output generation. The repair is a systems-state problem above that layer. Successful project builds must publish coherent snapshots across crashes and concurrent writers, long-lived readers must retain the generation they acquired, garbage collection must reclaim obsolete generations and objects safely, and request-ID builds must provide exactly-once semantics across duplicate invocations and response-loss crashes.

The request protocol changes the transaction model rather than adding an isolated edge case. A committed request must replay its exact original report without another publication even after later source or manifest changes. Concurrent duplicates must converge on one commit, a dead pre-commit owner must be immediately replaceable without wall-clock leases, and disjoint request IDs must still make progress. If a request process dies after publication but before report delivery, a retry must recover that committed result; recovery must survive later publications and GC of the original generation. Publication-time reconciliation is required so an invocation that started before a lost-response request cannot later overwrite the only recoverable copy of that request result.

The workspace layer adds a separate cross-resource consistency problem. `workspace-capture` publishes an immutable workspace generation containing one generation from every project in its plan. Those member generations must form a real simultaneous cut: during the deterministic stable-cut pause, ordinary publications to every listed project must wait rather than allowing a sequential reader to manufacture a combination of member generations that never coexisted. Workspace capture requests themselves are exactly-once and crash recoverable. Long-lived `workspace-read` operations pin the workspace generation they acquired, and retained workspace snapshots transitively protect their referenced project generations from project GC. `workspace-gc` has its own current/pinned/KEEP retention semantics, and project GC must revalidate those cross-project references before reclaiming history.

The central difficulty is therefore composition of several independent state machines: project publication, request deduplication, workspace publication, process-lifetime liveness, project readers, workspace readers, and two reclamation layers. Retaining everything violates bounded GC; global serialization violates progress; sequential workspace capture violates linearizability; and local-only project GC can destroy history that a retained workspace snapshot still names.

## Solution explanation

The oracle uses immutable project generations with short publication locks, stable-input revalidation, stale-base cache-state merge, monotonic commit sequences, process-lifetime reader/writer leases, and content-addressed objects. Project request IDs use per-request kernel locks and durable replay records. Committed generations carry sufficient request metadata to recover the response-loss window, and later publishers reconcile outgoing request-bearing state before replacing it.

The workspace layer uses a second immutable generation namespace under the workspace root. A capture obtains only its own request claim, then under the workspace publication lock acquires every listed project's publication lock in deterministic canonical-path order. While that lock set is held it records the current generation of every member, producing a linearizable cross-project cut, writes a staged workspace snapshot, assigns the next workspace commit sequence, and publishes it atomically. Unlisted projects remain independent, and disjoint request IDs do not share request claims.

Workspace request results are durable independently of workspace-generation retention. A committed response-loss capture is recoverable even if a later workspace publication replaces it and workspace GC subsequently deletes its original generation. Workspace readers hold OS-backed leases on the captured workspace generation and read directly from its referenced project generation. Workspace GC retains current, all live-reader-pinned snapshots, and newest KEEP additional history. Project GC takes the workspace lock before its project lock and treats project generations referenced by any retained workspace generation as protected; after the referencing workspace generation is retired, the next project GC may reclaim that history.

This is one implementation strategy. The contract intentionally leaves selector names, request-journal paths, lock filenames, and lease representation unspecified. The externally visible requirements are stable publication, exact reports, exactly-once replay, real cross-project cuts, liveness without wall-clock leases, snapshot pinning, and bounded safe reclamation.

## Verification explanation

Verifier-owned reference logic independently derives project output bytes and source dependencies. The existing suites retain incremental correctness, selective invalidation, exact project snapshots, crash consistency, concurrent publication, stale-base reuse, stable-input validation, request replay/recovery, project reader lifecycle, and project GC/reclamation coverage.

The workspace suite adds behavioral checks for:

- exact workspace replay without another workspace publication;
- request-ID binding to the exact canonical workspace plan;
- post-publication response loss and durable replay;
- recovery of a stranded workspace request by a later workspace publisher before the original workspace generation is reclaimed;
- a stable cross-project cut while concurrent project publishers are forced to wait;
- disjoint workspace request progress;
- takeover by an already-waiting duplicate after owner death;
- long-lived workspace readers pinning both a historical workspace snapshot and its referenced project generations;
- workspace KEEP retention in addition to live reader pins;
- project GC preserving generations referenced by retained workspace snapshots and reclaiming them after those snapshots retire.

Development mutation matrices independently break the project publication, project reclamation, project request, and workspace invariants. Workspace mutations cover replay-recapture, cross-plan replay, global request serialization, missing stable-cut project locks, incorrect post-publish failpoint placement, missing publication-time reconciliation, ignored workspace-reader pins, and project GC ignoring workspace references. Every mutant must be rejected before frontier testing.

Candidate code executes unprivileged inside the separate verifier image. The verifier checks public CLI behavior and documented generation metadata rather than requiring the oracle's selector, journal, lock, or lease layout.

## Relevant experience

The task was developed from hands-on Python/TypeScript service and cloud-infrastructure work, supplemented by targeted research into incremental-build caching, crash consistency, idempotency, snapshot publication, cross-resource consistent cuts, process-lifetime coordination, and safe reclamation. It does not claim prior ownership of a production build system.
