# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` contains an incremental build tool whose ordinary caching behavior is useful but whose starter publishes rebuilt targets independently. The required invariant is that the visible `out/` tree is one committed snapshot: interruption may leave unreachable work, but never a new producer output combined with an old downstream artifact.

The task uses a separate verifier image. Candidate code receives only the declared `/app/buildsys/` artifact; hidden tests and independent reference logic remain verifier-owned.

## Repository structure

```text
tasks/build-snapshot-publish/   Terminal-Bench task, starter, oracle, verifier
scripts/                        validation and trial command wrappers
results/                        validation, coverage, trials, failure analysis
```

## Validation

Use a fresh checkout of the live Terminal-Bench repository for final qualification:

```bash
TB3_REPO=/path/to/terminal-bench ./scripts/run-static-checks.sh
./scripts/run-local-reference-tests.sh
./scripts/run-mutation-checks.sh
harbor check tasks/build-snapshot-publish -r "$TB3_REPO/rubrics/task-implementation.toml"
HARBOR_ENV=modal ./scripts/run-oracle.sh
HARBOR_ENV=modal ./scripts/run-nop.sh
```

The current upstream snapshot and exact trial configuration are recorded in `results/environment.md`. Standard and adversarial trial evidence belongs in `results/standard-trials.md` and `results/cheat-trials.md`; no pending or infrastructure-invalid run is counted as a model failure.

## Evidence

- `results/contract-coverage.md` — instruction-to-verifier coverage and anti-cheat boundaries.
- `results/validation.md` — static, local, Harbor, oracle, nop, and mutation status.
- `results/standard-trials.md` — required standard model trials.
- `results/cheat-trials.md` — required adversarial trials.
- `results/failure-analysis.md` — classification of genuine model failures.
