# Candidate Selection Dossier

Status: primary candidate selected for implementation planning; no task code has been written yet.

## Selection criteria

Candidates are evaluated against the live TB3 proposal rubric and the Klavis assignment:

1. The final behavior must be objectively and deterministically verifiable.
2. The instruction must describe the contract without revealing a prescribed implementation.
3. A domain expert who already knows the key idea must be able to implement a working solution in a few hours.
4. Difficulty must come from a meaningful engineering invariant, not arbitrary corner cases, formatting, or a model-specific trap.
5. The scenario must resemble work a professional could plausibly be paid to do.
6. The verifier must grade outcomes and be hardened against `/cheat` attacks.
7. The task must be materially different from the current TB3 catalog, especially the storage, streaming, migration, parity, and performance tasks listed in `results/environment.md`.

## Candidate comparison

Scores are on a 1–5 scale, where 5 is strongest. They are design judgments, not trial results.

| Candidate | Verifiable | Specified | Solvable | Difficult | Realistic | Outcome-based | Novelty | Cheat resistance | Decision |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Hermetic incremental build cache | 5 | 4 | 5 | 5 | 5 | 5 | 5 | 4 | Primary |
| Lease-safe content-addressed storage GC | 5 | 4 | 5 | 5 | 5 | 5 | 4 | 5 | Fallback |
| Fenced lease writer | 5 | 5 | 5 | 4 | 5 | 5 | 4 | 5 | Strong alternative |
| Crash-consistent release publisher | 5 | 4 | 5 | 4 | 5 | 5 | 4 | 4 | Alternative |
| Resumable upload reconciler | 5 | 4 | 5 | 4 | 5 | 5 | 4 | 4 | Alternative |

## Candidate 1 — Hermetic incremental build cache

### Proposal

- **Name:** Hermetic Incremental Build Cache
- **Candidate slug:** `hermetic-build-cache`
- **Professional user:** Build/release infrastructure engineer maintaining a local or remote build cache for a large monorepo.
- **Real-world problem:** A build can reuse an artifact produced from an incomplete dependency view, causing stale or non-reproducible releases after generated inputs or transitive dependencies change. Rebuilding everything is safe but destroys the speed and resource advantages of incremental builds.
- **Starting environment:** A small build orchestrator under `/app/buildsys/` with a stable CLI, a workspace containing source and generated inputs, an action graph, a local content-addressed cache, and a deterministic toolchain. The visible code includes the public API and representative tests but contains a flawed incremental planner and cache publication path.
- **Required end state:** Repeated builds must produce the same artifact tree as a clean build, reuse only valid cached actions, invalidate all affected transitive dependents, recover from invalid cache material, and preserve atomic output publication. The public CLI and output schema remain available. Bundle sources support recursive includes and directory globs whose matching file set can change between builds.
- **Core difficulty crux:** Correct reuse requires an action key to represent the complete semantic dependency closure discovered by the build, including both transitive file contents and the namespace membership of directory globs, not merely the direct paths and metadata visible when the action is first scheduled.
- **Plausible wrong abstraction:** Treat direct input paths, mtimes, or the first observed dependency list as the identity of an action, then invalidate only direct dependents.
- **Correct abstraction:** Model actions and discovered dependencies as an immutable content-addressed graph; cache hits are valid only when the transitive file closure, directory membership signatures, and action definition match, and publication is atomic at the graph boundary.
- **Observable consequence:** A transitive input, or a file added to or removed from a globbed directory, must rebuild exactly the affected closure; unrelated actions must remain cached; a corrupted cache object or materialized output must not survive into the final artifact.
- **Why the wrong abstraction is plausible:** Direct-input invalidation is fast, intuitive, and passes ordinary edit/rebuild examples. It fails only when recursive discovery or directory membership changes the graph without changing the initially visible direct input.
- **Agentic exploration required:** Inspect the action runner, cache key construction, dependency-discovery protocol, state files, and publication code; reproduce a stale hit; trace a clean reference build; make a minimal repair; exercise repeated and concurrent builds.
- **Verifier design:** A separate verifier owns a pristine reference model and hidden deterministic workspaces. It runs the candidate CLI under fixed edit/build schedules, compares final artifacts, rebuild/reuse decisions, dependency manifests, and cache-corruption recovery, and emits per-case CTRF results. It never derives expected output by executing candidate code.
- **Likely cheat surface:** Reading hidden fixtures, replacing the build command, writing a fake manifest, changing the reference input, or leaving a background process that edits outputs after verification. Separate verifier isolation, narrow artifacts, immutable verifier fixtures, unprivileged execution, protected reward output, and process-group cleanup address these paths.
- **Novelty vs existing TB3:** No current task is centered on semantic dependency-closure keys and incremental build-cache correctness. It is not a generic performance task and does not duplicate the existing WAL, MVCC, database-cutover, streaming, or parity tasks.
- **Expected implementation size:** Approximately 100–250 lines changed in the starter implementation, plus a small deterministic reference model and focused test suite. The current prototype exposes the crux through recursive include and glob discovery rather than a large codebase; exact size will be controlled by the starter design, not used as the difficulty source.
- **Expected verifier size:** Approximately 150–300 lines of readable Python tests/reference helpers, with test fixtures baked into the verifier image.
- **Risk factors:** The contract can become underspecified if path identity, dynamic dependency discovery, or publication semantics are not stated. The first design review must choose one narrow invariant and document every observable behavior tested.

