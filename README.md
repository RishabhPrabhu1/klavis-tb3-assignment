# Hermetic Incremental Build Cache

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer assignment.

## Summary

The task repairs a small incremental build tool under `/app/buildsys/`. The tool expands recursive file includes and directory globs, caches target outputs, and propagates changes through a build graph. The intended difficulty is recovering the semantic dependency closure: a valid cache key must account for transitive file content and the membership of globbed directories, not only the direct source file.

## Repository structure

```text
tasks/hermetic-build-cache/   TB3 task, environment, reference solution, verifier
candidate-selection-dossier.md design candidates and selection rationale
results/                      environment, validation, trial, and development records
scripts/                      reproducible local/Harbor command wrappers
```

The task directory is intentionally self-contained. The verifier tests and reference data are baked into the separate verifier image; they are not copied into the agent image.

## Validation

The live TB3 snapshot used for development is recorded in `results/environment.md`. Run static checks by pointing the wrapper at a checkout of the matching upstream repository:

```bash
TB3_REPO=/path/to/terminal-bench-3 ./scripts/run-static-checks.sh
```

The direct reference regression suite can be exercised without Docker:

```bash
./scripts/run-local-reference-tests.sh
```

The focused mutation suite checks that the starter, an always-rebuild implementation, and an implementation that ignores upstream output changes are rejected:

```bash
./scripts/run-mutation-checks.sh
```

Harbor and Docker-backed validation use the wrappers in `scripts/`. The current TB3 defaults are Modal for `/validate`, `/run`, and `/cheat`; local Docker can be selected with `HARBOR_ENV=docker` when Docker is available.

## Task quality gates

- Oracle: every focused verifier case passes.
- Nop/starter: the intended transitive-closure cases fail.
- Static checks: all current upstream checks pass.
- Verifier: separate image, independent reference behavior, binary reward, CTRF output, unprivileged candidate execution, protected reward channel, and process cleanup.
- Final acceptance: current TB3 standard and adversarial trials must be run and documented. This repository must not be treated as a finished Klavis submission until those results are recorded.

## Reproduction

See `results/validation.md` for exact commands and observed results. The task's public CLI is:

```text
python3 -m buildsys.cli build --project PROJECT --target TARGET --report REPORT
```

## Design notes

The selected task and fallback candidates, overlap audit, explicit kill conditions, and hypothesis log are in `candidate-selection-dossier.md` and `results/development-log.md`.
