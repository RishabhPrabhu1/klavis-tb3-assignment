# Build Snapshot Publication

## Difficulty explanation

The starter already implements the ordinary incremental-build mechanics: recursive bundles, target dependencies, action keys, cache hits, selective invalidation, and deterministic output generation. The repair is a systems-state problem above that layer. Outputs, reusable cache state, reports, and the source view that produced them must remain coherent across interrupted builds and concurrent writers. A correct design must also allow disjoint builds to make progress concurrently, avoid stale-base lost updates, and reject an evaluated attempt whose manifest or source view is outdated before publication.

The visible project is intentionally small so the work is reasoning-heavy rather than tedious. Verifier fixtures vary requested closures, graph shapes, failpoint boundaries, commit ordering, and source/manifest changes.

## Solution explanation

The oracle uses immutable staged generations and a short publication lock. Each attempt evaluates against one committed generation, records the manifest/source digests it observed, and validates that view before commit. Publication briefly serializes, merges still-valid unrelated cache records from the latest committed generation, and atomically switches the visible generation. Stale or interrupted staging stays unreachable; a narrow successful build contains only its reached output closure while reusable records for unrelated work can survive.

That is one valid implementation, not a required architecture. The verifier does not require generations, symlinks, `flock`, a particular cache-object layout, or specific private filenames.

## Verification explanation

Verifier-owned `reference.py` independently derives clean output bytes and recursive source dependencies. Successful runs are checked for exact report schema, event order, dependency lists, target statuses, paths, digests, and materialized bytes.

The suite covers ordinary incremental behavior, selective invalidation, new includes, materialized-output recovery, exact narrow snapshots, cooperative crash recovery across two graph shapes, and ordinary publication observed with Linux filesystem events. Deterministic pausepoints exercise disjoint concurrent progress, stale-base cache preservation, and aborted-writer isolation. Separate stable-input tests mutate a source during a cache-hit attempt, mutate only the manifest, and mutate both manifest and a newly expanded transitive include during a rebuilt attempt.

Candidate code executes unprivileged inside the separate verifier; hidden tests/reference truth and reward state remain verifier-owned. Development mutation tests deliberately break independent invariants and require every mutant to be rejected.

## Relevant experience

The task was developed from hands-on Python/TypeScript service and cloud-infrastructure work, supplemented by targeted research into incremental-build caching, crash consistency, snapshot publication, and concurrent state updates. It does not claim prior ownership of a production build system.
