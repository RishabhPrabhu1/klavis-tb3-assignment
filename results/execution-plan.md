# Active Execution Plan

This is the active operational pipeline for the current task revision.

The Klavis assignment's full written requirement still includes Claude Opus 5/max. The current development/evidence workflow is intentionally **Codex-only** because Claude Code subscription access is not presently available. Do not represent the resulting repository as fully compliant with the Claude requirement unless that requirement is later satisfied or waived.

## Current deterministically qualified task

```text
tasks/build-snapshot-publish
4eaf21ae9456395fb080be497852c0ff9623b8fa
```

The prior task tree `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` was invalidated after a valid Sol diagnostic exposed an unstated verifier requirement for `.build-cache/CURRENT`. The verifier was corrected to determine the current committed generation from the greatest unique `commit_seq` instead of requiring a particular pointer layout. No frontier result from the old task tree counts toward final qualification.

## Pipeline

1. **Deterministic qualification**
   - live static checks;
   - full Oracle regression;
   - core + lifecycle mutation matrices;
   - Docker/verifier integrity.

2. **Reconfirm live Terminal-Bench source of truth**
   - `/run` defaults;
   - `/cheat` behavior;
   - trial counts;
   - model IDs and reasoning settings;
   - Harbor versions and execution behavior.

3. **Harbor qualification**
   - Oracle = 1;
   - NOP = 0;
   - zero Sol calls.

4. **Verify Codex execution path**
   - Codex subscription auth exists;
   - Docker is available;
   - Harbor 0.14.0 is installed;
   - `openai/gpt-5.6-sol` / `xhigh` command path is correct;
   - evidence directories/logging work.

5. **Adversarial `/cheat` qualification**
   - run the live `/cheat` transform on the exact candidate task;
   - use Codex GPT-5.6 Sol/xhigh;
   - require reward 0 from a normally completed verifier run;
   - any provider/auth/runtime/agent exception makes the attempt invalid;
   - if an exploit succeeds, fix the verifier/task and restart at Step 1.

6. **One genuine Sol difficulty probe**
   - exactly one Codex / GPT-5.6 Sol / xhigh standard trial;
   - classify the trajectory rather than looking only at reward;
   - normally this follows a clean `/cheat` pass;
   - because the official adversarial prompt has twice triggered the provider cybersecurity classifier before substantive task work, one ordinary diagnostic is permitted only when the blocked `/cheat` attempt is preserved and audited as invalid. This exception never converts `/cheat` into a pass.

7. **Decision gate**
   - genuine Sol architectural failure -> freeze candidate revision for standard evidence, while `/cheat` remains separately outstanding;
   - Sol success -> task-level redesign, then restart at Step 1;
   - non-architectural failure -> fix/redesign before collecting more trials;
   - invalid provider/auth/runtime attempt -> rerun only after access is restored; never count it;
   - do not add model-specific traps.

8. **Frozen Codex evidence collection**
   - only valid, uninterrupted Sol/xhigh trials count;
   - complete three valid Sol/xhigh trials total;
   - target: Sol 0/3 genuine failures;
   - no task/verifier semantic changes during this phase.

9. **Final valid `/cheat` evidence**
   - a provider-safety-blocked attempt is not evidence;
   - obtain at least one normally completed adversarial trial on the exact frozen task/configuration with reward 0;
   - if the verifier is defeated, repair and restart qualification.

10. **Documentation + final audit**
    - standard-trial table;
    - adversarial-trial table;
    - failure analysis;
    - exact repository/task/upstream SHAs;
    - exact commands/model/reasoning/Harbor config;
    - evidence paths;
    - repository cleanup;
    - final deterministic validation;
    - fresh-clone/reproduction check;
    - verify every written claim against preserved artifacts.

## Current status

- [x] Step 1 deterministic qualification: 37/37 Oracle tests pass; 14/14 core and 6/6 lifecycle mutants rejected.
- [x] Step 2 live TB3 source of truth rechecked at upstream HEAD `b2d4a935cfb1a6f621f611ea69421039cfccd158`.
- [x] Step 3 Harbor zero-Sol qualification: Oracle=1, NOP=0, `sol_calls=0`.
- [x] Step 4 local Codex execution/auth path verified.
- [ ] Step 5 valid Codex `/cheat` qualification. Two attempts have been invalid: both were terminated by the provider cybersecurity safety classifier before substantive task work.
- [ ] Step 6 valid Sol/xhigh difficulty probe. The first corrected-tree attempt was invalid because the Codex subscription usage limit terminated the turn before any patch was successfully applied.
- [ ] Step 7 decision/freeze gate.
- [ ] Step 8 complete Sol 0/3 evidence.
- [ ] Step 9 final valid cheat evidence.
- [ ] Step 10 final audit.

## Current execution blockers

### Codex `/cheat`

The current official adversarial prompt path reproducibly triggers `NonZeroAgentExitCodeError` from the provider cybersecurity classifier before substantive task work. Reward 0 from these attempts is invalid and must not be counted.

### Standard Sol diagnostic

The first corrected-tree standard diagnostic authenticated and began analysis, but the subscription usage limit terminated the Codex turn before any implementation was applied. Harbor therefore graded the unchanged starter. This attempt is invalid and does not measure task difficulty.

## Next valid action

Do not modify the deterministically qualified task because of either execution failure. After Codex subscription capacity is available again, rerun exactly one ordinary Sol/xhigh diagnostic on task tree `4eaf21ae9456395fb080be497852c0ff9623b8fa`. If it completes normally, classify the result as solve, genuine architectural failure, or non-architectural failure before launching any additional standard trial.

The valid `/cheat` requirement remains outstanding and must be resolved separately before final assignment compliance can be claimed.