### Proposal gates

- **Verifiable:** Strong. The output tree, cache decisions, dependency closure, and atomic visibility can be compared exactly against a clean reference under fixed schedules.
- **Well specified:** Promising but needs discipline. The final instruction must define what constitutes an input, a discovered dependency, a valid cache hit, and a visible build result without naming the implementation.
- **Solvable:** Strong. A known solution is an explicit dependency graph plus content-addressed action keys and atomic generation publication; the implementation can remain small.
- **Difficult:** Strong. The crux is temporal and graph-wide, not a list of edge cases; a direct-input cache looks correct until the agent explores a second build or concurrent reader.
- **Interesting:** Strong. Build correctness and cache invalidation are directly relevant to CI, monorepos, package managers, and release engineering.
- **Outcome-verified:** Strong. The verifier can compare behavior and artifacts without requiring a particular language, class, or data structure.

## Candidate 2 — Lease-safe content-addressed storage GC

### Proposal

- **Name:** Lease-Safe Content-Addressed Storage GC
- **Candidate slug:** `cas-lease-gc`
- **Professional user:** Storage-platform engineer operating a blob or container-image cache with immutable blobs, manifests, snapshots, readers, and background garbage collection.
- **Real-world problem:** A collector removes blobs that are not rooted by the latest manifest even though an in-flight reader still holds an older snapshot. The resulting read failure is intermittent and difficult to reproduce.
- **Starting environment:** A Python service under `/app/cas/` with blob insertion, manifest publication, snapshot reads, lease management, restart/recovery, and a deterministic fake clock. A deliberately plausible mark/sweep implementation has a temporal safety bug.
- **Required end state:** Every committed snapshot remains readable for the lifetime of its lease; GC eventually reclaims unreachable blobs after leases end; interrupted collection or restart never produces partial manifests or deletes live data; operations remain deterministic under the provided schedule API.
- **Core difficulty crux:** Reachability is not only a property of the latest namespace roots; it is a property of roots plus active snapshot leases across a GC epoch.
- **Plausible wrong abstraction:** Compute reachability from current manifests and delete everything else, or use a mutable reference count without a reader-generation barrier.
- **Correct abstraction:** Separate immutable committed manifests from lease epochs, mark from all leased roots, and sweep only after a safe epoch transition.
- **Agentic exploration required:** Inspect service state and persistence format, reproduce a paused reader/GC interleaving, reason about restart, then repair the state transition and test repeated collection.
- **Verifier design:** A fixed-clock schedule generator drives the public service API and compares candidate behavior to an independent model. Hidden schedules include delayed readers, duplicate leases, interrupted GC, and restart. The verifier image owns all truth and runs candidate code unprivileged.
- **Likely cheat surface:** Returning fabricated blob bytes, altering the schedule or snapshot inputs, modifying verifier-visible state, or racing reward output. Separate verifier isolation and root-owned verdict handling close these paths.
- **Novelty vs existing TB3:** It shares durability vocabulary with `wal-recovery-ordering` and `mvcc-lsm-compaction` but tests lease-aware reachability in a content-addressed storage system, not WAL replay or MVCC visibility.
- **Expected implementation size:** Approximately 120–220 changed lines; verifier approximately 150–250 lines.
- **Risk factors:** Need to keep the API contract short and avoid turning the task into an exhaustive distributed-systems specification. If the temporal behavior cannot be stated in two or three paragraphs, kill or simplify it.

