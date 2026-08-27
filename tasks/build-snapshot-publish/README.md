# Build Snapshot Publication

## Difficulty explanation

The starter already contains the ordinary incremental-build mechanics: recursive bundles, target dependencies, action keys, cache hits, selective invalidation, and deterministic output generation. The repair is a systems-state problem above that layer. Successful builds must publish coherent snapshots across crashes and concurrent writers, long-lived readers must continue to observe the generation they acquired, garbage collection must reclaim obsolete generations and cache objects safely, and request-ID builds must provide exactly-once semantics across duplicate invocations and response-loss crashes.

The request protocol deliberately changes the transaction model rather than adding another isolated edge case. A committed request must replay its exact original report without a new publication even after later source/manifest changes. Concurrent duplicates must converge on one commit, a dead pre-commit owner must be immediately replaceable without wall-clock leases, and disjoint request IDs must still make progress. If a request process dies after publication but before report delivery, a retry must recover that committed result; recovery must survive later publications and GC of the original generation. The verifier also composes this with a publisher that started before the lost-response request committed but publishes afterward, forcing publication-time reconciliation rather than a command-start-only journal check.

The hard part is the combined safety/liveness tension: retaining everything violates bounded GC, aggressive reclamation can destroy reader/writer/request state, global serialization violates progress, and overly local request bookkeeping can lose a committed result during a later publication race.

## Solution explanation

The oracle uses immutable staged generations with short publication/reclamation locks, process-lifetime leases, and per-request kernel locks. Builds evaluate privately, validate their manifest/source read set immediately before publication, merge still-valid cache records from the newest commit, assign a monotonic commit sequence, and atomically switch the visible generation. Readers acquire one generation under the commit lock and keep an OS-backed lease live until they exit. GC scans without monopolizing the project, then revalidates current generation, live pins, writers, generation membership, and objects before deleting anything.

For request-ID builds, a per-request lock serializes only callers sharing that ID. The first committed generation carries enough request result information to recover from a process death immediately after publication. Durable replay state is journaled independently of generation retention. Crucially, every later publisher reconciles the outgoing current generation before replacing it; this closes the race where a build that started earlier would otherwise move a lost-response request into history before its durable request record existed. Replays return the stored report without publishing or changing the current snapshot.

This is one implementation strategy. The externally visible requirements are snapshot stability, exactly-once request behavior, bounded reclamation, process-lifetime liveness, exact reports, concurrency progress, and recovery. The verifier does not require a particular request-journal directory, filename, selector, or lock layout.

## Verification explanation

Verifier-owned `reference.py` independently derives clean output bytes and recursive source dependencies. Existing tests retain the incremental, selective-invalidation, exact-snapshot, crash-consistency, ordinary-publication, disjoint-progress, stale-base-cache, aborted-writer, stable-input, reader-lifecycle, and reclamation coverage.

The request suite adds:

- replay of an already committed request without recommit;
- cross-target request-ID reuse rejection;
- invalid request-ID rejection;
- pre-commit claim crash followed by retry;
- duplicate concurrent request coalescing;
- takeover by an already-waiting duplicate after owner death;
- independent progress for a different request ID;
- committed response loss at `request:after-publish`;
- replay after later publication and GC of the original generation;
- an already-in-flight ordinary publisher that must preserve a stranded request before replacing the current generation.

Development mutation matrices deliberately break publication, reclamation, and request invariants. The request matrix includes replay-recommit, cross-target replay, global request serialization, incorrect post-publish failpoint placement, and invocation-start-only request recovery. Every mutant must be rejected before frontier testing.

Candidate code executes unprivileged inside the separate verifier; verifier truth and reward state remain isolated. Concurrent-process cleanup is careful not to kill intentional sibling actors while still reaping leaked candidate descendants.

## Relevant experience

The task was developed from hands-on Python/TypeScript service and cloud-infrastructure work, supplemented by targeted research into incremental-build caching, crash consistency, idempotency, snapshot publication, concurrent state updates, process-lifetime coordination, and safe reclamation. It does not claim prior ownership of a production build system.
