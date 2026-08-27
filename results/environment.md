# TB3 Environment and Assignment Snapshot

Checked against live `harbor-framework/terminal-bench` on 2026-08-27.

## Authority order

1. The Klavis coding assignment defines the hiring deliverable and says current Terminal-Bench CI/review configuration is the source of truth for required agent/model configurations, trial count, and `/run`/`/cheat` behavior.
2. Live Terminal-Bench defines current schema, static checks, implementation rubric, validation flow, and trial defaults.
3. Klavis separately provides local subscription-auth sample commands using the Docker backend. This repository uses Docker for local reproduction because the current task fits within 1 CPU / 2 GiB and the user does not have TB3's repository Modal secrets.

The Klavis deliverable is a standalone GitHub repository; an upstream Terminal-Bench PR is not required.

## Live upstream snapshot

| Item | Current value |
|---|---|
| Upstream `main` | `79e71650f5b6a6ef5bb46a434c7c04d7d99a9480` |
| Date/time of upstream head | 2026-08-27 14:29:11 UTC |
| Latest head change | Raise task timeout cap to eight hours (#1801) |
| `/run` + `/cheat` Harbor | `0.14.0` |
| `/validate` / rubric-review Harbor | current workflow uses `0.18.0` where configured |

## Current trial configuration

Live `.github/harbor-run-defaults.yml` supplies the required agents and the standard-run trial count:

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
| Analysis model | `sonnet` |

The standard `/run` workflow expands the configured `trials: 3` into a `(task × agent × trial)` matrix. The live `/cheat` workflow does **not** include a trial dimension; it runs a `(task × agent)` matrix once per configured agent. Therefore the final required model evidence target is **8 runs total**: 3 Codex standard + 3 Claude standard + 1 Codex cheat + 1 Claude cheat.

## Docker vs current upstream Modal default

Upstream currently chooses `env: modal` for `/run`, `/cheat`, and `/validate` because many benchmark tasks exceed GitHub-hosted runner resources. Both trial workflows still have explicit Docker execution paths, and command overrides can choose the backend.

Klavis's own local examples use:

```text
--env docker
```

with subscription authentication. The hiring assignment specifically identifies the current agent/model configuration and trial behavior as authoritative while giving Docker as the local execution route. The current task requests only 1 CPU / 2 GiB RAM / 10 GiB storage, so local Docker does not weaken its computational environment.

For transparency, final documentation should state that recorded candidate trials were local Harbor 0.14.0 Docker reproductions using the exact required agent/model/reasoning settings, rather than claiming they were executed by upstream TB3's Modal CI.

## Current timeout rule

Upstream head `79e71650...` raised the task timeout cap to **8 hours**. The current task uses:

```text
agent timeout:    14400s (4h)
verifier timeout: 900s
```

which remains within the live cap.

## Validation compatibility

Upstream validation and trial workflows currently use different Harbor generations. Local deadline qualification keeps Harbor 0.14.0 as the candidate-trial authority because that is what live `/run` and `/cheat` install. Earlier development also checked Oracle/NOP compatibility under newer Harbor where possible.

For the final frozen tree, the minimum recorded validation evidence should include:

- live static checks from upstream HEAD;
- full Oracle/reference success;
- NOP reward 0;
- Docker image build success;
- the current mutation matrix;
- exact Harbor and TB3 SHAs.

## Implementation rubric

Current upstream implementation review is a model-driven `harbor exec` reviewer against `docs/prompts/task-implementation.toml`, not part of the shell static checks. Upstream CI supplies `ANTHROPIC_API_KEY`, so this repository's `results/implementation-rubric-review.md` remains a self-audit until the reviewer is reproduced successfully.

A Bedrock reproduction runner is prepared at:

```text
scripts/run-implementation-rubric-bedrock.sh
```

If zero-cost Bedrock access works, it can run the same Claude Code `sonnet` reviewer with Harbor 0.18.0 without a paid Claude subscription or Anthropic API key.

Current live rubric risks identified for this candidate:

- instruction length/concision;
- optional task-local README duplicates substantial instruction/solution material;
- instruction should include a brief real-world-role sentence;
- avoid wording that unnecessarily prescribes a specific locking implementation rather than observable transactional outcomes.

A non-applied cleanup transformation is prepared at `scripts/apply-deadline-rubric-cleanup.sh`. It must not be applied until interrupted same-tree frontier evidence is inspected.

## Current static/verifier requirements relevant to this task

- Separate verifier mode with only declared artifacts transferred from the agent container.
- Hidden tests/reference truth and reward state remain verifier-owned.
- Verifier dependencies are baked into `tests/Dockerfile`; `test.sh` does not install from the network.
- Candidate behavior is graded through execution rather than source keyword matching.
- Reward is binary.
- Current static checks cover canary, absolute paths, canonical timeout trailer, task fields/taxonomy, Docker sanity/platform, separate verifier, pinned verifier tooling, package name/slug, internet policy, and process/resource sanity.
- Current implementation rubric emphasizes deterministic verification, professional realism, outcome-based testing, reviewer readability, instruction concision, and anti-cheat isolation.

## Claude access

Klavis's preferred no-API-price local route is Claude Code OAuth from `claude setup-token`; that requires an eligible paid Claude subscription and is unavailable here.

Claude Code and Harbor 0.14.0 both support Amazon Bedrock. Harbor detects Bedrock mode from `CLAUDE_CODE_USE_BEDROCK=1` / AWS credentials and converts the Harbor model name `anthropic/claude-opus-5` to Claude Code's recognized version name `claude-opus-5`. Claude Code then resolves that version to the matching Bedrock inference profile/model (for example `us.anthropic.claude-opus-5` in a US region). AWS documents the underlying Opus 5 Bedrock model ID as `anthropic.claude-opus-5`.

Prepared zero-spend runners:

```text
scripts/run-claude-bedrock-trial.sh
scripts/run-deadline-claude-bedrock-matrix.sh
```

The AWS Free Tier/credit route will be tested only if the free account actually permits Anthropic model entitlement; no paid upgrade is allowed.

## Final freshness rule

Immediately before final submission, re-fetch and record:

- Terminal-Bench `main` SHA;
- `.github/harbor-run-defaults.yml`;
- `.github/workflows/run-trials.yml`;
- `.github/workflows/run-cheat-trials.yml`;
- `.github/workflows/validate-task.yml`;
- `docs/prompts/task-implementation.toml`.

Any changed model, trial count, Harbor version, backend behavior, timeout rule, or rubric requirement supersedes this snapshot.
