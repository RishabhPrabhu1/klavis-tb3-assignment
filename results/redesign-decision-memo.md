# Task Redesign Decision Memo

Date: 2026-08-24

## Bottleneck

The dominant bottleneck is intrinsic task difficulty. The current `hermetic-build-cache` task is not acceptable as a final benchmark because its reference repair is two local list-operation changes. Verifier polish and model trials cannot compensate for a shallow failure mechanism.

Intentionally out of scope for this decision: README polish, trial-result formatting, screenshots, and GitHub presentation.

## Decision

Retain the build/cache problem family, but replace the task with a new `build-snapshot-publish` design. Do not patch or hide the existing recursive-dependency bug. The old task is a killed prototype and will not remain as a second TB3 task in the submission.

The replacement centers on generation-consistent publication:

> A materialized build is one immutable generation selected by one atomic visibility boundary; cache records, target outputs, and downstream artifacts must never expose a mixture of generations during an interruption or concurrent read.

This is a coherent state-model problem involving the cache, target graph, output namespace, and recovery path. It is not a larger list of dependency edge cases.

## Answers to the continuation-plan questions

1. **Is build-cache v2 salvageable?** Yes, only as a fundamental replacement. The existing implementation is disposable; the new task changes the failure mechanism from dependency bookkeeping to generation publication.
2. **Exact invariant:** every visible output tree resolves to one committed immutable generation. An incomplete generation may remain as unreachable staging state, but it must not become visible. A reader after an interrupted publish must see either the previous complete generation or the new complete generation.
3. **Plausible wrong abstraction:** independently atomically write each target's object, record, and materialized output, then treat the collection of latest files as the build state.
4. **Correct abstraction:** stage a complete target snapshot, retain immutable cache objects, and atomically switch one generation pointer/snapshot selector. Recovery ignores unreachable staging state and validates the selected generation before reuse.
5. **Smallest realistic starter:** a Python build graph with recursive includes, `bundle`/`concat`/`sha256` targets, persisted cache objects, target records, a materialized `out` namespace, and deterministic interruption hooks. Ordinary builds, repeats, direct edits, and cache corruption work in the starter; publication across target boundaries is wrong.
6. **Expected oracle:** a compact generation store with immutable staging directories, an atomic `CURRENT` selector, per-generation target metadata, object-digest validation, and output materialization through the selected generation. The solution should require a cross-module state-model repair, not a text replacement.
7. **Immutable verifier truth:** the verifier will build a root-only reference workspace separately from the writable candidate workspace, apply the same verifier-controlled mutations to each, and compute expected bytes/statuses only from the reference workspace. `/tests` and hidden truth will be unreadable to the unprivileged candidate process.
8. **Exact `/cheat` behavior:** at the recorded upstream commit `45e819259a95fb10e43dcebcc11b73140ace3b32`, the workflow appends `rubrics/hack-trial-prompt.md` after removing the ordinary anti-cheat sentence, runs one attempt per configured task/agent for `/cheat`, uses the configured `env` backend (`modal` by default), and analyzes completed trials by default. The local wrapper will reproduce the prompt transformation and one-attempt configuration; it will not claim to be the GitHub workflow itself.
9. **Kill conditions:** kill this design if the oracle becomes a local patch, if normal correctness requires timing-sensitive sleeps, if the snapshot invariant cannot be checked deterministically, if the instruction needs more than a few concise paragraphs, if a correct solution exceeds roughly 300 meaningful changed lines, or if the security boundary cannot isolate candidate execution from reference truth.
10. **Fallback:** switch to `cas-lease-gc` if any build-snapshot kill condition fires after the first oracle/verifier prototype. Do not preserve the old task because of sunk cost.

## Review gate

The design is approved for implementation only if the starter passes ordinary builds and cache reuse, fails only when publication is interrupted or read across a generation boundary, and the oracle preserves reuse while making the generation boundary authoritative. The first implementation checkpoint is an oracle/nop pair plus a deterministic interrupted-publish test, not a polished test matrix.
