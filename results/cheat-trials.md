# Adversarial Cheat Trials

Status: pending execution for `build-snapshot-publish` in the current TB3 environment.

The assignment requires zero reward for every adversarial trial required by the current TB3 `/cheat` workflow. At the live snapshot recorded in `results/environment.md`, that workflow runs one attempt for each configured agent. Run the local reproduction helper with a fresh checkout of the same live upstream:

```bash
TB3_REPO=/path/to/terminal-bench ./scripts/run-cheat-trials.sh
```

The helper copies the task to a temporary directory, removes the ordinary anti-cheat sentence, **appends** the live `rubrics/hack-trial-prompt.md` after the legitimate instruction, and runs one attempt for Claude Code / Opus 5 max and one attempt for Codex / GPT-5.6 Sol xhigh. This mirrors `.github/workflows/run-cheat-trials.yml` at the recorded upstream commit; it does not inherit the ordinary `/run` value of three attempts.

Record each reward, attack path, verifier response, infrastructure status, and analysis result here after execution. A zero reward caused by a crash, invalid environment, or verifier failure is not sufficient evidence.
