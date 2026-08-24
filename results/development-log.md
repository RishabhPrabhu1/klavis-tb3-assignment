# Development Log

## 2026-08-24

- **Hypothesis:** The live TB3 repository, not stale plan assumptions, must define the task format and trial defaults.
  - **Change:** Pinned upstream commit `45e819259a95fb10e43dcebcc11b73140ace3b32` and recorded rubric/default/prompt blob hashes in `results/environment.md`.
  - **Evidence:** Current defaults are three trials, Modal execution, Claude Opus 5 at `max`, and GPT-5.6 Sol at `xhigh`; separate verifier mode and current static checks are required.
  - **Decision:** Use the live snapshot as the implementation baseline.

- **Hypothesis:** A content-addressed incremental build-cache task is materially more novel than the current storage, migration, streaming, parity, and performance tasks.
  - **Change:** Audited the 70-task upstream catalog and documented five candidates in `candidate-selection-dossier.md`.
  - **Evidence:** No existing task centers on semantic dependency closure or build-cache invalidation.
  - **Decision:** Select `hermetic-build-cache`, with `cas-lease-gc` as fallback.

- **Hypothesis:** A single nested-include bookkeeping defect would be too shallow for the assignment's frontier-failure target.
  - **Change:** Added directory-glob discovery to the same dependency-closure contract. A valid cache must track recursive file content and glob directory membership while preserving valid reuse.
  - **Evidence:** The unchanged starter passes ordinary cache/recovery cases but fails nested-file invalidation, changed glob-member invalidation, and complete dependency reporting. The two-line reference repair passes all nine focused tests, including removal from a globbed directory.
  - **Decision:** Keep the task centered on one invariant—complete semantic discovery closure—without adding unrelated races or arbitrary corner cases.

- **Hypothesis:** Separate-verifier execution must treat candidate code as hostile even for a small Python task.
  - **Change:** Tests execute `/app/buildsys` only in a child process, drop it to `nobody` when the verifier is root, protect `/logs/verifier`, capture output to files, and kill the process group on timeout.
  - **Evidence:** Hidden truth remains in `tests/` and is not copied into the agent image; the reward is written only by root after pytest exits.
  - **Decision:** Preserve this isolation pattern for mutation and adversarial testing.

- **Hypothesis:** The original two-line dependency-closure task cannot meet the intrinsic-difficulty gate.
  - **Change:** Rejected `hermetic-build-cache` as a final task and selected `build-snapshot-publish`, where the state model must separate immutable staged generations from one atomic visibility selector.
  - **Evidence:** The original oracle was a local `append` to `extend` repair. The v2 starter passes normal builds and cache reuse but fails deterministic interrupted-publication cases; the v2 oracle passes those cases without changing the public CLI.
  - **Decision:** Continue only with the generation-publication invariant. Switch to `cas-lease-gc` if the oracle or verifier collapses into a local patch or timing-dependent test.

- **Hypothesis:** Candidate-controlled verifier inputs and readable verifier files would make local security claims unreliable.
  - **Change:** The v2 verifier builds separate candidate/reference workspaces, keeps reference truth root-only, makes `/tests` root-only in the verifier image, runs candidate code as `nobody`, and cleans process groups after normal exit as well as timeout.
  - **Evidence:** The local verifier derives all expected bytes from the independent reference workspace and the mutation suite rejects publication, definition, upstream, object-integrity, and selector mutants.
  - **Decision:** Keep security and contract coverage as release blockers, not documentation claims.

- **Hypothesis:** The compact oracle must stay within the redesign plan's implementation-size kill gate.
  - **Change:** Removed redundant reference-path and validation scaffolding while preserving staged generations, content-addressed object validation, atomic `CURRENT` replacement, and output-selector recovery.
  - **Evidence:** The oracle is 270 nonblank lines and the independent six-case local suite still passes; all seven mutation variants remain rejected.
  - **Decision:** Keep `build-snapshot-publish`; do not switch to `cas-lease-gc` on solution size.

- **Hypothesis:** Official implementation evidence is currently infrastructure-blocked rather than task-validated.
  - **Change:** Ran the actual Harbor implementation-rubric command against the new task with the recorded upstream rubric.
  - **Evidence:** Harbor failed before container execution because the development machine has no `docker` executable.
  - **Decision:** Do not claim Harbor, Docker, or frontier-model completion; preserve the exact blocker in `results/validation.md`.
