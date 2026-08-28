# Final Submission Checklist

This checklist is operational. It does not change the task contract or weaken the repository's strict readiness audit.

## Frozen identities

```text
task tree:      d862ab3cc79718e959e9cc7ec1b792540990a24d
Terminal-Bench: 79e71650f5b6a6ef5bb46a434c7c04d7d99a9480
```

Any change under `tasks/build-snapshot-publish/` changes the task tree and invalidates same-tree model evidence.

## Already complete

- [x] Current Terminal-Bench static checks pass.
- [x] Exact-tree reference verifier passes `68/68`.
- [x] Harbor 0.14 Oracle = `1.000`.
- [x] Harbor 0.14 NOP = `0.000`.
- [x] Exact-tree deterministic qualification contains zero frontier-model calls.
- [x] Fully-qualified predecessor rejected `40/40` development mutation controls.
- [x] Reviewer-facing current-state documentation identifies the frozen tree.
- [x] Repository consistency CI passes after documentation cleanup.
- [x] Live Terminal-Bench head rechecked on 2026-08-27 and remains `79e71650...`.
- [x] Live model identities/trial counts rechecked: 3 Codex standard, 3 Claude standard, 1 Codex cheat, 1 Claude cheat.
- [x] Common committed credential patterns were checked; no AWS access-key/secret or Anthropic API-key value was found.
- [x] `.gitignore` excludes local `.env`, key, credential, secret, log, cache, Harbor job, and agent-state files.
- [x] Claude provider limitation is explicitly documented in README and reviewer-facing result files.

## Codex evidence

- [x] Standard trial 1 finished.
- [x] Trial 1 authoritative Harbor result audited.
- [x] Trial 1 confirmed free of provider/auth/quota/container/timeout/verifier contamination.
- [x] Trial 1 reward and failed tests classified as genuine candidate behavior.
- [x] Trial 1 recorded in `results/standard-trials.md` and `results/failure-analysis.md`.
- [ ] Standard trial 2 completed and audited.
- [ ] Standard trial 3 completed and audited.
- [ ] Final Codex standard ledger updated with all three exact evidence paths/results.
- [ ] Final Codex failure analysis updated with all three per-trial analyses.
- [ ] Codex `/cheat` completed under pinned TB3 adversarial semantics.
- [ ] `results/cheat-trials.md` updated with exact Codex adversarial evidence/provenance.

Current Codex standard status: **1/3 counted**.

## Claude-dependent requirements — intentionally incomplete

Full TB3 compliance additionally requires:

- [ ] Automated implementation-rubric review: complete criterion set, zero failed criteria, exact frozen tree.
- [ ] Claude Code / Opus 5 / `max` standard trial 1.
- [ ] Claude Code / Opus 5 / `max` standard trial 2.
- [ ] Claude Code / Opus 5 / `max` standard trial 3.
- [ ] Claude Code / Opus 5 / `max` `/cheat` entry with reward 0.

These boxes are expected to remain unchecked for this submission because the submission environment has **no Claude Code subscription and no usable Anthropic API or Bedrock route**. The missing entries are not provider failures and are not counted as model results. No alternate model is used to fill them.

The README, `results/environment.md`, `results/implementation-rubric-review.md`, `results/standard-trials.md`, and `results/cheat-trials.md` all disclose this limitation. Do not mark `FINAL_STATUS=READY_FOR_SUBMISSION` while these required items remain incomplete.

## Repository delivery

- [ ] Confirm `git rev-parse HEAD:tasks/build-snapshot-publish` is exactly `d862ab3cc79718e959e9cc7ec1b792540990a24d` after the final documentation commit.
- [ ] Confirm no task files are dirty locally.
- [ ] Confirm `main` contains every final evidence/documentation update.
- [ ] Confirm latest `Submission Consistency` workflow succeeds.
- [ ] Re-fetch Terminal-Bench `main` immediately before sending and compare required defaults/workflows.
- [ ] Run `bash scripts/final-submission-audit.sh`; preserve its truthful partial/not-ready status if Claude remains incomplete.
- [ ] Confirm the reviewer can access the GitHub repository. The repository is currently private, so either reviewer access must be granted or visibility must be changed before sending the URL.
- [ ] Open the repository URL in a logged-out/private browser session if it is intended to be publicly accessible.

## Submission email

The final email should:

- include the repository URL;
- apologize briefly for the late/incomplete provider-dependent portion without overexplaining;
- state what was completed and validated;
- state explicitly that no Claude Code subscription or other usable Claude provider route was available;
- identify the missing automated rubric, three Claude standard trials, and Claude `/cheat` result;
- avoid claiming full TB3 compliance if the strict audit does not report ready;
- make clear that no substitute model or provider failure was counted as Claude evidence;
- offer to complete the missing Claude validation if an approved access route or follow-up is provided.

## Final stop conditions

Do not send until all immediately controllable Codex and repository-delivery items above are complete. Do not alter the task merely to make a status page look complete. Evidence accuracy takes precedence over cosmetic completeness.