# Validation

Status: v2 local implementation and static validation are complete; Docker/Harbor and frontier trials remain pending because Docker is unavailable and Modal credentials are not configured on the development machine.

## Environment

- TB3 upstream commit: `45e819259a95fb10e43dcebcc11b73140ace3b32`
- Harbor: `0.22.0`
- Docker: unavailable at the time of this record
- Modal credentials: unavailable at the time of this record
- Python: `3.14.6`
- pytest: `9.1.1` in an isolated temporary environment
- pytest-json-ctrf: `0.5.2` in the same temporary environment

## Commands and results

### Static checks

The wrapper stages a no-space temporary copy because the upstream scripts do not safely handle a workspace path containing spaces.

```bash
TB3_REPO=/tmp/terminal-bench-3-research.0wlQ6w/repo ./scripts/run-static-checks.sh
```

Result: all 22 current static checks passed for `build-snapshot-publish`.

### Local reference regression

```bash
TEST_PYTHON=/tmp/tb3-build-test-venv.Po50im/bin/python ./scripts/run-local-reference-tests.sh
```

Result: 6 focused tests passed for the generation-publication oracle. The tests cover clean/repeat reuse, transitive edits and new includes, unrelated inputs, target-definition changes, cache/output corruption recovery, and interrupted publication.

The untouched v2 starter fails the two interrupted-publication parameterizations and passes the ordinary cache/output cases. This is the intended nop signal, but the official Harbor nop result remains pending.

### Mutation checks

```bash
TEST_PYTHON=/tmp/tb3-build-test-venv.Po50im/bin/python ./scripts/run-mutation-checks.sh
```

Result: all seven invalid variants were rejected: starter, always-rebuild, ignore-upstream, ignore-definition, trust-object, publish-in-place, and no-selector.

The compact generation-based oracle is 270 nonblank lines; it remains below the continuation plan's approximate 300-line kill threshold.

### Harbor implementation rubric

```bash
harbor check tasks/build-snapshot-publish \
  -r /tmp/terminal-bench-3-research.0wlQ6w/repo/rubrics/task-implementation.toml
```

Result: blocked before the check trial. On 2026-08-24, Harbor reported `FileNotFoundError: [Errno 2] No such file or directory: 'docker'` while trying to provision the implementation-rubric check.

### Oracle and nop

Planned commands:

```bash
HARBOR_ENV=docker ./scripts/run-oracle.sh
HARBOR_ENV=docker ./scripts/run-nop.sh
```

Official result: pending Docker/Harbor environment provisioning.

### Standard and adversarial trials

The current live TB3 defaults are recorded in `results/environment.md`. Standard and `/cheat` trials have not been run; no model or reward result is being claimed.
