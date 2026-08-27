# Active Execution Plan

This is the active operational pipeline for the current task revision.

The Klavis assignment's full written requirement still includes Claude Opus 5/max. The current development/evidence workflow is intentionally **Codex-only** because Claude Code subscription access is not presently available. Do not represent the repository as fully compliant with the Claude requirement unless that requirement is later satisfied or waived.

## Current redesign candidate

```text
tasks/build-snapshot-publish
3ddb933ae848f6912210371c6afc210ceea3f373
```

This tree is **not yet qualified**. It must restart deterministic qualification from Step 1 before any frontier-model measurement.

The previous tree `4eaf21ae9456395fb080be497852c0ff9623b8fa` was deterministically qualified but then cleanly solved by Codex / `openai/gpt-5.6-sol` / `xhigh`: reward 1, 37/37 verifier tests, no infrastructure contamination. That result invalidates the previous tree as a final benchmark candidate and triggered the present redesign.

## Redesign crux

The prior task's single-project MVCC publication, reader pinning, writer liveness, and reclamation model was not intrinsically difficult enough. The current redesign adds a new transaction dimension: optional build request IDs with exactly-once semantics across concurrency and crashes.

For request-ID builds, the task now requires:

- durable binding of the first committed request ID to its target and exact report;
- replay without a new generation, `commit_seq` advance, or current-snapshot change;
- rejection of cross-target request-ID reuse;
- coalescing of concurrent duplicate requests;
- immediate takeover after a pre-commit owner dies, without wall-clock leases;
- independent progress for disjoint request IDs;
- recovery when a process dies after publication but before returning its report;
- replay after later builds and after GC has reclaimed the original generation.

The starter only plumbs the new interface and intentionally does not implement the protocol. The independent reference solution and verifier exercise the new state machine.

## Pipeline

1. **Deterministic qualification**
   - live TB3 static checks;
   - full Oracle/reference regression;
   - core mutation matrix;
   - lifecycle/GC mutation matrix;
   - exactly-once request mutation matrix;
   - verifier determinism and Docker integrity.

2. **Reconfirm live Terminal-Bench source of truth**
   - `/run` defaults;
   - `/cheat` transform;
   - trial counts;
   - model IDs/reasoning settings;
   - Harbor versions.

3. **Harbor zero-model qualification**
   - Oracle = 1;
   - NOP = 0;
   - zero Sol calls.

4. **Codex execution path check**
   - subscription auth available;
   - Docker available;
   - Harbor 0.14.0;
   - evidence path usable under macOS/Colima.

5. **Adversarial `/cheat` qualification**
   - exact redesigned tree;
   - Codex GPT-5.6 Sol/xhigh;
   - valid completed reward 0 required;
   - any provider/auth/runtime exception is invalid evidence.

6. **One genuine Sol difficulty probe**
   - exactly one valid uninterrupted Sol/xhigh standard trial;
   - classify the trajectory, not only the reward.

7. **Decision gate**
   - clean solve -> redesign again and restart Step 1;
   - genuine architectural/conceptual failure -> freeze candidate;
   - narrow bug, ambiguity, verifier defect, or infrastructure failure -> do not freeze;
   - never add trajectory-specific/model-specific traps.

8. **Frozen Codex evidence**
   - three valid Sol/xhigh trials total;
   - target 0/3 passes for genuine task-substantive reasons;
   - no semantic task/verifier changes during the matrix.

9. **Final valid `/cheat` evidence**
   - reward 0 on the exact frozen tree from a normally completed adversarial run.

10. **Documentation and final audit**
   - exact SHAs/configurations/results;
   - failure analyses;
   - evidence paths;
   - fresh-clone reproduction;
   - final deterministic validation.

## Current status

- [ ] Step 1 deterministic qualification of `3ddb933ae848f6912210371c6afc210ceea3f373`.
- [x] Step 2 source-of-truth baseline previously rechecked at TB3 HEAD `b2d4a935cfb1a6f621f611ea69421039cfccd158`; recheck again if upstream advances before frontier trials.
- [ ] Step 3 Harbor Oracle/NOP for the redesigned tree.
- [x] Step 4 local Codex/Docker/Harbor path previously proven functional, subject to current quota availability.
- [ ] Step 5 valid redesigned-tree `/cheat`.
- [ ] Step 6 redesigned-tree Sol/xhigh difficulty probe.
- [ ] Step 7 freeze/redesign decision.
- [ ] Step 8 Sol 0/3 matrix.
- [ ] Step 9 final valid `/cheat`.
- [ ] Step 10 final audit.

## Historical evidence excluded from final matrix

- task tree `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4`: invalidated by an unstated verifier representation requirement;
- task tree `4eaf21ae9456395fb080be497852c0ff9623b8fa`: cleanly solved by Sol/xhigh, reward 1, 37/37;
- provider-safety-blocked `/cheat` attempts: invalid;
- quota-exhausted standard attempt: invalid.

## Next action

Run zero-model deterministic qualification on tree `3ddb933ae848f6912210371c6afc210ceea3f373`. Do not spend another frontier call until the full Oracle and all three mutation matrices are green and Harbor again returns Oracle=1/NOP=0.
