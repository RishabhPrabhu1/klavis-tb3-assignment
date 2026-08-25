# Validation

Status: implementation and verifier hardening are substantially complete, but the current suite still needs execution on the recorded live TB3 snapshot before any final pass claim. Docker/Harbor and frontier trials remain pending because Docker was unavailable and Modal credentials were not configured on the recorded development machine.

## Environment

- Current live TB3 snapshot recorded in `results/environment.md`: `82981590d6a1015a9db3bd7952e8465215933683`
- Earlier static/local execution snapshot: `45e819259a95fb10e43dcebcc11b73140ace3b32`
- Harbor: `0.22.0` at the recorded local run
- Docker: unavailable at the time of the recorded run
- Modal credentials: unavailable at the time of the recorded run
- Python: `3.14.6`
- pytest: `9.1.1` in the recorded isolated temporary environment
- pytest-json-ctrf: `0.5.2` in the same temporary environment

## Commands and evidence

### Static checks

```bash
TB3_REPO=/path/to/current/terminal-bench ./scripts/run-static-checks.sh
```

Historical result: all 22 static checks passed for `build-snapshot-publish` against an earlier upstream snapshot.

Current status: **rerun required** against the live snapshot recorded in `results/environment.md`. The task has since gained the currently required task-level README and the instruction/verifier changed, so the historical result is not final CI evidence.

### Local reference regression

```bash
TEST_PYTHON=/path/to/isolated/python ./scripts/run-local-reference-tests.sh
```

Historical result before the latest hardening: 6 focused generation-publication tests passed.

The current verifier additionally includes:

- complete-snapshot checks for all four named cooperative failpoints;
- a normal-build publication observer using only regular source files and a wide dependency graph, with no `BUILDSYS_FAILPOINT` exposed to candidate code;
- a Linux/root self-test proving detached `setsid()` candidate processes are cleaned up;
- Linux/root self-tests proving candidate code cannot rename the sibling reference workspace or verifier-controlled source/manifest entries;
- candidate-owned cache/output corruption performed only after dropping to the candidate UID, avoiding a verifier-root confused-deputy path;
- UID-based cleanup of candidate processes on every verifier invocation.

The normal-build observer was also stress-checked independently against toy in-place and atomic publishers: the in-place publisher exposed the producer-new/downstream-old state on 10/10 runs, while the atomic publisher avoided it on 10/10 runs. This is a verifier-mechanism check only, not an oracle or Harbor result.

Current status: **full current-suite rerun required**. The oracle must pass the complete current `tests/` directory before the next gate.

### Starter / nop behavior

Historical result: the untouched v2 starter failed interrupted-publication cases while passing ordinary cache/output behavior.

The current regular-file observer is designed to reject ordinary per-target in-place publication even when a candidate behaves differently only during cooperative failpoint runs. Official Harbor nop remains pending.

### Mutation checks

```bash
TEST_PYTHON=/path/to/isolated/python ./scripts/run-mutation-checks.sh
```

The current mutation matrix contains eight invalid variants:

```text
starter
always-rebuild
ignore-upstream
ignore-definition
trust-object
publish-in-place
no-selector
failpoint-only-staging
```

`failpoint-only-staging` is an adversarial verifier probe: it hides in-place publication only when `BUILDSYS_FAILPOINT` is present while remaining unsafe during an ordinary build.

Historical result: an earlier seven-mutant matrix was rejected before the latest publication-observer hardening.

Current status: **rerun required**. Every current invalid variant must be rejected by the complete verifier suite.

### Harbor implementation rubric

Current command:

```bash
harbor check tasks/build-snapshot-publish \
  -r /path/to/current/terminal-bench/rubrics/task-implementation.toml
```

Recorded result on 2026-08-24: blocked before the check trial because Harbor could not find a `docker` executable. This is an infrastructure blocker, not a rubric pass or failure.

### Oracle and nop

Planned commands:

```bash
HARBOR_ENV=modal ./scripts/run-oracle.sh
HARBOR_ENV=modal ./scripts/run-nop.sh
```

Official result: pending Harbor/Modal execution.

### Standard and adversarial trials

The current live trial matrix is recorded in `results/environment.md`. Ordinary `/run` uses three trials each for Claude Code / Opus 5 max and Codex / GPT-5.6 Sol xhigh. The current `/cheat` workflow runs one adversarial attempt for each configured agent.

Standard and adversarial trials have not been run on the current frozen task. No model-failure or reward result is being claimed.
