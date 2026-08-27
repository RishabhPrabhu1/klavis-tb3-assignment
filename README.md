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

## Pre-frontier qualification

The GitHub preflight validates against a fresh checkout of live Terminal-Bench and runs:

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

## Standard model trials

Current live TB3 defaults are three trials each for:

- `codex` + `openai/gpt-5.6-sol`, `reasoning_effort=xhigh`;
- `claude-code` + `anthropic/claude-opus-5`, `reasoning_effort=max`.

Live agent trials use Harbor 0.14.0. The local runners use Docker plus the subscription-auth mechanisms documented by the Klavis assignment and preserve raw Harbor/verifier evidence outside the repository.

Before spending the full six-run matrix, validate the frozen path without a Sol call:

```bash
uv tool install --force 'harbor==0.14.0'
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
PREFLIGHT_ONLY=1 \
./scripts/run-codex-strong-test.sh
```

Then run exactly one Codex/Sol diagnostic:

```bash
EXPECTED_TASK_TREE=d84a5bf3df6a2c3ed7a523c7fee072936f4029e4 \
./scripts/run-codex-strong-test.sh
```

After a defensible genuine reward-0 diagnostic, run the final standard matrix:

```bash
./scripts/run-standard-trials.sh
```

The wrapper refuses any task tree other than the frozen qualified tree. Claude subscription-auth runs additionally require `CLAUDE_CODE_OAUTH_TOKEN`, produced by `claude setup-token`.

## Adversarial trials

The live `/cheat` workflow performs one adversarial run per configured agent. The local runner obtains a fresh Terminal-Bench checkout itself, records its exact HEAD, removes the ordinary anti-cheat sentence from a disposable task copy, appends the current upstream `docs/prompts/hack-trial-prompt.md`, and leaves the real task unchanged.

```bash
./scripts/run-cheat-trials.sh
```

The wrapper is also frozen to the qualified task tree. All required adversarial trials must reward 0.

## Evidence

Trial evidence is written under `~/.cache/klavis-tb3-runs/` by default. Each candidate run records repository SHA, task-tree hash, agent/model/reasoning configuration, Harbor version, raw Harbor output, verifier artifacts, and a deterministic summary.

Repository records:

- `results/contract-coverage.md` — instruction-to-verifier coverage and anti-cheat boundaries.
- `results/validation.md` — static, local, Harbor, Oracle/NOP, determinism, and mutation status.
- `results/standard-trials.md` — required standard model trials.
- `results/cheat-trials.md` — required adversarial trials.
- `results/failure-analysis.md` — classification of genuine model failures versus specification, verifier, or infrastructure failures.

Infrastructure-invalid runs are never counted as model failures.
