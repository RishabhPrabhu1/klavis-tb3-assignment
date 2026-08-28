# TB3 Environment and Assignment Snapshot

Reverified against live `harbor-framework/terminal-bench` on 2026-08-27 immediately before final evaluation.

## Authority order

1. The Klavis coding assignment defines the hiring deliverable and says the current Terminal-Bench CI/review configuration is the source of truth for required agent/model configurations, trial count, and `/run`/`/cheat` behavior.
2. Live Terminal-Bench defines the current schema, static checks, implementation rubric, validation flow, and trial defaults.
3. Klavis supplies local subscription-auth sample commands using Docker. This repository uses Docker for local reproduction; it does not claim that local runs were executed by upstream TB3's Modal CI.

The Klavis deliverable is a standalone GitHub repository; an upstream Terminal-Bench PR is not required.

## Frozen submission candidate

```text
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
```

Recorded zero-frontier qualification on this tree:

```text
static checks:       PASS
Oracle/reference:    68/68
Harbor Oracle/NOP:   1/0
frontier calls:      0
```

The fully-qualified predecessor `301107828273e249fbd31ed34d86bf3fed7143a1` rejected all 40/40 development mutation controls. The frozen successor differs only in verifier teardown/reaping hygiene in `tests/conftest.py` and reran current-tree static checks, the complete 68-test reference verifier, and exact-tree Harbor Oracle/NOP.

## Live upstream snapshot

