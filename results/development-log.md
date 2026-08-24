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
  - **Evidence:** The unchanged starter passes ordinary repeat and unrelated-input cases but fails nested-file invalidation, changed glob-member invalidation, and complete dependency reporting. The two-line reference repair passes all eight focused tests.
  - **Decision:** Keep the task centered on one invariant—complete semantic discovery closure—without adding unrelated races or arbitrary corner cases.

- **Hypothesis:** Separate-verifier execution must treat candidate code as hostile even for a small Python task.
  - **Change:** Tests execute `/app/buildsys` only in a child process, drop it to `nobody` when the verifier is root, protect `/logs/verifier`, capture output to files, and kill the process group on timeout.
  - **Evidence:** Hidden truth remains in `tests/` and is not copied into the agent image; the reward is written only by root after pytest exits.
  - **Decision:** Preserve this isolation pattern for mutation and adversarial testing.
