# Build Snapshot Publication

## Difficulty explanation

The failure is deliberately below the level of ordinary incremental-build correctness. The starter produces correct bytes, cache hits, dependency invalidation, and recovery during uninterrupted runs, so a local patch to target hashing or file writes does not solve the task. The distinguishing requirement is crash-consistent publication across a dependency closure while retaining selective reuse. The bundled project is synthetic and intentionally small, but its producer/intermediate/downstream shape models the state-publication problem seen in real build and release infrastructure; verifier fixtures vary the graph and inputs rather than depending on the visible sample.

## Solution explanation

The oracle uses a generation store: it constructs and validates an unreachable complete snapshot, preserves content-addressed objects for reuse, and commits visibility with one atomic selector change. That architecture is included to demonstrate solvability, not as a required implementation. A candidate may use any design that satisfies the observable CLI, report, incremental, recovery, and snapshot guarantees; the verifier does not inspect candidate source structure or require generation directories, symlinks, or a particular cache layout.

## Verification explanation

Expected build bytes and recursive bundle dependencies come from verifier-owned `reference.py`, which performs a clean build independently of candidate cache state. Successful runs are checked for exact output bytes, report schema, event order, dependencies, statuses, paths, and digests. Recovery tests remove or corrupt candidate-owned cache/materialized state and require deterministic convergence without unnecessary downstream rebuilds.

Crash publication is checked in two ways. Cooperative cases exercise each `after-target:TARGET` hook and require the visible tree to remain exactly the old or new complete snapshot. Separately, a Linux `inotify` observer runs an ordinary build with no failpoint variable, freezes the candidate when a rebuilt producer becomes visible, and checks the same complete-snapshot invariant before allowing recovery. This second path prevents an implementation from becoming safe only when it detects the cooperative test hook. Candidate execution is dropped to an unprivileged user; verifier truth and the reward channel remain root-owned in the separate verifier container.

## Relevant experience

The task was developed from hands-on software engineering work with Python/TypeScript services, PostgreSQL/Supabase-backed systems, and GCP/AWS infrastructure, supplemented by targeted research into incremental-build caching and crash-consistent publication. It does not claim prior ownership of a production build system. The design was calibrated with negative implementations covering unconditional rebuilds, stale upstream/definition keys, trusted corrupt objects, in-place publication, missing selector publication, and failpoint-only staging.