## Candidate 3 — Fenced lease writer

### Proposal

- **Name:** Fenced Lease Writer
- **Candidate slug:** `fenced-lease-writer`
- **Professional user:** Distributed-systems engineer maintaining a leader-elected worker that writes to a durable sink during pauses, failover, or rolling deploys.
- **Real-world problem:** A worker's lease expires while it is paused, a replacement worker acquires leadership, and the old worker later writes stale state. A boolean lock or TTL check cannot prevent this delayed write.
- **Starting environment:** A local worker and fake lease/sink services under `/app/worker/`. The scheduler can deterministically pause, reorder, duplicate, and resume worker operations. The starter code checks lease ownership before writes but does not enforce stale-writer rejection at the sink boundary.
- **Required end state:** Only the current lease generation may commit a write; stale workers receive a deterministic rejection and cannot overwrite newer state; retries are idempotent; the public worker CLI remains compatible.
- **Core difficulty crux:** Lease possession is not sufficient authority after a pause; every write must carry a monotonically increasing fencing generation that the sink enforces.
- **Plausible wrong abstraction:** Check `lease.is_valid()` before each write and treat the result as permanent authority.
- **Correct abstraction:** Acquire a generation token and make the durable sink reject writes from older generations, even if the old worker resumes after a new owner commits.
- **Agentic exploration required:** Read the worker/sink interaction, reproduce a pause-and-resume interleaving, inspect persisted state, and repair the protocol across both caller and sink.
- **Verifier design:** The reference model applies fixed event schedules and checks final sink state, accepted/rejected operations, monotonic generations, and idempotent retries. Tests are outcome-based and independent.
- **Likely cheat surface:** Bypassing the sink, editing the event schedule, or faking success in the worker's local log. The verifier reads the sink's independent state and owns the schedule.
- **Novelty vs existing TB3:** No current catalog task is centered on fencing-token enforcement. It is distinct from database cutover and payment notification tasks.
- **Expected implementation size:** Approximately 80–180 changed lines; verifier approximately 120–200 lines.
- **Risk factors:** Fencing tokens are a well-known concept. The task may be too easy if the public code or instruction names the answer; it must describe only the observable stale-writer behavior and keep the abstraction recoverable through exploration.

## Candidate 4 — Crash-consistent release publisher

### Proposal

- **Name:** Crash-Consistent Release Publisher
- **Candidate slug:** `atomic-release-publisher`
- **Professional user:** Release-engineering or platform engineer publishing versioned application bundles consumed by concurrent workers.
- **Real-world problem:** A deployment process updates files in place and crashes between writes, leaving readers with a mixed version or a pointer to an incomplete bundle.
- **Starting environment:** A small publisher under `/app/publisher/` with version directories, a current-release pointer, concurrent readers, retention cleanup, and deterministic crash points around filesystem operations.
- **Required end state:** Readers always observe a complete committed release; an interrupted publish leaves the previous release usable; cleanup never removes the current or an in-use release; restart recovers committed state without inventing a release.
- **Core difficulty crux:** A release is an immutable generation with one atomic visibility boundary, not a set of files updated independently.
- **Plausible wrong abstraction:** Write files into the live directory and update a marker when the copy appears complete.
- **Correct abstraction:** Stage an immutable generation, validate it, atomically publish one pointer, and retain generations according to an explicit reader/retention rule.
- **Agentic exploration required:** Inspect filesystem state transitions, inject a crash, compare reader views, and repair publication and cleanup.
- **Verifier design:** The verifier controls crash points and concurrent reads, then compares observable directory snapshots and restart behavior to a reference model.
- **Likely cheat surface:** Writing the expected marker without a valid bundle, modifying verifier fixtures, or relying on host-specific filesystem behavior. The verifier uses its own fixtures and checks the complete artifact tree.
- **Novelty vs existing TB3:** Related to persistence but distinct from WAL replay, MVCC compaction, and Bun source-map release hygiene; the core is atomic generation visibility.
- **Expected implementation size:** Approximately 100–200 changed lines; verifier approximately 120–220 lines.
- **Risk factors:** Filesystem crash semantics vary by host. The task must use a deterministic simulated filesystem or narrowly defined local operations rather than claim durability beyond what the environment can verify.

