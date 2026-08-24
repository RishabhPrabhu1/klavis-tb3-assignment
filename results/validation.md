# Validation

Status: local implementation and static validation complete; Docker/Harbor execution is pending because Docker is not installed on the development machine.

## Environment

- TB3 upstream commit: `45e819259a95fb10e43dcebcc11b73140ace3b32`
- Harbor: `0.22.0`
- Docker: unavailable at the time of this record
- Python: `3.14.6`
- pytest: `9.1.1` in an isolated temporary environment
- pytest-json-ctrf: `0.5.2` in the same temporary environment

## Commands and results

### Static checks

The wrapper stages a no-space temporary copy of `tasks/hermetic-build-cache` because the upstream scripts do not safely handle a workspace path containing spaces.

```bash
TB3_REPO=/tmp/terminal-bench-3-research.0wlQ6w/repo ./scripts/run-static-checks.sh
```

Result: all 22 current static checks passed.

### Direct reference regression

```bash
TEST_PYTHON=/tmp/tb3-build-test-venv.Po50im/bin/python ./scripts/run-local-reference-tests.sh
```

Result: `8 passed`.

The untouched starter fails the intended closure cases and passes the ordinary-repeat, unrelated-input, and materialized-output recovery cases. This confirms that nop behavior is nontrivial, but the official Harbor nop result is still pending.

### Mutation checks

```bash
TEST_PYTHON=/tmp/tb3-build-test-venv.Po50im/bin/python ./scripts/run-mutation-checks.sh
```

Result: the untouched starter, an always-rebuild mutant, and an upstream-dependency-ignoring mutant were all rejected by the focused verifier suite.

### Harbor implementation rubric

```bash
harbor check tasks/hermetic-build-cache -r /tmp/terminal-bench-3-research.0wlQ6w/repo/rubrics/task-implementation.toml
```

Result: blocked before the check trial started because the `docker` executable is unavailable. The temporary Harbor job artifacts were removed from the repository after recording the blocker.

### Oracle and nop

Planned commands:

```bash
HARBOR_ENV=docker ./scripts/run-oracle.sh
HARBOR_ENV=docker ./scripts/run-nop.sh
```

Official result: pending Docker/Harbor environment provisioning.
