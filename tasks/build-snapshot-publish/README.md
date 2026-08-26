# Build Snapshot Publication

## Difficulty explanation

The starter already contains the ordinary incremental-build mechanics: recursive bundles, target dependencies, action keys, cache hits, selective invalidation, and deterministic output generation. The repair is a systems-state problem above that layer. Successful builds must publish coherent snapshots across crashes and concurrent writers, long-lived readers must continue to observe the generation they acquired, and garbage collection must reclaim obsolete generations and cache objects without deleting state that a live reader or writer can still need.

The hard part is the safety/liveness tension rather than fixture volume: retaining everything is incorrect because GC has an explicit bounded-history contract, while aggressive reclamation is incorrect under reader, writer, and stale-scan races. Correct solutions must also preserve the prior stable-input, stale-base merge, and disjoint-progress guarantees.

## Solution explanation

The oracle uses immutable staged generations with a short commit/reclamation lock and process-lifetime leases. Builds evaluate privately, validate their manifest/source read set immediately before publication, merge still-valid cache records from the newest commit, assign a monotonic commit sequence, and atomically switch the visible generation. Readers acquire one generation under the commit lock and keep an OS-backed lease live until they exit. GC scans without monopolizing the project, then revalidates current generation, live pins, writers, generation membership, and objects before deleting anything. A quiescent sweep retains exactly the objects reachable from retained generation records; active writers force conservative object retention until a later GC.

This is one implementation strategy. The externally visible requirements are snapshot stability, bounded reclamation, process-lifetime liveness, exact reports, concurrency progress, and recovery. The on-disk generation/object representation is specified only where the verifier must independently validate reachability and retention.

## Verification explanation

Verifier-owned `reference.py` independently derives clean output bytes and recursive source dependencies. Existing tests retain the full v1 coverage for incremental behavior, selective invalidation, exact narrow snapshots, crash consistency, ordinary publication, disjoint concurrent progress, stale-base cache preservation, aborted-writer isolation, and source/manifest revalidation.

The reclamation suite adds monotonic commit ordering, explicit history budgets, live-reader pinning, killed-reader cleanup, multiple readers of one generation, GC/build and GC/read races at a deterministic post-scan barrier, object protection while a writer is active, exact quiescent object sweeping, and recovery from interruption between generation deletion and object reclamation. Tests inspect both command reports and persistent generation/object state rather than trusting implementation-owned metadata alone. Development mutation matrices deliberately break independent publication and reclamation invariants and require every mutant to be rejected.

Candidate code executes unprivileged inside the separate verifier; verifier truth and reward state remain isolated.

## Relevant experience

The task was developed from hands-on Python/TypeScript service and cloud-infrastructure work, supplemented by targeted research into incremental-build caching, crash consistency, snapshot publication, concurrent state updates, process-lifetime coordination, and safe reclamation. It does not claim prior ownership of a production build system.
