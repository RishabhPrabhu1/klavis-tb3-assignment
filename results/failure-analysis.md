# Failure Analysis

Status: pending valid standard trials for the redesigned `build-snapshot-publish` task.

## Intended systems crux

The benchmark is no longer calibrated around one atomic-directory trick. A genuine hard-task failure should arise while composing several stated invariants:

- incremental dependency/cache correctness;
- one exact visible snapshot per successful requested closure;
- crash-safe output/cache/report commit semantics;
- concurrent disjoint progress;
- preservation of still-valid cache state across stale-base concurrent commits;
- isolation of interrupted writers;
- a manifest/source view that is still current at publication time.

A strong model may understand some pieces while choosing a transaction boundary that makes another piece incorrect. That kind of cross-invariant architectural failure is the primary intended evidence.

## Categories

- `F1` — substantive architectural failure on one or more stated systems invariants.
- `F2` — substantive concurrency/recovery implementation bug after the broad architecture was understood.
- `F3` — incidental local coding bug unrelated to benchmark difficulty.
- `F4` — instruction ambiguity/specification mismatch.
- `F5` — verifier defect or implementation-specific verifier assumption.
- `F6` — authentication/API/Harbor/Docker/model infrastructure failure.
- `F7` — invalid timeout/crash where the model did not receive a fair completed trial.
- `F8` — reward hacking, hidden-test exploit, or task-specific solution leakage.

For assignment difficulty evidence, count only valid reward-0 trials whose trajectory supports `F1` or a clearly task-substantive `F2`. `F3` should be treated cautiously; `F4`–`F8` do not count and require correction/rerun.

## Per-trial record

```text
Agent / model / reasoning:
Benchmark commit and task-tree identity:
Trial/job/evidence path:
Reward and verifier summary:
Validity classification:
Failure category:
Architecture attempted:
First incorrect assumption or state boundary:
Which stated invariant(s) failed:
What the model correctly understood:
Whether it noticed/revised the mistake:
Why this is or is not defensible difficulty evidence:
```

## Cross-trial synthesis

After the final matrix, compare the six valid trajectories. Strong evidence is repeated failure on the same underlying composition problem through different implementations. Weaker evidence is six unrelated syntax/local bugs. Also record any model that solves the task cleanly; do not reinterpret a success as a failure or add post-hoc trajectory-specific requirements.
