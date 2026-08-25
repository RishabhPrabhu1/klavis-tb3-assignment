# Validation

Status: task design, oracle behavior, and verifier hardening are substantially complete. The remaining gates are live static execution, the Harbor implementation check, official Oracle/NOP runs, the mutation rerun, and the frontier/adversarial model matrix.

## Environment

- Current live TB3 snapshot recorded in `results/environment.md`: `c48c033cf1829b2fd62374ace87461b004b97ccd`
- Earlier static execution snapshot: `45e819259a95fb10e43dcebcc11b73140ace3b32`
- Harbor: `0.22.0` at the recorded local run
- Docker: unavailable at the recorded development-machine snapshot
- Modal credentials: not stored in this repository
- Python: `3.14.6`
- pytest: `9.1.1` in the recorded isolated environment
- pytest-json-ctrf: `0.5.2` in the same isolated environment

## Commands and evidence

### Static checks

```bash
TB3_REPO=/path/to/current/terminal-bench ./scripts/run-static-checks.sh
```

Historical result: all static checks passed against an earlier upstream snapshot.

A source-level audit was refreshed against live TB3 commit `c48c033cf1829b2fd62374ace87461b004b97ccd`: the task has the currently required metadata and task README sections, canonical instruction suffix, three-word slug/package name, separate-verifier configuration, pinned verifier tooling, no explicit `allow_internet`, no bare `nproc`, and no verifier-time network install. This is useful preflight evidence but is **not** a substitute for executing the complete live `checks/check-*.sh` set. Final static execution remains pending.

### Local oracle regression

```bash
TEST_PYTHON=/path/to/isolated/python ./scripts/run-local-reference-tests.sh
```

After the latest verifier hardening, the complete reconstructed verifier was executed against the reference solution and produced:

```text
15 passed
```

The current verifier covers ordinary incremental behavior, selective invalidation, missing/corrupt cache and materialized-output recovery, all named cooperative interruption boundaries, a normal-build publication observer with no `BUILDSYS_FAILPOINT` visible to candidate code, and verifier-isolation checks.

The normal-build observer uses only regular source files and an intentionally wide graph. It was separately stress-checked against toy in-place and atomic publishers: the in-place publisher exposed the producer-new/downstream-old state on 10/10 runs, while the atomic publisher avoided it on 10/10 runs. That stress check validates the observer mechanism; the `15 passed` result is the oracle regression evidence.

### Starter / NOP behavior

The untouched starter was rechecked on the current verifier family. Its ordinary incremental/cache/recovery cases pass, while the interrupted-publication case fails for the intended reason: per-target in-place publication can expose a new producer together with the previous downstream snapshot.

Official Harbor NOP remains pending; no official NOP reward is claimed yet.

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

`failpoint-only-staging` is an adversarial verifier probe: it hides unsafe publication only when `BUILDSYS_FAILPOINT` is present while remaining unsafe during an ordinary build. The current full eight-mutant matrix still requires one final rerun after the latest verifier edits; historical mutation results are not presented as final evidence.

### Harbor implementation rubric

Current command:

```bash
harbor check tasks/build-snapshot-publish \
  -r /path/to/current/terminal-bench/rubrics/task-implementation.toml
```

The earlier attempt was blocked before the check trial because Docker was unavailable. This remains an execution gate, not a rubric pass or failure.

### Oracle and NOP

Planned commands:

```bash
HARBOR_ENV=modal ./scripts/run-oracle.sh
HARBOR_ENV=modal ./scripts/run-nop.sh
```

Required outcome: Oracle reward `1`; NOP reward `0`. Official Harbor results remain pending.

### Standard diagnostic and final trials

Run one diagnostic attempt for each live default agent first:

```bash
HARBOR_ENV=modal N_ATTEMPTS=1 JOB_NAME=build-snapshot-publish-diagnostic ./scripts/run-standard-trials.sh
```

If both valid runs fail for the intended systems reason, freeze the task and run the default three attempts per agent:

```bash
HARBOR_ENV=modal ./scripts/run-standard-trials.sh
```

The required final standard matrix is three valid failures for Claude Code / Opus 5 max and three valid failures for Codex / GPT-5.6 Sol xhigh. Crashes, API/rate limits, container failures, verifier errors, and other infrastructure faults do not count.

### Adversarial trials

The current live `/cheat` workflow runs one adversarial attempt for each configured agent. The repository helper now mirrors the live remote JobConfig shape: one Harbor invocation, `n_attempts: 1`, two configured agents, and concurrency `2`, after applying the live remove-then-append adversarial instruction transformation.

```bash
TB3_REPO=/path/to/current/terminal-bench HARBOR_ENV=modal ./scripts/run-cheat-trials.sh
```

Every valid adversarial trial must receive reward `0`. No adversarial reward is currently claimed.
