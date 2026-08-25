# Validation

Status: the task implementation is qualified through current static checks, local verifier regression, mutation testing, Docker build, and version-matched Harbor Oracle/NOP. The remaining gates are the current implementation-rubric judgment and the frontier/adversarial model trials.

## Qualified revision

- Task/runtime/test revision qualified by CI: `48ad719d72a8c623ae77c21acefdc6e65ef9062d`
- Current repository HEAD at this record: `44421479203c93c4f52dd9a52fa34596162f2efd`
- The only change between those revisions is reviewer documentation in `results/contract-coverage.md`; task files, verifier files, scripts, and workflow code are unchanged.
- Live Terminal-Bench snapshot used by the qualification run: `405a783ea111ab855718ce93b2b0cadaa2e8d47f`

## Version-matched GitHub Actions qualification

Workflow: `.github/workflows/preflight.yml`

Run `32815877598` completed successfully on the qualified task revision. Both jobs succeeded:

- `preflight`: live static checks, local oracle regression, and mutation matrix.
- `harbor-docker`: task Docker build, Harbor Oracle, and Harbor NOP.

### Live static checks

The workflow cloned the live `harbor-framework/terminal-bench` repository at `405a783ea111ab855718ce93b2b0cadaa2e8d47f` and executed `scripts/run-static-checks.sh` against that checkout.

All current static checks passed, including:

- internet-policy checks
- canary and canonical instruction suffix
- Dockerfile platform/reference/sanity checks
- GPU/resource checks
- no bare `nproc`
- pinned pip/uv tooling and pytest version
- separate-verifier configuration
- absolute task paths
- required task fields, package name, slug, and timeout
- test-file references and `test.sh` sanity
- no trial-time verifier network fetch
- verifier tooling baked into the verifier image

### Local oracle regression

The verifier regression ran as verifier root under Python 3.13 with the pinned pytest tooling.

```text
13 passed
```

This includes incremental/cache/recovery behavior plus cooperative and externally observed publication safety.

### Mutation matrix

The qualification run exercised all eight current negative implementations and rejected every one:

| Mutant | Intended defect |
|---|---|
| `starter` | ordinary per-target publication exposes mixed snapshots |
| `always-rebuild` | destroys unchanged cache reuse |
| `ignore-upstream` | misses required-output invalidation |
| `ignore-definition` | misses target-definition invalidation |
| `trust-object` | trusts missing/corrupt cache state |
| `publish-in-place` | publishes target outputs independently |
| `no-selector` | never exposes a committed output snapshot |
| `failpoint-only-staging` | becomes safe only when the cooperative failpoint variable exists |

The last mutant is the key regression for the earlier failpoint-short-circuit weakness: the normal-build Linux publication observer runs without `BUILDSYS_FAILPOINT`, freezes candidate processes when rebuilt producer output becomes visible, and rejects a mixed producer/downstream snapshot.

### Docker build

The task environment built successfully from `tasks/build-snapshot-publish/environment` on the GitHub Ubuntu runner.

### Harbor Oracle and NOP

The Docker qualification job installed Harbor `0.18.0`, matching the current TB3 validation-workflow pin, and ran the task through Harbor in Docker mode.

Oracle:

```text
1/1 Mean: 1.000
Exceptions: 0
Reward: 1.0
```

NOP:

```text
1/1 Mean: 0.000
Exceptions: 0
Reward: 0.0
```

These are valid execution results, not inferred local outcomes. Current TB3 defaults use Modal for `/validate`, so a Modal `/validate` run may still be useful as an environment-parity check, but the Docker execution already establishes that the environment builds and the separate verifier distinguishes the oracle from the untouched starter under the current Harbor validation version.

## Implementation rubric

The authoritative rubric is the live `rubrics/task-implementation.toml` at the recorded upstream commit. The live TB3 automated `/review` workflow runs a Sonnet reviewer through Harbor `0.18.0` and requires repository-side model credentials.

This standalone assignment repository does not claim that TB3's automated `/review` job has run. A reviewer-side assessment against the same current rubric is recorded separately in `results/implementation-rubric-review.md`; any model-generated rubric result must remain labeled separately from the official TB3 workflow.

## Standard diagnostic and final trials

Current TB3 `/run` defaults are:

- `claude-code` / `anthropic/claude-opus-5`, reasoning `max`
- `codex` / `openai/gpt-5.6-sol`, reasoning `xhigh`
- Modal environment
- three trials per agent for the final matrix

Before spending the final six trials, run one valid diagnostic attempt for each agent:

```bash
HARBOR_ENV=modal N_ATTEMPTS=1 JOB_NAME=build-snapshot-publish-diagnostic ./scripts/run-standard-trials.sh
```

Only genuine verifier failures count. API errors, rate limits, agent crashes, environment failures, verifier failures, or timeouts caused by infrastructure do not count as model failures.

If both diagnostics fail for the intended systems reason, freeze the task and run the final matrix:

```bash
HARBOR_ENV=modal ./scripts/run-standard-trials.sh
```

The Klavis acceptance target is three valid failures for Opus 5 max and three valid failures for GPT-5.6 Sol xhigh.

## Adversarial trials

The current `/cheat` workflow runs one adversarial attempt for each configured agent. It strips the ordinary `Do not cheat...` sentence and appends the live `rubrics/hack-trial-prompt.md` after the task instruction. The repository helper mirrors that transformation and the current model configuration:

```bash
TB3_REPO=/path/to/current/terminal-bench HARBOR_ENV=modal ./scripts/run-cheat-trials.sh
```

Every valid adversarial trial must receive reward `0`. No adversarial reward is claimed until those trials actually run.

## Remaining gates

1. Complete the current-rubric judgment and resolve any blocker it identifies.
2. Prevent public solution/test discovery before frontier trials.
3. Run one valid Opus 5 max diagnostic and one valid GPT-5.6 Sol xhigh diagnostic.
4. If both genuinely fail, freeze the task and run the final 3+3 standard matrix.
5. Run the current one-attempt-per-agent adversarial matrix; every reward must be `0`.
6. Record trajectories and classify failures in `results/standard-trials.md`, `results/cheat-trials.md`, and `results/failure-analysis.md`.
