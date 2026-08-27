# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` contains an incremental build tool whose ordinary caching behavior is largely present while its transactional publication, lifecycle, and request semantics require architectural repair.

The benchmark covers:

- crash-safe immutable snapshot publication;
- exact requested-target output closures;
- concurrent writers without lost reusable cache state;
- stable manifest/source views across evaluation and publication;
- long-lived snapshot readers and reader pinning;
- garbage collection under concurrent readers/writers;
- content-addressed object reclamation;
- exactly-once build request IDs across duplicate concurrency and crashes;
- request takeover after a pre-commit owner dies;
- post-publication response-loss recovery;
- replay after later publications and GC of the original generation;
- publication races where a build that started earlier must preserve a stranded committed request before replacing its generation.

Deterministic failpoint and pausepoint hooks make crash and concurrency cases reproducible.

The task uses a separate verifier image. Candidate code receives only the declared `/app/buildsys/` artifact; verifier tests and independent reference logic remain verifier-owned.

## Current candidate

```text
05e14f258a07c24a04e7c8ae1516ce36c5796f44
```

This tree is **pending deterministic qualification**. It must not be represented as final or frozen frontier evidence yet.

Historical task trees:

- `d84a5bf3df6a2c3ed7a523c7fee072936f4029e4` — invalidated after a valid Sol diagnostic exposed an unstated verifier representation requirement;
- `4eaf21ae9456395fb080be497852c0ff9623b8fa` — corrected and deterministically qualified, then cleanly solved by GPT-5.6 Sol/xhigh with reward 1 and 37/37 tests;
- `3ddb933ae848f6912210371c6afc210ceea3f373` — first exactly-once request redesign, superseded before frontier testing after a verifier coverage audit found missing composition races;
- `f90cf3f01fe692b1d473fcbf82858cd65d4a5bc8` — strengthened request semantics/tests, superseded only because task metadata and reviewer README were updated to accurately describe that protocol. Runtime semantics were unchanged in that metadata step.

## Repository structure

```text
tasks/build-snapshot-publish/   Terminal-Bench task, starter, oracle, verifier
scripts/                        validation and evidence-preserving trial runners
results/                        validation, coverage, trials, failure analysis
```

`results/execution-plan.md` is the active execution order.

## Pre-frontier qualification

The local deterministic qualification uses a pinned Python 3.13 verifier environment and runs:

```bash
TB3_REPO="$HOME/.cache/klavis-tb3-terminal-bench" \
  bash scripts/run-corrected-tree-local-qualification.sh
```

That includes:

- live TB3 static checks;
- full Oracle/reference regression;
- core publication/cache mutations;
- lifecycle/GC mutations;
- exactly-once request-protocol mutations.

The current request mutation matrix includes negative controls for replay recommit, cross-target replay, global request serialization, incorrect post-publish failpoint placement, and invocation-start-only recovery that loses a stranded request during a later publication race.

After the local suite is green, run Harbor Oracle/NOP with zero Sol calls on the exact task tree using the home-backed evidence path required by macOS/Colima.

Verifier dependencies are pinned in `tasks/build-snapshot-publish/tests/Dockerfile`; `test.sh` performs no runtime network installation.

## Live Terminal-Bench configuration

The currently verified live source of truth specifies three standard trials each for:

- `codex` + `openai/gpt-5.6-sol`, `reasoning_effort=xhigh`;
- `claude-code` + `anthropic/claude-opus-5`, `reasoning_effort=max`.

Live `/run` and `/cheat` use Harbor 0.14.0. Recheck upstream before final evidence if Terminal-Bench advances.

The current local workflow is **Codex-only** because Claude Code subscription access is not available. This does not satisfy the written Claude requirement unless that requirement is later completed or waived.

## Frontier evidence policy

No model failure counts unless the trial:

- uses the exact qualified/frozen task tree;
- completes normally without auth, quota, provider-safety, Docker, Harbor, timeout, or verifier infrastructure contamination;
- has audited `result.json.exception_info` with no invalidating exception;
- fails for a task-substantive reason rather than ambiguity or verifier defect.

A clean Sol/xhigh solve triggers a task-level redesign and full requalification. Do not add trajectory-specific traps to manufacture failure.

The target final Codex evidence is three valid Sol/xhigh failures plus a valid reward-0 `/cheat` trial on the exact frozen tree. Claude standard and adversarial evidence remains separately outstanding under the written assignment.

## Current next action

Run **zero-model deterministic qualification** on:

```text
05e14f258a07c24a04e7c8ae1516ce36c5796f44
```

Do not spend another frontier-model call until static checks, the full Oracle, all mutation matrices, and Harbor Oracle/NOP are green on this exact tree.

## Evidence records

- `results/execution-plan.md` — active pipeline and gate state.
- `results/contract-coverage.md` — instruction-to-verifier coverage and trust boundary.
- `results/preflight-status.json` — machine-readable qualification state.
- `results/standard-trials.md` — standard frontier evidence and exclusions.
- `results/cheat-trials.md` — adversarial evidence and invalid provider-blocked attempts.
- `results/failure-analysis.md` — model-failure versus specification/verifier/infrastructure classification.

Trial evidence is stored under `~/.cache/klavis-tb3-runs/` by default and records repository/task/upstream SHAs, model configuration, Harbor version, raw Harbor output, verifier artifacts, and audited summaries.
