# Failure Analysis

## Current candidate

```text
5620526fada6eebea16910fc62bf71746aaa40ea
```

The current benchmark's primary systems crux is composition of optimistic multi-project write transactions with the existing project publication, exactly-once request, reader/writer, workspace snapshot, and bounded-GC protocols.

A correct solution must simultaneously provide:

- expensive private member evaluation without holding global publication locks;
- stable manifest/source observations and ordinary project-current version validation;
- workspace member write-set conflict validation;
- whole-transaction retry after stale observations;
- disjoint transaction progress and merge into the newest workspace state;
- atomic overlapping-member publication;
- transaction-private project generations that do not move ordinary project current;
- exactly-once request binding/replay across owner death and response-loss boundaries;
- reclamation of unreachable pre-commit imports;
- durable replay after the original workspace and private project generation have both been reclaimed;
- transitive workspace-to-project retention without retain-everything shortcuts.

## Trial validity first

Before classifying model behavior, a standard trial must satisfy:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward is non-null
verifier completed normally
```

Authentication, provider safety, quota, timeout, Harbor/Docker, or other execution contamination makes the run invalid regardless of raw reward or passing tests.

## Failure categories

- `F1` — genuine conceptual / architectural failure: the model chooses a system boundary or protocol that cannot satisfy one or more stated invariants without broad redesign.
- `F2` — narrow implementation / debugging bug: the broad design is appropriate but code contains a localized correctness error.
- `F3` — specification ambiguity or reasonable interpretation mismatch. Task defect; clarify and rerun.
- `F4` — verifier defect or representation-specific verifier assumption. Verifier defect; repair and rerun.
- `F5` — runtime / environment / container failure.
- `F6` — auth / provider / model / tooling failure.
- `F7` — other invalid or non-difficulty failure, including suspicious shortcut/reward-hacking behavior that prevents clean difficulty interpretation.

Under deadline policy, a valid reward-0 caused by a real candidate implementation error under a clear, correctly verified task is sufficient to freeze; it does not have to be a perfect F1. F3-F7 are not legitimate model-difficulty evidence.

## Historical calibration

### Workspace snapshot design — clean solve

Task tree:

```text
17291a73dc954c66db0ef5cc6cf2f70fe1c85db4
```

Valid GPT-5.6 Sol/xhigh standard probe:

```text
reward = 1.0
58 passed / 0 failed
execution_class = valid-completed-trial
qualification_valid = true
```

Sol implemented the intended immutable generations, request journals, stable cross-project cut, reader/GC protocol, and transitive project protection. Classification: **valid solve; redesign required**.

### First optimistic transaction qualification — verifier bug

Task tree:

```text
bff3b135d88174ac463d6e35a6cc30c4066dd8ea
```

Oracle stopped at 65/66 because `lifecycle_harness.current_token()` treated the newest transaction-private project-history generation as ordinary project current. The task contract explicitly requires private generations not to move ordinary current. The verifier was repaired to distinguish transaction-private generations using the public `snapshot.json` marker `workspace_transaction: true`.

Classification: **F4 verifier defect; no frontier call**.

### Second optimistic transaction probe — verifier bug

Task tree:

```text
40cbd34104e1f0a549be23b46ef70655b728cece
```

Deterministic qualification passed 66/66 with 40/40 mutants rejected and Harbor Oracle/NOP 1/0. A valid GPT-5.6 Sol/xhigh probe returned:

```text
reward = 0
61 passed / 5 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
```

Sol implemented a substantive coherent optimistic transaction system. All five failures were masked by `workspace_txn_harness.workspace_snapshot()` requiring `.workspace-cache/CURRENT`, although the contract never required that selector pathname and the candidate used lowercase `.workspace-cache/current`.

Classification: **primary F4 verifier defect; secondary representation mismatch. Do not count as difficulty evidence.** The verifier now resolves current workspace state semantically by workspace generation commit sequence.

The resulting corrected task tree is `5620526f...`.

## Per-trial analysis template

```text
Agent / model / reasoning:
Execution commit:
Task tree:
Terminal-Bench HEAD:
Evidence directory:

Validity:
- execution_class:
- qualification_valid:
- result_exception_types:
- infrastructure/provider contamination:

Result:
- reward:
- passed / failed / skipped:
- failed tests:

Implementation:
- architecture attempted:
- files changed:
- substantive execution:
- suspicious shortcuts:

Failure analysis:
- primary category F1-F7:
- exact stated invariant violated:
- first incorrect assumption/state boundary:
- local patch vs broad redesign:
- likely repair distance:
- specification ambiguity:
- verifier defect:

Decision:
- legitimate model failure:
- freeze candidate:
- redesign required:
- invalid run:
```

## Final synthesis

For the final standard matrix, report every valid trial independently. Repeated failures on the same transaction-composition issue are particularly strong evidence, but the assignment requirement is binary: all required standard trials must genuinely fail the verifier. Any clean reward-1 solve on the frozen tree invalidates that frozen candidate and must not be reinterpreted as a failure.
