# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` contains an incremental build tool with working ordinary caching behavior but broken publication semantics. The repair must keep incremental correctness while treating outputs, reusable cache state, and reports as transactional build state.

The benchmark covers crash-safe snapshot publication, exact requested-target snapshots, concurrent writers without lost reusable cache state, stable manifest/source views across evaluation and publication, long-lived snapshot readers, and garbage collection under concurrent readers/writers. Deterministic failpoint and pausepoint hooks make crash and concurrency cases reproducible.

The task uses a separate verifier image. Candidate code receives only the declared `/app/buildsys/` artifact; hidden tests and independent reference logic remain verifier-owned.

Frozen qualified task tree:

```text
d84a5bf3df6a2c3ed7a523c7fee072936f4029e4
```

## Repository structure

```text
tasks/build-snapshot-publish/   Terminal-Bench task, starter, oracle, verifier
scripts/                        validation and evidence-preserving trial runners
results/                        validation, coverage, trials, failure analysis
```

`results/execution-plan.md` is the active execution order.

## Pre-frontier qualification

The qualification workflow validates against a fresh checkout of live Terminal-Bench and runs:

- live static checks;
- Oracle regression plus repeated verifier-determinism runs;
- core and lifecycle mutation matrices;
- Docker environment build;
- Oracle = 1 and NOP = 0 under Harbor 0.18.0;
- Oracle = 1 and NOP = 0 under Harbor 0.14.0.

Equivalent local checks are:

```bash
TB3_REPO=/path/to/terminal-bench ./scripts/run-static-checks.sh
./scripts/run-local-reference-tests.sh
./scripts/run-mutation-checks.sh
./scripts/run-lifecycle-mutation-checks.sh
```

Verifier dependencies are pinned in `tasks/build-snapshot-publish/tests/Dockerfile`; `test.sh` performs no network installs.

## Live Terminal-Bench configuration

The live source of truth currently specifies three standard trials each for:

- `codex` + `openai/gpt-5.6-sol`, `reasoning_effort=xhigh`;
- `claude-code` + `anthropic/claude-opus-5`, `reasoning_effort=max`.

Live `/run` and `/cheat` use Harbor 0.14.0. The current local workflow is **Codex-only** because Claude Code subscription access is not available. This is sufficient to qualify and collect Codex evidence, but it does not by itself satisfy the assignment's written Claude requirement unless that requirement is later completed or waived.

## Active Codex-only execution order

### 1. Verify the frozen local path without a Sol call

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Required result: Oracle = 1, NOP = 0, `sol_calls=0`.

### 2. Qualify `/cheat` before the standard difficulty probe

```bash
AGENTS=codex ./scripts/run-cheat-trials.sh
```

The wrapper obtains a fresh Terminal-Bench checkout, records its exact HEAD, reproduces the live adversarial prompt transform on a disposable task copy, and preserves evidence outside the repository. A valid normally completed adversarial attempt must receive reward 0.

If `/cheat` succeeds against the verifier, fix the task/verifier and restart deterministic qualification before spending standard evidence.

### 3. Run one genuine Sol/xhigh difficulty probe

Only after the adversarial gate is clean:

```bash
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
./scripts/run-codex-strong-test.sh
```

The probe wrapper refuses to launch unless it can find valid reward-0 Codex `/cheat` evidence for this exact task tree.

If Sol cleanly solves the task, perform a task-level redesign and restart qualification. Do not add trajectory-specific tests or continue collecting trials on a candidate already demonstrated solvable.

If Sol receives a valid reward 0 for the intended systems reason, freeze the exact revision.

### 4. Complete the frozen Codex evidence matrix

After explicitly making the freeze decision:

```bash
CONFIRM_FROZEN=1 AGENTS=codex N_ATTEMPTS=3 ./scripts/run-standard-trials.sh
```

The final-matrix wrapper refuses to launch without `CONFIRM_FROZEN=1`. The qualifying probe may count toward the three only if it used the exact frozen task/configuration and otherwise satisfies the assignment conditions. Target: three valid genuine Sol/xhigh failures total.

### 5. Final Codex `/cheat` evidence

The earlier cheat qualification may serve as final evidence only if it used the exact revision that was subsequently frozen and no task/verifier semantics changed. Otherwise rerun:

```bash
AGENTS=codex ./scripts/run-cheat-trials.sh
```

### 6. Documentation and final audit

Record exact repository/task/upstream SHAs, commands, model/reasoning settings, Harbor version, evidence paths, trial classifications, and reproduction results. Run one final deterministic/fresh-clone audit before submission.

## Evidence

Trial evidence is written under `~/.cache/klavis-tb3-runs/` by default. Each candidate run records repository SHA, task-tree hash, agent/model/reasoning configuration, Harbor version, raw Harbor output, verifier artifacts, and a deterministic summary.

Repository records:

- `results/execution-plan.md` — active Codex-only pipeline and gate state.
- `results/contract-coverage.md` — instruction-to-verifier coverage and anti-cheat boundaries.
- `results/validation.md` — static, local, Harbor, Oracle/NOP, determinism, and mutation status.
- `results/standard-trials.md` — standard frontier evidence and outstanding Claude requirement.
- `results/cheat-trials.md` — adversarial evidence and outstanding Claude requirement.
- `results/failure-analysis.md` — classification of genuine model failures versus specification, verifier, or infrastructure failures.

Infrastructure-invalid runs are never counted as model failures.
