# Validation

Status: implementation and verifier hardening are in progress. Earlier local tests and static checks passed on the recorded development machine, but the verifier and live upstream snapshot have changed since those runs. The current suite must be re-executed before any final validation claim. Docker/Harbor and frontier trials remain pending because Docker was unavailable and Modal credentials were not configured on the recorded development machine.

## Environment

- Current live TB3 snapshot recorded in `results/environment.md`: `2d58e0374d2de102181f080c5a9d77af29f3717c`
- Earlier static/local execution snapshot: `45e819259a95fb10e43dcebcc11b73140ace3b32`
- Harbor: `0.22.0` at the recorded local run
- Docker: unavailable at the time of the recorded run
- Modal credentials: unavailable at the time of the recorded run
- Python: `3.14.6`
- pytest: `9.1.1` in the recorded isolated temporary environment
- pytest-json-ctrf: `0.5.2` in the same temporary environment

## Commands and evidence

### Static checks

The wrapper stages a no-space temporary copy because the upstream scripts do not safely handle a workspace path containing spaces.

```bash
TB3_REPO=/path/to/current/terminal-bench ./scripts/run-static-checks.sh
```

Historical result: all 22 static checks passed for `build-snapshot-publish` against the earlier upstream snapshot.

Current status: **rerun required** against the live snapshot recorded in `results/environment.md`. Do not treat the historical result as final CI evidence.

### Local reference regression

```bash
TEST_PYTHON=/path/to/isolated/python ./scripts/run-local-reference-tests.sh
```

Historical result before the latest hardening: 6 focused generation-publication tests passed.

The current verifier additionally includes:

- progress validation for all four `after-target:TARGET` failpoint boundaries;
- a verifier-controlled external SIGKILL test that does not expose `BUILDSYS_FAILPOINT` to candidate code;
- a Linux/root verifier self-test proving detached `setsid()` candidate processes are cleaned up;
- UID-based cleanup of candidate processes on every verifier invocation.

Current status: **rerun required**. The oracle must pass the complete current `tests/` directory before the next gate.

### Starter / nop behavior

Historical result: the untouched v2 starter failed interrupted-publication cases while passing ordinary cache/output behavior.

The current external-kill guard is specifically designed to reject failpoint-only safety and ordinary per-target in-place publication. Official Harbor nop remains pending.

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
failpoint-shortcut
```

Historical result: the earlier seven-mutant matrix was rejected before the latest failpoint/external-crash hardening.

Current status: **rerun required**. Every current invalid variant must be rejected by the complete verifier suite.

The compact generation-based oracle remains below the continuation plan's approximate implementation-size kill threshold; line count is not itself evidence of correctness or difficulty.

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
HARBOR_ENV=docker ./scripts/run-oracle.sh
HARBOR_ENV=docker ./scripts/run-nop.sh
```

Official result: pending Docker/Harbor environment provisioning.

### Standard and adversarial trials

The current live defaults are recorded in `results/environment.md`: three trials each for Claude Code / Opus 5 max and Codex / GPT-5.6 Sol xhigh under the configured backend, with the same trial count used for `/cheat`.

Standard and adversarial trials have not been run on the current frozen task. No model-failure or reward result is being claimed.
