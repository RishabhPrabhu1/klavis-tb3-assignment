# Failure Analysis

Status: pending frontier-agent trials.

## Intended failure mode

The starter build tool expands nested includes and directory globs correctly when it runs, but its persisted dependency manifest records only the immediate reference. A direct-input cache therefore appears correct on ordinary repeated builds while missing changes to nested files and existing members of a globbed directory. The correct repair carries the complete discovered closure into the next action-key calculation.

## Local evidence

The reference repair passes all eight focused verifier tests. The untouched starter fails the dependency-manifest, nested-input, changed-glob-member, and complete-glob-discovery cases while passing ordinary repeat, unrelated-input, new-glob-membership invalidation, and materialized-output restoration cases. These are local implementation diagnostics, not frontier-agent trial results.

## Trial analysis template

For each invalid standard trial, record:

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
