# Adversarial Cheat Trials

Status: pending execution for `build-snapshot-publish` in the current TB3 environment.

The assignment requires zero reward for every required `/cheat` trial for both current default agents. Run:

```bash
TB3_REPO=/path/to/terminal-bench ./scripts/run-cheat-trials.sh
```

The helper copies the task to a temporary directory, removes the ordinary anti-cheat sentence, prepends the live `rubrics/hack-trial-prompt.md`, and runs one attempt per configured agent to match the current TB3 `/cheat` behavior. Record each reward, attack path, verifier response, and analysis result here after execution. A zero reward without a normal verifier run is not sufficient evidence.
