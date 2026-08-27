# Failure Analysis

## Current candidate

```text
85eb3be3ce69a625a06eab3e37c69badbab89779
```

This is the frozen rubric-corrected successor to the difficulty-proven `fc064cac...` task. It preserves the same starter and reference implementation and the same observable runtime challenge, while removing verifier/process assumptions found during review:

- workspace current is resolved semantically rather than through a fixed selector pathname;
- transaction post-publish replay is checked only after later replacement plus workspace/project GC and does not read private `request_report` state;
- ordinary project current is observed through the required public `read` interface rather than a transaction-specific metadata marker;
- directly inspected generation-record object references are an explicit documented schema;
- workspace candidate subprocesses use verifier-owned log files, isolated sessions, UID baselines, and bounded process-tree cleanup;
- host-only signal permission limits no longer contaminate local mutation failures, while authoritative root-verifier cleanup errors still fail;
- live-owner duplicate waiting behavior tested by the verifier is explicit in the contract;
- deferred replay validates observable member/output identity and requires only the documented positive `attempts` value, not an invented exact retry count.

Final deterministic qualification and frontier evidence must use this exact tree. Historical trials below are calibration evidence only.

## Standard-trial validity

A `/run` trial counts as a model failure only when all of the following hold:

```text
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
reward = 0
verifier completed normally
```

Authentication, provider/quota, timeout, container, Harbor, or other execution failures do not count as standard model failures.

For `/cheat`, the live TB3 workflow is reward-based: each task × agent adversarial run must have reward `0`; any nonzero reward fails the requirement. The live workflow records reward 0 when `harbor run` itself exits nonzero, so an adversarial safety refusal is not treated the same way as an invalid `/run` model failure.

## Failure categories

- `F1` — conceptual/architectural implementation failure.
- `F2` — localized implementation/debugging failure under an otherwise viable approach.
- `F3` — specification ambiguity or reasonable interpretation mismatch; repair the task.
- `F4` — verifier defect or hidden representation assumption; repair the verifier.
- `F5` — runtime/container/infrastructure failure.
- `F6` — auth/provider/model/tooling failure.
- `F7` — other invalid/non-difficulty evidence, including suspicious shortcut behavior.

Under deadline policy, a valid reward-0 caused by a genuine candidate implementation error under a clear contract is sufficient difficulty evidence; F3-F7 are not.

## Historical calibration

### Workspace snapshot design — solved

Task tree `17291a73dc954c66db0ef5cc6cf2f70fe1c85db4` produced a clean GPT-5.6 Sol/xhigh solve:

```text
reward = 1
58 passed / 0 failed
execution_class = valid-completed-trial
```

Classification: valid solve; task was strengthened.

### Optimistic transaction tree — hidden workspace selector

Task tree `40cbd34104e1f0a549be23b46ef70655b728cece` passed deterministic qualification, then Sol returned reward 0 with 61 passed / 5 failed. All five failures were caused by a verifier helper requiring `.workspace-cache/CURRENT`, while the contract did not prescribe that selector and the candidate used another representation.

Classification: F4 verifier defect; not difficulty evidence. Workspace current was changed to semantic `commit_seq` observation.

### Rubric-clean transaction tree — genuine Sol failure

Task tree:

```text
fc064cac2fb1241b68a98475dbc8ea04fbe579cc
```

Deterministic qualification:

```text
static checks:        PASS
Oracle/reference:     66/66
mutants rejected:     40/40
Harbor Oracle/NOP:    1 / 0
frontier calls in qualification: 0
```

GPT-5.6 Sol/xhigh standard probe:

```text
reward = 0
45 passed / 21 failed
execution_class = valid-completed-trial
qualification_valid = true
result_exception_types = []
runtime = 29m44s
```

The failures were broad rather than a single formatting issue: project publication, durable exactly-once recovery, reader/GC behavior, reclamation interleavings, interrupted-work recovery, and workspace transaction replay all remained incorrect. One transaction-replay assertion was later identified as depending on private verifier state, but the remaining failures independently establish that the runtime challenge is difficult enough.

Classification: **genuine model implementation failure for difficulty calibration**. No further difficulty strengthening is warranted. Because later rubric review found verifier/schema/process issues, this old-tree result is not part of the final required 3-trial matrix.

### Frozen rubric-corrected successor

Review of the calibration tree and intermediate successors identified hidden replay state, undocumented record schema, selector/metadata assumptions, incomplete workspace process isolation, an early replay that could repair durability before the intended GC test, and undocumented live-owner duplicate semantics. Tree `85eb3be3...` removes or documents those assumptions without changing starter/reference runtime code or weakening observable concurrency/crash/replay/GC requirements.

The last verifier-only adjustment removed an unnecessary `attempts == 1` assumption from deferred replay. The verifier now checks that `attempts` is the documented positive integer and that the replay identifies the stranded member generation and original `out/app.txt` SHA-256 after that generation itself has been reclaimed.

## Per-trial analysis template

```text
Agent / model / reasoning:
Execution commit:
Task tree:
Evidence directory:

Validity:
- execution_class:
- qualification_valid:
- result_exception_types:
- infrastructure/provider contamination:

Result:
- reward:
- passed / failed / skipped:
- failed tests:

Implementation:
- architecture attempted:
- substantive execution:
- suspicious shortcuts:

Failure analysis:
- primary category F1-F7:
- violated observable invariant:
- first incorrect assumption/state boundary:
- local patch vs broad redesign:
- specification ambiguity/verifier defect:

Decision:
- legitimate model failure:
- freeze candidate:
- invalid run:
```

## Freeze rule

For exact task tree `85eb3be3ce69a625a06eab3e37c69badbab89779`:

- any valid standard reward `1` means do not treat that tree as meeting the required failure matrix;
- valid standard reward `0` from a genuine candidate implementation error permits freezing under the deadline policy;
- F3/F4 requires a narrow task/verifier repair and requalification;
- F5/F6 is preserved as invalid evidence and does not count;
- final submission requires three valid standard failures for Sol/xhigh and three for Opus 5/max, plus one zero-reward adversarial run for each agent under the live TB3 `/cheat` behavior.
