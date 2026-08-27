# Build Snapshot Publication — reviewer notes

## Difficulty explanation

Difficulty should come from composing concurrency, crash recovery, replay, and reclamation invariants. A failure caused only by an undocumented selector, journal, lock, lease, or staging pathname is a verifier defect rather than intended difficulty.

## Solution explanation

`solution/` is one working witness, not a prescribed architecture. Only the public behavior and the small generation/object schemas stated in `instruction.md` are normative.

## Verification explanation

The verifier is separate and behavior-first. Direct filesystem inspection is limited to documented committed-generation metadata needed to identify history and object reachability; request journals, locks, leases, selectors, and staging layouts remain implementation-private.

## Relevant experience

The task was developed from software/cloud engineering experience plus targeted study of crash consistency, idempotency, optimistic concurrency, snapshot publication, and reclamation. No production build-system ownership is claimed.
