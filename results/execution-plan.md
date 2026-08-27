# Active Execution Plan

This is the active operational pipeline for the current task revision.

The Klavis assignment's full written requirement still includes Claude Opus 5/max. The current development/evidence workflow is intentionally **Codex-only** because Claude Code subscription access is not presently available. Do not represent the repository as fully compliant with the Claude requirement unless that requirement is later satisfied or waived.

## Current redesign candidate

```text
tasks/build-snapshot-publish
f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8
```

This tree is **not yet qualified**. It must pass deterministic qualification before any frontier-model measurement.

The first request-protocol tree `3ddb933ae848f6912210371c6afc210ceea3f373` was superseded before frontier testing after static review found missing composition coverage. The strengthened tree adds request-ID validation, already-waiting duplicate takeover after owner death, and a publication race in which an ordinary build starts before a lost-response request commits and later replaces that request generation.

The earlier tree `4eaf21ae9456395fb080be497852c0ff9623b8fa` was deterministically qualified but then cleanly solved by Codex / `openai/gpt-5.6-sol` / `xhigh`: reward 1, 37/37 verifier tests, no infrastructure contamination. That solve triggered the request-protocol redesign.

## Redesign crux

The prior task's MVCC publication, reader pinning, writer liveness, and reclamation model was not intrinsically difficult enough. The current redesign adds a second transaction dimension: optional build request IDs with exactly-once semantics across concurrency and crashes.

For request-ID builds, the task requires:

- durable binding of the first committed request ID to its target and exact report;
- replay without another generation, `commit_seq` advance, or visible-snapshot change;
- rejection of cross-target request-ID reuse and invalid IDs;
- coalescing of concurrent duplicate requests;
- waiting duplicates to take over after a pre-commit owner dies without wall-clock leases;
- independent progress for disjoint request IDs;
- recovery when a process dies after publication but before returning its report;
- replay after later builds and after GC reclaims the original generation;
- publication-time reconciliation so a build that started before a lost-response request committed cannot erase the only recoverable copy when it publishes later.

The starter only plumbs the new interface and intentionally does not implement the protocol. The reference solution and verifier exercise the protocol independently.

## Pipeline

1. **Deterministic qualification**
   - live TB3 static checks;
   - full Oracle/reference regression;
   - core mutation matrix;
   - lifecycle/GC mutation matrix;
   - exactly-once request mutation matrix, including publication-race recovery;
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
   - home-backed evidence paths under macOS/Colima.

5. **Adversarial `/cheat` qualification**
   - exact candidate tree;
   - Codex GPT-5.6 Sol/xhigh;
   - valid completed reward 0 required;
   - provider/auth/runtime exceptions are invalid evidence.

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

- [ ] Step 1 deterministic qualification of `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8`.
- [x] Step 2 source-of-truth baseline previously rechecked at TB3 HEAD `b2d4a935cfb1a6f621f611ea69421039cfccd158`; recheck if upstream advances before frontier trials.
- [ ] Step 3 Harbor Oracle/NOP for the strengthened request tree.
- [x] Step 4 local Codex/Docker/Harbor path previously proven functional, subject to current quota availability.
- [ ] Step 5 valid current-tree `/cheat`.
- [ ] Step 6 current-tree Sol/xhigh difficulty probe.
- [ ] Step 7 freeze/redesign decision.
- [ ] Step 8 Sol 0/3 matrix.
- [ ] Step 9 final valid `/cheat`.
- [ ] Step 10 final audit.

## Historical evidence excluded from final matrix

- `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4`: invalidated by an unstated verifier representation requirement;
- `4eaf21ae9456395fb080be497852c0ff9623b8fa`: cleanly solved by Sol/xhigh, reward 1, 37/37;
- `3ddb933ae848f6912210371c6afc210ceea3f373`: superseded before frontier testing after verifier coverage audit;
- provider-safety-blocked `/cheat` attempts: invalid;
- quota-exhausted standard attempt: invalid.

## Next action

Run zero-model deterministic qualification on `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8`. Do not spend another frontier call until the full Oracle, all mutation matrices, and Harbor Oracle/NOP are green.
