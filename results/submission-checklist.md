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

## Codex evidence

- [ ] Standard trial 1 finishes.
- [ ] Trial 1 authoritative Harbor result audited.
- [ ] Trial 1 confirmed free of provider/auth/quota/container/timeout/verifier contamination.
- [ ] Trial 1 reward and failed tests classified as genuine candidate behavior before counting.
- [ ] Standard trial 2 completed and audited.
- [ ] Standard trial 3 completed and audited.
- [ ] `results/standard-trials.md` updated with exact evidence paths and results.
- [ ] `results/failure-analysis.md` updated with per-trial analysis.
- [ ] Codex `/cheat` completed under pinned TB3 adversarial semantics.
- [ ] `results/cheat-trials.md` updated with exact adversarial evidence/provenance.

## Claude-dependent requirements

Full TB3 compliance additionally requires:

- [ ] Automated implementation-rubric review: complete criterion set, zero failed criteria, exact frozen tree.
- [ ] Claude Code / Opus 5 / `max` standard trial 1.
- [ ] Claude Code / Opus 5 / `max` standard trial 2.
- [ ] Claude Code / Opus 5 / `max` standard trial 3.
- [ ] Claude Code / Opus 5 / `max` `/cheat` entry with reward 0.

If provider access remains unavailable, these boxes stay unchecked and the submission email must state that limitation plainly. Do not mark `FINAL_STATUS=READY_FOR_SUBMISSION` in that state.

## Repository delivery

- [ ] Confirm `git rev-parse HEAD:tasks/build-snapshot-publish` is exactly `d862ab3cc79718e959e9cc7ec1b792540990a24d` after the final documentation commit.
- [ ] Confirm no task files are dirty locally.
- [ ] Confirm `main` contains every final evidence/documentation update.
- [ ] Confirm latest `Submission Consistency` workflow succeeds.
- [ ] Re-fetch Terminal-Bench `main` immediately before sending and compare required defaults/workflows.
- [ ] Run `bash scripts/final-submission-audit.sh`; preserve its truthful status.
- [ ] Confirm the reviewer can access the GitHub repository. The repository is currently private, so either reviewer access must be granted or visibility must be changed before sending the URL.
- [ ] Open the repository URL in a logged-out/private browser session if it is intended to be publicly accessible.

## Submission email

The final email should:

- include the repository URL;
- apologize briefly for the late/incomplete provider-dependent portion without overexplaining;
- state what was completed and validated;
- state exactly which Claude-dependent requirements could not be executed if they remain incomplete;
- avoid claiming full TB3 compliance if the strict audit does not report ready;
- offer to complete the missing Claude validation promptly if approved access is provided or a follow-up is permitted.

## Final stop conditions

Do not send until all immediately controllable items above are complete. Do not alter the task merely to make a status page look complete. Evidence accuracy takes precedence over cosmetic completeness.