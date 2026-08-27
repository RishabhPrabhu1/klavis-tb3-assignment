# Active Execution Plan

This is the active operational pipeline for the current task revision.

The Klavis assignment's full written requirement still includes Claude Opus 5/max. The current development/evidence workflow is intentionally **Codex-only** because Claude Code subscription access is not presently available. Do not represent the resulting repository as fully compliant with the Claude requirement unless that requirement is later satisfied or waived.

## Frozen qualified task

```text
tasks/build-snapshot-publish
d84a5bf3df6a2c3ed7a523c7fee072936f4029e4
```

No frontier result counts unless its recorded task-tree object equals that value.

## Pipeline

1. **Deterministic qualification**
   - live static checks;
   - Oracle regression;
   - repeated verifier determinism;
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
   - validate under the relevant Harbor validation and agent-trial versions.

4. **Verify Codex execution path before a real task trial**
   - Codex subscription auth exists;
   - Docker is available;
   - Harbor 0.14.0 is installed;
   - `openai/gpt-5.6-sol` / `xhigh` command path is correct;
   - evidence directories/logging work.

5. **Adversarial `/cheat` qualification**
   - run the live `/cheat` transform on the exact candidate task;
   - use Codex GPT-5.6 Sol/xhigh;
   - require reward 0 from a normally completed verifier run;
   - if an exploit succeeds, fix the verifier/task and restart at Step 1.

6. **One genuine Sol difficulty probe**
   - exactly one Codex / GPT-5.6 Sol / xhigh standard trial;
   - classify the trajectory rather than looking only at reward.

7. **Decision gate**
   - genuine Sol failure + clean `/cheat` -> freeze the exact revision;
   - Sol success -> task-level redesign, then restart at Step 1;
   - do not collect additional standard trials on a task already shown solvable;
   - do not add model-specific traps.

8. **Frozen Codex evidence collection**
   - count the probe if and only if it used the same frozen task/configuration and is otherwise valid;
   - complete three valid Sol/xhigh trials total;
   - target: Sol 0/3 genuine failures;
   - no task/verifier semantic changes during this phase.

9. **Final `/cheat` evidence**
   - earlier cheat evidence may be reused only if it used the exact frozen revision and exact required configuration;
   - otherwise rerun;
   - this phase should be evidence collection, not vulnerability discovery.

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

- [x] Step 1 deterministic qualification recorded green.
- [x] Step 2 live TB3 source of truth rechecked at upstream HEAD `b2d4a935cfb1a6f621f611ea69421039cfccd158` on 2026-08-26.
- [x] Step 3 Harbor qualification recorded Oracle=1/NOP=0 under Harbor 0.18.0 and 0.14.0.
- [ ] Step 4 local Codex execution/auth path check on the machine holding `~/.codex/auth.json`.
- [ ] Step 5 Codex `/cheat` qualification.
- [ ] Step 6 one genuine Sol/xhigh difficulty probe.
- [ ] Step 7 decision/freeze gate.
- [ ] Step 8 complete Sol 0/3 evidence.
- [ ] Step 9 final cheat evidence.
- [ ] Step 10 final audit.

## Commands for the next gates

Zero-Sol path check:

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Codex adversarial qualification:

```bash
AGENTS=codex ./scripts/run-cheat-trials.sh
```

Only after that valid reward-0 adversarial run, run one standard difficulty probe:

```bash
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
./scripts/run-codex-strong-test.sh
```

If that probe is a genuine intended-crux failure, freeze the revision and later complete the Codex matrix with:

```bash
AGENTS=codex N_ATTEMPTS=3 ./scripts/run-standard-trials.sh
```
