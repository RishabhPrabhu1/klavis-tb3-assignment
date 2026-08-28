# Active Execution Plan — Deadline Mode

## Frozen candidate

```text
task tree: d862ab3cc79718e959e9cc7ec1b792540990a24d
```

Difficulty strengthening is finished. Do not change `tasks/build-snapshot-publish/` unless a concrete final-tree specification/verifier defect is demonstrated.

## Current hard status

```text
Static checks:                 PASS
Oracle/reference:              68/68
Harbor Oracle/NOP:             1/0
Predecessor mutation controls: 40/40 rejected
Frozen successor task delta:   tests/conftest.py teardown/reaping only
Frozen-tree frontier calls:    0
Automated implementation rubric: OUTSTANDING
```

The predecessor mutation evidence belongs to `301107828273e249fbd31ed34d86bf3fed7143a1`. The frozen successor reran current-tree static checks, all 68 reference tests, and exact-tree Harbor Oracle/NOP because its sole task delta is verifier teardown hygiene.

## Required final model matrix

```text
Standard /run:
  3 × codex       / openai/gpt-5.6-sol       / xhigh
  3 × claude-code / anthropic/claude-opus-5 / max

Adversarial /cheat:
  1 × codex       / openai/gpt-5.6-sol       / xhigh
  1 × claude-code / anthropic/claude-opus-5 / max
```

Standard runs must be genuine clean model failures. Provider/auth/quota/container/timeout/verifier failures do not count. `/cheat` follows the pinned live reward condition: every required adversarial entry must record reward 0 and any nonzero reward fails.

## Gate 1 — Deterministic qualification: COMPLETE

Existing frozen-tree evidence is recorded in `results/preflight-status.json`.

A fresh full reproduction, including all 40 mutation controls, is available via:

```bash
bash scripts/run-final-tree-deadline-qualification.sh
```

Do not rerun it merely to create another marker if the existing exact-tree evidence remains intact and the task tree has not changed.

## Gate 2 — Automated implementation rubric: NEXT

The source-level review is `BORDERLINE -> LIKELY PASS`, with no known concrete hidden-schema/process-isolation defect remaining. The empirical automated rubric is still required.

Preferred Klavis subscription OAuth route when available:

```bash
EXPECTED_TASK_TREE=d862ab3cc79718e959e9cc7ec1b792540990a24d \
EXPECTED_TB3_HEAD=79e71650f5b6a6ef5bb46a434c7c04d7d99a9480 \
CONFIRM_ZERO_COST_COVERAGE=1 \
bash scripts/run-implementation-rubric-oauth.sh
```

Bedrock is supported only if eligible coverage is separately confirmed. Do not silently fall back to a paid provider route.

Acceptance condition:

```text
exact task tree = d862ab3...
exact pinned TB3 revision
all live criteria present
failed criteria = 0
overall = PASS
```

## Gate 3 — First exact-tree Sol probe

Only after Gate 2 passes:

```bash
bash scripts/run-next-frontier-step.sh
```

That entry point verifies the same-tree qualification marker and automated rubric PASS before delegating to the guarded one-probe runner.

Decision rule:

- valid reward `0` caused by genuine candidate implementation behavior → accept as first final failure and freeze;
- reward `1` → final matrix requirement is not met; do not reinterpret it as failure;
- specification/verifier defect → repair narrowly, then completely requalify the changed task tree;
- provider/auth/quota/container/timeout/other execution error → preserve as invalid evidence and do not count or blindly retry.

## Gate 4 — Complete Codex standard matrix

After reviewing and accepting the first exact-tree reward-0 failure:

```bash
CONFIRM_FREEZE=1 bash scripts/run-deadline-sol-matrix.sh
```

The first accepted probe counts. The runner launches only enough additional valid failures to reach 3/3 and stops on solve or invalid execution.

## Gate 5 — Codex adversarial entry

```bash
CONFIRM_FREEZE=1 AGENT=codex TARGET_CHEATS=1 \
bash scripts/run-deadline-cheat-matrix.sh
```

Require reward 0 with exact pinned Terminal-Bench provenance.

## Gate 6 — Claude Code / Opus 5

Required identity:

```text
agent:     claude-code
model:     anthropic/claude-opus-5
reasoning: max
```

The prepared Claude pipeline can reuse an exact-tree rubric PASS, collect 3 valid standard failures, run the adversarial entry, and invoke the final audit:

```bash
CONFIRM_FREEZE=1 CONFIRM_ZERO_COST_COVERAGE=1 \
bash scripts/run-deadline-claude-pipeline.sh
```

Do not count provider/auth/quota failures as standard model failures.

## Gate 7 — Evidence update and final audit

After each final run, record exact execution commit, task tree, agent/model/reasoning, evidence directory, Harbor/result status, verifier counts, reward, exceptions, and failure classification in the relevant ledger.

Then run:

```bash
bash scripts/final-submission-audit.sh
```

Required end state:

```text
same-tree qualification:          PASS
same-tree implementation rubric:  PASS
Codex standard reward-0:           3/3 valid
Claude standard reward-0:          3/3 valid
Codex cheat reward-0:              1/1
Claude cheat reward-0:             1/1
FINAL_STATUS=READY_FOR_SUBMISSION
```

## Gate 8 — Repository delivery hygiene

Before sending the repository URL:

1. Confirm `git rev-parse HEAD:tasks/build-snapshot-publish` equals `d862ab3cc79718e959e9cc7ec1b792540990a24d`.
2. Confirm the task subtree is clean.
3. Confirm current-state docs do not name a superseded tree or 66-test verifier as current.
4. Confirm the default GitHub branch points to the final submission commit.
5. Recheck live Terminal-Bench defaults/rubric for freshness.
6. Leave at least a small upload/submission buffer before midnight.

## Historical calibration — not final evidence

`fc064cac2fb1241b68a98475dbc8ea04fbe579cc` passed its then-current 66/66 verifier and 40/40 mutation controls and produced a valid Sol/xhigh reward-0 with 45 passed / 21 failed. It proves the task family is difficult but cannot satisfy any final matrix slot because it is a different task tree.
