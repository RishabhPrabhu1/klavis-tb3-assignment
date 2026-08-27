# Build Snapshot Publication — reviewer notes

The normative agent contract is `instruction.md`. High-level difficulty,
solution, and verification summaries are in `task.toml`. This README records
only development context useful to reviewers and future maintainers.

## Difficulty explanation

The task was intentionally calibrated around composition of familiar systems
mechanisms rather than hidden representation requirements. Deterministic
pause/fail hooks expose concurrency and crash boundaries without relying on
wall-clock races. Internal selector, journal, lock-file, lease, and staging
layouts are deliberately non-normative; reviewers should treat any test that
accidentally depends on one such representation as a verifier defect.

## Solution explanation

The reference implementation is one witness, not a prescribed architecture.
Its concrete filesystem names and helper decomposition are not part of the
contract. The maintenance rule is to preserve observable atomicity,
retry/replay, progress, pinning, and bounded-reclamation semantics while
allowing alternative correct implementations.

## Verification explanation

The verifier runs separately from the agent image and checks behavior through
process execution and committed artifacts. Development mutation suites are
negative controls for coverage and are not part of reward computation. Current
selection is resolved from documented generation metadata rather than a
candidate-specific selector pathname; transaction-private project history is
identified by the documented `workspace_transaction` metadata bit.

## Relevant experience

This task grew from software/cloud infrastructure work plus targeted study of
incremental builds, crash consistency, idempotency, optimistic concurrency,
snapshot publication, and safe reclamation. The design was iterated by fixing
specification/verifier defects when found rather than counting them as model
failures. No production build-system ownership is claimed.