## Candidate 5 — Resumable upload reconciler

### Proposal

- **Name:** Resumable Upload Reconciler
- **Candidate slug:** `resumable-upload-reconciler`
- **Professional user:** Storage or media-platform engineer maintaining a chunked upload service across unreliable clients and retries.
- **Real-world problem:** Retries, duplicate chunks, interrupted finalization, and client restarts can produce corrupted objects or report completion before all bytes are durable.
- **Starting environment:** A local upload service under `/app/uploader/` with a chunk API, session state, a durable object store, and a deterministic transport that fragments, duplicates, reorders, and drops messages.
- **Required end state:** A finalized object is byte-exact, each accepted chunk is idempotent, conflicting retries are rejected, finalization is durable before acknowledgment, and a restart either resumes a valid session or reports it incomplete.
- **Core difficulty crux:** A byte offset is not a durable session identity; reconciliation must bind chunks to an immutable upload generation and content digest.
- **Plausible wrong abstraction:** Treat a matching offset as proof that a retry is the same chunk and mark the session complete after observing all offsets once.
- **Correct abstraction:** Use explicit session generation, chunk identity/content validation, durable commit state, and idempotent finalization.
- **Agentic exploration required:** Explore service state and protocol traces, reproduce a duplicate/reordered retry, then fix reconciliation and restart handling.
- **Verifier design:** Fixed transport traces compare object bytes, response classes, and durable session state to an independent model.
- **Likely cheat surface:** Hard-coding visible objects, accepting malformed chunks, modifying transport traces, or writing a fake completion marker. Separate verifier state and hidden traces address these paths.
- **Novelty vs existing TB3:** Distinct from generic stream parsing and payment notification reliability, but it remains adjacent to existing streaming and persistence tasks.
- **Expected implementation size:** Approximately 100–220 changed lines; verifier approximately 150–250 lines.
- **Risk factors:** Strong overlap with protocol and durability tasks could make this a weaker choice if the primary design is already accepted. Keep as an alternative only.

## Primary selection

### Selected candidate: `hermetic-build-cache`

This candidate has the best combination of professional relevance, novel overlap profile, agentic exploration, and a verifier that can compare exact outcomes. Its difficulty comes from a graph-wide semantic invariant rather than from an arbitrary race or a long list of special cases. It also directly uses the plan's preferred incremental-build/cache family while remaining distinct from the current TB3 task catalog.

The implementation will not begin until the candidate contract is reduced to one explicit crux and the verifier/oracle design is written down. The first design constraint is to keep the task about transitive semantic dependency closure; symlinks, hard links, renames, and concurrency will be included only if they expose that same invariant and can be specified succinctly.

### Fallback selection: `cas-lease-gc`

Use this fallback if the build-cache contract requires too many filesystem semantics, cannot be stated in two or three paragraphs, or the oracle becomes larger than the intended task solution. It preserves the plan's systems-invariant objective with a smaller state machine and a more direct deterministic schedule model.

## Explicit kill conditions

Kill or redesign the selected candidate if any of these becomes true:

1. The task is mainly a collection of filesystem corner cases rather than one dependency-closure invariant.
2. The prompt has to reveal the implementation concept (`content-addressed`, `fencing`, `mark/sweep`, or similar) for an agent to solve it.
3. The oracle is large because of mechanical implementation volume rather than a compact key insight.
4. Two independent verifier authors could reasonably disagree about valid behavior.
5. A reference solution can pass by hard-coding visible fixtures or bypassing the public CLI.
6. The separate verifier must execute candidate code as root, expose hidden truth, or depend on live external state.
7. Standard-agent failures are primarily formatting mistakes, timeouts, infrastructure errors, or local coding slips rather than the intended abstraction failure.
8. The candidate materially duplicates an existing TB3 task after implementation details are known.
9. The only way to preserve the required zero-success standard trials is to add model-specific traps, hidden semantics, or arbitrary edge cases.
10. A clean expert solution cannot be implemented and tested in a few focused hours after the crux is known.
