# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer assignment.

## Summary

The task repairs an incremental build tool under `/app/buildsys/`. Its target graph and content-addressed cache are ordinary and useful on normal builds, but publication is initially performed target by target. The intended systems invariant is that a materialized output tree is one committed generation: an interruption may leave unreachable staging data, never a producer output combined with an old downstream artifact.

## Repository structure

```text
tasks/build-snapshot-publish/   TB3 task, environment, reference solution, verifier
results/                        design, coverage, validation, and trial records
scripts/                        reproducible local/Harbor command wrappers
```

The verifier uses a separate image. Hidden reference logic and fixtures are root-only in that image; the candidate receives only the declared `/app/buildsys/` artifact and a writable candidate workspace.

## Validation

Run live static checks with a checkout of the recorded TB3 snapshot:

```bash
TB3_REPO=/path/to/terminal-bench-3 ./scripts/run-static-checks.sh
```

Run the local independent verifier and mutation suite without Docker:

```bash
./scripts/run-local-reference-tests.sh
./scripts/run-mutation-checks.sh
```

Docker/Harbor commands are in `scripts/`. Official `/run` and `/cheat` results are intentionally not reported as complete until they have executed on the live configured backend.

## Quality gates

- Oracle output must match the independent reference on every focused case.
- The starter and plausible wrong-abstraction mutants must fail.
- Interrupted publication must expose only a complete old or new snapshot.
- Static checks and the implementation rubric must pass.
- The verifier must keep `/tests`, reference truth, candidate inputs, reward output, and child processes within their intended trust boundaries.
- Required standard and adversarial trial results must be recorded before submission.

See `results/contract-coverage.md`, `results/redesign-decision-memo.md`, and `results/validation.md` for the design and evidence trail.
