# Failure Analysis

Status: pending frontier-agent trials for the replacement task.

## Killed prototype

The original `hermetic-build-cache` task was rejected before official trials. Its visible failure was an incomplete dependency closure, and the reference solution reduced to two local changes from `append(...)` to `extend(child_deps)`. That is a bookkeeping defect, not the non-local systems invariant required by the assignment. The prototype is preserved in Git history and is not part of the current `tasks/` tree.

## Replacement hypothesis

`build-snapshot-publish` should fail agents that model a build as independently valid target files. The intended failure is a mixed output generation after a deterministic interruption between target publications. A correct solution must make one immutable generation the visibility boundary while preserving selective cache reuse.

## Trial analysis template

For each valid standard trial, record:

```text
Agent:
Model:
Reasoning effort:
Job/trial path:
Reward:
Infrastructure status:
Failure category: F1 conceptual / F2 local bug / F3 ambiguity / F4 timeout / F5 infrastructure / F6 verifier / F7 reward hacking / F8 leakage
First incorrect abstraction:
Evidence the agent observed or missed:
Whether it revised after evidence:
Why the failure is professionally meaningful:
```
