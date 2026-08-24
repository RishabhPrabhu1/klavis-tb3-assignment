# Verifier Security and Coverage Plan

## Trust boundary

The verifier image owns `/tests` and hidden reference logic. Before any candidate process runs:

- `/logs/verifier` is root-only;
- `/tests` is root-only and unreadable to the candidate UID;
- the candidate artifact under `/app/buildsys` is read-only to the candidate UID;
- the candidate workspace and reference workspace are different directories;
- the reference workspace is root-only and never passed to candidate code.

The candidate process receives only the candidate workspace, the public command arguments, and ordinary environment values. Expected outputs are reconstructed from the independent reference workspace, never from files the candidate can mutate.

## Process lifecycle

Each invocation runs in a fresh session as `nobody`, with stdout/stderr redirected to root-owned temporary files. After normal exit, failure, or timeout, the verifier terminates the complete process group, waits for descendants, scans for surviving descendants, and only then inspects artifacts. The root verifier alone writes the binary reward.

## Contract coverage

The final verifier will cover:

- clean output bytes and output paths;
- dependency-order events and complete dependency lists;
- unchanged repeat-cache reuse;
- direct and transitive input invalidation;
- target-definition invalidation;
- valid and corrupt object recovery;
- missing and corrupt materialized-output recovery;
- nested directives in discovered files;
- interrupted publication before, during, and after target publication;
- old-or-new snapshot visibility after interruption;
- cleanup/recovery of unreachable staging state;
- downstream reuse when an upstream output digest is unchanged.

Every row will be linked to an instruction sentence in `results/contract-coverage.md`. Near-correct mutants will be required to fail for the intended state-model reason.