| Item | Current value |
|---|---|
| Upstream `main` | `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` |
| Upstream head timestamp | 2026-08-27 14:29:11 UTC |
| Head change | Raise task timeout cap to eight hours (#1801) |
| `/run` + `/cheat` Harbor | `0.14.0` |
| implementation-rubric Harbor | `0.18.0` |

The public upstream `main` SHA was re-fetched immediately before this update and remained exactly `79e71650...`; there was no newer Terminal-Bench revision to absorb.

## Current trial configuration

Live `.github/harbor-run-defaults.yml` currently specifies:

| Setting | Live value |
|---|---|
| `/run` trials per configured agent | **3** |
| `/cheat` invocations per configured agent | **1** |
| `/run` backend default | `modal` |
| `/cheat` backend default | `modal` |
| `/validate` backend default | `modal` |
| Claude agent/model | `claude-code` / `anthropic/claude-opus-5` |
| Claude reasoning | `max` |
| Claude output cap | `CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000` |
| Codex agent/model | `codex` / `openai/gpt-5.6-sol` |
| Codex reasoning | `xhigh` |
| `harbor analyze` | enabled upstream by default |
| analysis model | `sonnet` |

The standard `/run` workflow expands `trials: 3` into a `(task × agent × trial)` matrix. The live `/cheat` workflow has no trial dimension; it runs one `(task × agent)` entry per configured agent. Therefore the required final model evidence target is **8 runs total**: 3 Codex standard + 3 Claude standard + 1 Codex cheat + 1 Claude cheat.

## Provider availability in the submission environment

| Provider route | Availability | Submission consequence |
|---|---|---|
| Codex subscription authentication | **Available** | Codex standard and `/cheat` evidence can be collected. |
| Claude Code subscription / setup-token route | **Unavailable** | Claude Code standard trials and Claude-driven rubric cannot run. |
| Anthropic API route | **Unavailable for this submission** | Cannot provide the required Claude execution. |
| Amazon Bedrock Claude route | **Unavailable for this submission** | Cannot provide the required Claude execution. |

The missing Claude-dependent results are an explicit provider-access limitation. They are not counted as model failures or treated as passing evidence. The repository keeps the required rows visible and the final submission note will disclose that the automated implementation rubric, three Claude standard trials, and Claude `/cheat` entry were not executed.

## Live `/cheat` acceptance behavior

At upstream revision `79e71650...`, the adversarial workflow is reward-based:

- if `harbor run` succeeds, the workflow parses the mean reward;
- if `harbor run` exits nonzero, the workflow records adversarial reward `0`;
- the remote-backend JobConfig uses `n_attempts: 1`.

Accordingly, the final adversarial requirement is one reward-0 entry for each required agent. This is intentionally different from standard `/run`, where provider/auth/quota/container/timeout/agent errors are not genuine model failures and do not count.

## Docker vs upstream Modal default

Upstream currently defaults `/run`, `/cheat`, and `/validate` to Modal because many benchmark tasks exceed GitHub-hosted runner resources. Both trial workflows retain explicit Docker paths, and Klavis's local examples use `--env docker` with subscription authentication.

The frozen task requests only:

```text
CPU:     1
RAM:     2 GiB
storage: 10 GiB
```

so local Docker is sufficient for the task's declared computational requirements. Final evidence states the actual backend used rather than implying upstream Modal execution.

## Timeout rule

Upstream head `79e71650...` raised the task timeout cap to **8 hours**. The frozen task uses:

```text
agent timeout:    14400s (4h)
verifier timeout: 900s
```

which is within the live cap.

## Implementation rubric

The live implementation-rubric workflow at this upstream revision installs `harbor==0.18.0` and runs a model-driven `harbor exec` review using:

```text
agent: claude-code
model: sonnet
rubric: docs/prompts/task-implementation.toml
artifact: /app/verdicts.json
```

The current rubric includes criteria such as verifiability, solvability, difficulty, realism/interest, outcome-based verification, anti-cheat robustness, task security, functional verification, reproducibility, essential difficulty, test/instruction alignment, novelty, agentic behavior, reviewability, and instruction concision.

Repository source-level review has already corrected the concrete hidden-representation and verifier-isolation defects found during iteration, but that self-audit is **not** a substitute for the automated exact-tree review. Because Claude access is unavailable, the automated rubric is marked **NOT RUN** rather than PASS.

For reproducibility, the repository retains the Claude Code OAuth implementation-rubric runner:

```text
scripts/run-implementation-rubric-oauth.sh
```

It was not executed because the required Claude Code access is unavailable in the submission environment.

## Static/verifier properties relevant to this task

- Separate verifier mode keeps tests, reference truth, and reward state outside the agent container.
- Verifier dependencies are baked into `tests/Dockerfile`; `test.sh` does not perform runtime network installs for verifier tooling.
- Candidate behavior is graded by execution and observable committed state, not source-keyword matching.
- Reward is binary.
- Direct filesystem/schema inspection is limited to structures explicitly documented in the task contract.
- Deterministic pause/fail hooks expose concurrency and crash boundaries without relying on uncontrolled timing races.
- Candidate processes are isolated and verifier teardown includes bounded cleanup/reaping.

`results/contract-coverage.md` contains the requirement-to-test traceability and representation-neutrality review.

## Repository delivery state

The repository default branch contains the frozen task tree and current submission documentation. A read-only GitHub `Submission Consistency` workflow checks:

- frozen task-tree identity and cleanliness;
- `results/preflight-status.json` consistency;
- current reviewer-facing task hashes/counts;
- Python audit-tool compilation;
- retained shell-tool syntax;
- absence of development-only orchestration and stale candidate pins.

The workflow is rerun after reviewer-facing documentation updates; the task subtree remains frozen.

## Final freshness rule

Immediately before final submission, re-fetch and compare:

- Terminal-Bench `main` SHA;
- `.github/harbor-run-defaults.yml`;
- `.github/workflows/run-trials.yml`;
- `.github/workflows/run-cheat-trials.yml`;
- `.github/workflows/review.yml`;
- `docs/prompts/task-implementation.toml`.

Any changed model identity, trial count, Harbor behavior, backend behavior, timeout rule, or rubric requirement supersedes this snapshot.

`bash scripts/final-submission-audit.sh` remains intentionally strict. With Claude-dependent requirements unexecuted, it must not report full TB3 readiness even after all controllable Codex evidence is complete; the submission should preserve and disclose that partial status.
