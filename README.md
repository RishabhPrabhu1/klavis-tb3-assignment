# Build Snapshot Publication

This repository contains one original Terminal-Bench 3 task for the Klavis Founding Engineer coding assignment.

## Task

`tasks/build-snapshot-publish/` contains an incremental build system whose starter implementation has ordinary caching behavior but is missing the required transactional publication, lifecycle, recovery, and workspace semantics.

The current task combines five layers:

- crash-safe immutable project generations and atomic publication;
- concurrent incremental builds with stable manifest/source views and reusable cache merging;
- reader/writer lifecycle plus bounded garbage collection and object reclamation;
- exactly-once project request IDs across duplicate concurrency, owner death, response loss, later publications, and GC;
- cross-project workspace snapshots and optimistic atomic multi-project `workspace-build` transactions.

The workspace transaction layer is the current difficulty crux. Expensive member evaluation must happen privately outside long-held workspace/project publication locks, followed by coordinated validation and a short atomic commit. Disjoint transactions must progress and merge; overlapping transactions must retry; transaction-private project generations must not move ordinary project current; crash/replay semantics must remain exactly-once; and retained workspace state must protect referenced project history without retaining everything forever.

Deterministic failpoints and pausepoints make crash and concurrency interleavings reproducible.

## Current candidate

Current corrected task tree:

```text
5620526fada6eebea16910fc62bf71746aaa40ea
```

This tree differs from the immediately previous transaction candidate only by a representation-neutral verifier fix: workspace transaction tests now resolve the current workspace snapshot semantically rather than requiring a `.workspace-cache/CURRENT` symlink. The task contract does not require that pathname.

The immediately previous tree, `40cbd34104e1f0a549be23b46ef70655b728cece`, deterministically passed:

- 66/66 Oracle/reference tests;
- 40/40 non-equivalent mutation checks;
- Harbor Oracle reward 1;
- Harbor NOP reward 0;
- zero frontier calls during qualification.

A valid GPT-5.6 Sol/xhigh probe on that tree returned reward 0 with 61/66 tests, but all five failures were masked by the verifier's hard-coded workspace selector pathname. That result is therefore classified as a verifier/specification-side non-architectural failure and is not counted as model difficulty evidence.

The corrected `5620526f...` tree must be requalified and remeasured before freeze.

## Important historical evidence

- `4eaf21ae9456395fb080be497852c0ff9623b8fa` — corrected generation-publication design; cleanly solved by GPT-5.6 Sol/xhigh.
- `42cba8ad00bebf316048d1470033c1742a20ec97` — exactly-once request redesign; a substantial Sol run reached 48/48 verifier tests but was formally invalid because the provider ended with a subscription-limit exception.
- `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` — cross-project workspace-snapshot redesign; deterministically qualified and then cleanly solved by GPT-5.6 Sol/xhigh with 58/58 tests and reward 1.
- `40cbd34104e1f0a549be23b46ef70655b728cece` — optimistic workspace-transaction redesign; deterministically qualified, then produced a valid reward-0 Sol probe that was invalid as difficulty evidence because a verifier helper required an unstated `.workspace-cache/CURRENT` representation.
- `5620526fada6eebea16910fc62bf71746aaa40ea` — current corrected transaction candidate.

## Repository structure

```text
tasks/build-snapshot-publish/   TB3 task, starter, reference solution, verifier
scripts/                        qualification, trial, audit, resume, and deadline runners
results/                        validation state, trial records, coverage, failure analysis
```

## Deterministic qualification

The deadline workflow uses a pinned Python 3.13 verifier environment and runs:

```bash
bash scripts/run-next-qualification-step.sh
```

That performs:

- current TB3 static checks;
- full Oracle/reference verifier;
- 14 core publication/cache mutants;
- 6 lifecycle/GC mutants;
- 5 project exactly-once request mutants;
- 7 workspace snapshot/cross-layer mutants;
- 8 optimistic workspace transaction mutants;
- Harbor Oracle/NOP with zero Sol calls.

Expected deterministic totals for the current design are 66 Oracle tests and 40 rejected non-equivalent mutants.

## Frontier configuration

The written Klavis requirement specifies three standard trials each for:

- `codex` + `openai/gpt-5.6-sol`, `reasoning_effort=xhigh`;
- `claude-code` + `anthropic/claude-opus-5`, `reasoning_effort=max`.

It also requires adversarial `/cheat` trials for both configurations with reward 0. Infrastructure, authentication, provider-safety, quota, timeout, or agent-crash runs do not count as model failures.

Harbor 0.14.0 is used for recorded candidate trials.

## Deadline execution workflow

Routine execution is intentionally one-command and evidence-preserving:

```bash
bash scripts/resume-deadline-cycle.sh
```

The resume runner reuses same-tree qualification and trial evidence, refuses duplicate model launches when an interrupted run is present, and continues only from the first genuinely unfinished gate.

Once a valid same-tree reward-0 Sol probe is reviewed and accepted as a real task failure, the remaining Sol standard trials can be collected with:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

The matrix runner stops immediately on a solve or invalid execution rather than silently accumulating unusable evidence.

## Claude access

Klavis's sample uses Claude Code OAuth (`claude setup-token`) to avoid API billing. If subscription OAuth is unavailable, Claude Code also supports Amazon Bedrock. Bedrock exposes the required model as `anthropic.claude-opus-5`; any Bedrock route used for final evidence must still preserve the required Claude Code agent, Opus 5 model, max reasoning setting, Docker environment, and auditable Harbor result.

Claude standard/adversarial evidence remains outstanding until a valid access route is established.

## Evidence policy

A model failure counts only when:

- the exact qualified/frozen task tree is measured;
- the trial completes normally;
- authoritative `result.json` contains no invalidating exception;
- the verifier itself completes normally;
- the failure is caused by candidate behavior under a clear contract, not verifier representation assumptions or infrastructure.

A clean standard solve means the current candidate is not sufficient. A valid reward-0 caused by a genuine candidate implementation error is eligible for freeze under the current deadline policy; it does not need to be an artificially manufactured model-specific trap.

## Evidence records

- `results/preflight-status.json` — machine-readable qualification state.
- `results/standard-trials.md` — standard frontier evidence and exclusions.
- `results/cheat-trials.md` — adversarial evidence and invalid provider-blocked attempts.
- `results/failure-analysis.md` — failure classification.
- `results/contract-coverage.md` — contract-to-verifier coverage and trust boundary.
- `results/execution-plan.md` — execution order and gate state.

Raw trial evidence is kept under `~/.cache/klavis-tb3-runs/` and records repository/task/upstream SHAs, model configuration, Harbor version, raw Harbor output, verifier artifacts, trajectories, and audited summaries.
