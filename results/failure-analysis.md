# Failure Analysis

Status: pending valid standard trials for `build-snapshot-publish`.

The intended difficulty is the publication invariant, not the ordinary cache mechanics: individually correct target outputs are not a valid visible build state unless they belong to one committed snapshot. A meaningful failure should therefore show the agent preserving or reintroducing per-target visibility, incomplete generation switching, or another architectural mistake that can expose producer-new/downstream-old output after interruption.

Use the following categories:

- `F1` — conceptual/architectural failure aligned with the intended systems crux.
- `F2` — local implementation bug after the correct architecture was understood.
- `F3` — instruction ambiguity or specification misunderstanding.
- `F4` — timeout.
- `F5` — infrastructure/API/container failure.
- `F6` — verifier defect.
- `F7` — reward-hacking/verifier exploit.
- `F8` — task-specific solution leakage.

Only genuine valid task failures count toward the assignment. `F3`–`F8` require correction or rerun rather than being treated as evidence of difficulty.

For each valid standard zero-reward trial, record:

```text
Agent / model / reasoning:
Trial and job path:
Reward:
Failure category:
First incorrect abstraction:
Evidence observed or missed:
Whether the agent revised its model:
Final implementation strategy:
Verifier rejection:
Why the failure is aligned (or not aligned) with the intended crux:
```

After all six trials, add a short cross-trial synthesis identifying whether failures converge on the same architectural misunderstanding or are merely unrelated local mistakes.
