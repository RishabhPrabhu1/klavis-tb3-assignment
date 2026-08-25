# Build Snapshot Publication

## Difficulty explanation

The starter build tool is correct on ordinary builds and cache hits, but it publishes each rebuilt target independently. The hard part is recognizing that individually valid outputs and cache records can still form an invalid build state after interruption: downstream artifacts may describe a different generation than their producers. A correct repair must preserve selective cache reuse while making the visible output tree one committed generation.

## Solution explanation

The reference solution stages every reached target into an immutable generation, validates the staged snapshot, moves it into the generation store, and atomically replaces one `CURRENT` selector. The public `out/` namespace resolves through that selector. Content-addressed objects remain reusable across generations, while incomplete staging is unreachable and can be discarded on the next invocation.

## Verification explanation

The separate verifier owns an independent clean reference workspace and checks output bytes, reports, cache reuse, selective invalidation, corruption recovery, and every named cooperative interruption boundary. A second normal-build test uses only regular source files and observes an intentionally wide dependency graph; if a new producer becomes visible while the old downstream fingerprint is still visible, the verifier interrupts the process and rejects the mixed snapshot. Candidate code runs unprivileged, hidden tests and reference truth remain root-only, candidate-owned mutations run with candidate privileges, and verifier cleanup removes detached candidate processes before grading continues.

## Relevant experience

The task was developed from hands-on software engineering experience with Python/TypeScript services, PostgreSQL/Supabase-backed systems, and cloud infrastructure on GCP and AWS, supplemented by targeted research into build/release systems and crash-consistent publication. It does not claim prior ownership of a production build system.
