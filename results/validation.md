# Validation

Status: task design, oracle behavior, and verifier hardening are substantially complete. The remaining gates are live static execution, the current implementation-rubric review, official Harbor Oracle/NOP, and the frontier/adversarial model matrix.

## Environment

- Current live TB3 snapshot recorded in `results/environment.md`: `c48c033cf1829b2fd62374ace87461b004b97ccd`
- Earlier static execution snapshot: `45e819259a95fb10e43dcebcc11b73140ace3b32`
- Local Harbor previously installed: `0.22.0`
- Live `/run` and `/cheat` workflows pin Harbor: `0.14.0`
- Live `/validate` Oracle/NOP workflow pins Harbor: `0.18.0`
- Docker: unavailable at the recorded development-machine snapshot
- Modal credentials: not stored in this repository
- Python test execution: Linux container, Python 3.13, pytest 9.x

## Commands and evidence

### Static checks

```bash
TB3_REPO=/path/to/current/terminal-bench ./scripts/run-static-checks.sh
```

Historical result: all static checks passed against an earlier upstream snapshot.

A source-level audit was refreshed against live TB3 commit `c48c033cf1829b2fd62374ace87461b004b97ccd`: the task has the currently required metadata and task README sections, canonical instruction suffix, three-word slug/package name, separate-verifier configuration, pinned verifier tooling, no explicit `allow_internet`, no bare `nproc`, and no verifier-time network install. All canary-scoped task files were rechecked after verifier pruning/refactoring. The task instruction was subsequently shortened without changing those structural properties. This is useful preflight evidence but is **not** a substitute for executing the complete live `checks/check-*.sh` set. Final live static execution remains pending.

### Local oracle regression

```bash
TEST_PYTHON=/path/to/isolated/python ./scripts/run-local-reference-tests.sh
```

The final runtime verifier was split from its development-only harness self-tests so reward assertions now focus on task outcomes. A reconstructed post-refactor verifier using the current oracle/reference behavior was executed in Linux in two groups:

```text
7 passed  # incremental/cache/recovery cases
5 passed  # cooperative + external publication cases
```

All **12 runtime cases passed**. The earlier pre-prune run had also produced `15 passed`; the three removed cases were verifier-harness self-tests rather than candidate-solution requirements.

The external normal-build publication test now uses Linux `inotify` to observe visible producer publication and immediately `SIGSTOP` the candidate process before inspecting the snapshot. The hidden graph still provides a long downstream window, but official Linux verification no longer depends on a 1 ms polling loop. A polling fallback exists only for local non-Linux development. The candidate never receives `BUILDSYS_FAILPOINT` in this test.

### Starter / NOP behavior

The untouched current starter was executed against the post-refactor runtime verifier. Result:

```text
6 passed, 6 failed
```

The failures were publication failures: cooperative interruptions at producer/intermediate boundaries exposed mixed old/new output, and the external normal-build observer froze a producer-new/downstream-old state. Ordinary incremental/cache/recovery behavior continued to pass. This is the intended NOP failure mode.

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

Post-refactor targeted killing tests were executed for every current mutant. All eight were rejected:

| Mutant | Killing behavior |
|---|---|
| `starter` | cooperative and external publication checks |
| `always-rebuild` | unchanged-repeat cache-status check |
| `ignore-upstream` | transitive edit / required-output propagation |
| `ignore-definition` | selective target-definition invalidation |
| `trust-object` | corrupt cache-object recovery |
| `publish-in-place` | interrupted snapshot check |
| `no-selector` | initial materialized-output/report check |
| `failpoint-only-staging` | normal-build external publication observer |

The `failpoint-only-staging` probe is the important adversarial case: it hides unsafe publication whenever `BUILDSYS_FAILPOINT` exists but remains unsafe during an ordinary build. The event-driven external observer rejected it by freezing a mixed snapshot.

### Harbor implementation rubric

Current contributor-side command:

```bash
harbor check tasks/build-snapshot-publish \
  -r /path/to/current/terminal-bench/rubrics/task-implementation.toml
```

The live TB3 review workflow currently pins Harbor `0.18.0` and performs the implementation review with the current rubric/reviewer path. The earlier local attempt was blocked because Docker was unavailable, so a current rubric result remains pending.

### Oracle and NOP

The live validation workflow currently installs Harbor `0.18.0` and then uses the same direct command shape as these helpers:

```bash
HARBOR_ENV=modal ./scripts/run-oracle.sh
HARBOR_ENV=modal ./scripts/run-nop.sh
```

Required outcome: Oracle reward `1`; NOP reward `0`. Official Harbor results remain pending.

### Standard diagnostic and final trials

The live `/run` workflow currently installs Harbor `0.14.0`. Run one diagnostic attempt for each live default agent first:

```bash
HARBOR_ENV=modal N_ATTEMPTS=1 JOB_NAME=build-snapshot-publish-diagnostic ./scripts/run-standard-trials.sh
```

If both valid runs fail for the intended systems reason, freeze the task and run the default three attempts per agent:

```bash
HARBOR_ENV=modal ./scripts/run-standard-trials.sh
```

The required final standard matrix is three valid failures for Claude Code / Opus 5 max and three valid failures for Codex / GPT-5.6 Sol xhigh. Crashes, API/rate limits, container failures, verifier errors, and other infrastructure faults do not count.

### Adversarial trials

The current live `/cheat` workflow also installs Harbor `0.14.0` and runs one adversarial attempt for each configured agent. The repository helper mirrors the live remote JobConfig shape: one Harbor invocation, `n_attempts: 1`, two configured agents, and concurrency `2`, after applying the live remove-then-append adversarial instruction transformation. The helper uses Python for that transform so it behaves consistently on both GNU/Linux and macOS/BSD development machines.

```bash
TB3_REPO=/path/to/current/terminal-bench HARBOR_ENV=modal ./scripts/run-cheat-trials.sh
```

Every valid adversarial trial must receive reward `0`. No adversarial reward is currently claimed.
