# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` contains an incremental build tool with working ordinary caching behavior but broken publication semantics. The repair must keep incremental correctness while treating outputs, reusable cache state, and reports as transactional build state.

The benchmark covers crash-safe snapshot publication, exact requested-target snapshots, concurrent writers without lost reusable cache state, and stable manifest/source views across evaluation and publication. Deterministic failpoint and pausepoint hooks make the crash and concurrency cases reproducible.

The task uses a separate verifier image. Candidate code receives only the declared `/app/buildsys/` artifact; hidden tests and independent reference logic remain verifier-owned.

## Repository structure

```text
tasks/build-snapshot-publish/   Terminal-Bench task, starter, oracle, verifier
scripts/                        validation and trial command wrappers
results/                        validation, coverage, trials, failure analysis
```

## Pre-frontier qualification

The GitHub preflight validates against a fresh checkout of live Terminal-Bench and runs:

- live static checks;
- Oracle regression plus repeated verifier-determinism runs;
- a mutation matrix covering independent failure modes;
- Docker environment build;
- Oracle = 1 and NOP = 0 under Harbor 0.18.0, matching live `/validate`;
- Oracle = 1 and NOP = 0 under Harbor 0.14.0, matching live `/run` and `/cheat` agent trials.

Equivalent local checks are:

```bash
TB3_REPO=/path/to/terminal-bench ./scripts/run-static-checks.sh
./scripts/run-local-reference-tests.sh
./scripts/run-mutation-checks.sh
```

Verifier dependencies are pinned in `tasks/build-snapshot-publish/tests/Dockerfile`; `test.sh` performs no network installs.

## Standard model trials

Current live TB3 defaults are three trials each for:

- `codex` + `openai/gpt-5.6-sol`, `reasoning_effort=xhigh`;
- `claude-code` + `anthropic/claude-opus-5`, `reasoning_effort=max`.

Live agent trials use Harbor 0.14.0. The local wrappers use subscription authentication rather than API-key billing.

Before spending the full six-run matrix, run a single Codex diagnostic on the frozen benchmark revision:

```bash
uv tool install --force 'harbor==0.14.0'
AGENTS=codex N_ATTEMPTS=1 ./scripts/run-standard-trials.sh
```

After a defensible diagnostic, the final standard matrix is:

```bash
./scripts/run-standard-trials.sh
```

Claude subscription-auth runs additionally require `CLAUDE_CODE_OAUTH_TOKEN`, produced by `claude setup-token`.

## Adversarial trials

The live `/cheat` workflow performs one adversarial run per configured agent. The local helper copies the task, removes the ordinary anti-cheat sentence, appends the current upstream `docs/prompts/hack-trial-prompt.md`, and leaves the original task unchanged.

```bash
git clone --depth 1 https://github.com/harbor-framework/terminal-bench.git /tmp/terminal-bench
TB3_REPO=/tmp/terminal-bench ./scripts/run-cheat-trials.sh
```

All required adversarial trials must reward 0.

## Evidence

- `results/contract-coverage.md` — instruction-to-verifier coverage and anti-cheat boundaries.
- `results/validation.md` — static, local, Harbor, Oracle/NOP, determinism, and mutation status.
- `results/standard-trials.md` — required standard model trials.
- `results/cheat-trials.md` — required adversarial trials.
- `results/failure-analysis.md` — classification of genuine model failures versus specification, verifier, or infrastructure failures.

Infrastructure-invalid runs are never counted as model failures.
