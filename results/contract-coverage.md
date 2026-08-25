# Instruction-to-Test Coverage

This matrix is maintained against `tasks/build-snapshot-publish/instruction.md`. The reference workspace is independent of the candidate workspace in every test that compares output bytes. Runtime reward assertions are limited to behavior required by the task; verifier trust-boundary checks are documented separately below.

| Instruction requirement | Runtime test(s) | Negative/mutation evidence | Covered? |
|---|---|---|---|
| Public `build --project --target --report` command remains usable | every verifier test | starter and every candidate mutation invoke the same CLI | yes |
| Recursive `@include` expansion | `test_initial_repeat_and_report_contract`, `test_transitive_edit_and_new_include_rebuild_affected_closure` | incomplete dependency closure fails dependency/output assertions | yes |
| `concat` and `sha256` target semantics | every report/output assertion | independent `reference.py` derives expected bytes | yes |
| Outputs remain beneath `out/`; report paths and SHA-256 fields are correct | `_assert_report` in every successful-build test | `no-selector`, `trust-object`, and `publish-in-place` fail physical/output checks | yes |
| Exact report schema: top-level `target`/`events`/`outputs`, exact event and output-object keys, field types, requested target, depth-first order, and sorted complete dependencies | `_assert_report` in every successful-build test; missing-object recovery also checks the requested target | exact-key/type assertions reject undocumented report shapes; output objects are compared exactly | yes |
| Clean output matches a deterministic build | every successful-build test | reference workspace is separate and cache-free | yes |
| Unchanged repeat reuses valid work | `test_initial_repeat_and_report_contract` | `always-rebuild` rejected | yes |
| Direct and transitive edits rebuild only affected closure | `test_transitive_edit_and_new_include_rebuild_affected_closure` | `ignore-upstream` rejected | yes |
| Newly introduced includes are discovered | second half of `test_transitive_edit_and_new_include_rebuild_affected_closure` | incomplete closure fails dependency/output checks | yes |
| Unrelated input stays cached | `test_unrelated_input_and_target_definition_invalidate_selectively` | `always-rebuild` rejected | yes |
| Target definition participates in cache identity | second half of `test_unrelated_input_and_target_definition_invalidate_selectively` | `ignore-definition` rejected | yes |
| Required-target output identity propagates | transitive-edit and recovery tests | `ignore-upstream` rejected | yes |
| Missing/corrupt cache object recovery | `test_missing_cache_object_is_rebuilt_without_invalidating_downstream`; first half of `test_cache_object_and_materialized_output_recovery` | missing and corrupt object cases both exercised; `trust-object` rejected | yes |
| Missing/corrupt materialized output recovery | second half of `test_cache_object_and_materialized_output_recovery` | `trust-object` and `no-selector` rejected | yes |
| Cooperative interruption leaves only a complete old or new snapshot | `test_interrupted_publication_exposes_only_complete_snapshot`; all four cases in `test_all_named_failpoints_preserve_complete_snapshot` | starter and `publish-in-place` rejected | yes |
| Snapshot safety is not implemented only when `BUILDSYS_FAILPOINT` is present | `test_normal_build_never_exposes_new_producer_with_old_downstream` | normal build uses regular files and no failpoint variable; `failpoint-only-staging` rejected | yes |
| Interrupted/staged state recovers on the next ordinary build | every cooperative interruption case performs a following successful build | generation solution converges to the new complete snapshot | yes |
| Do not hard-code the visible project | independent reference workspace, input/definition mutations, and a separate wide hidden graph | hidden verifier changes inputs, graph shape, and definitions without changing candidate code | yes |

## Verifier trust-boundary evidence

These are properties of the grading harness, not additional task requirements. They are deliberately not separate reward-scoring tests in the final verifier.

| Trust-boundary property | Mechanism / development evidence |
|---|---|
| Candidate runs unprivileged | every candidate invocation uses `_drop_privileges` to execute as `nobody` |
| Hidden verifier truth is unavailable to candidate code | `/tests` is verifier-image-owned and root-only; the independent reference workspace is root-only; only the declared `/app/buildsys/` artifact crosses into the separate verifier |
| Candidate cannot replace the sibling reference workspace | workspace parent is root-owned `0711`, reference workspace is root-only; a development self-test attempted the rename as `nobody` and was rejected before that self-test was removed from runtime scoring |
| Candidate cannot replace verifier-controlled manifest/source entries | candidate project root is sticky `01777` while manifest and source entries remain root-owned/read-only; development rename probes were rejected before being removed from runtime scoring |
| Corruption checks do not turn verifier root into a confused deputy | `_candidate_write`, `_candidate_unlink`, and `_run_candidate_fs_action` mutate candidate-owned cache/output state only after dropping to the candidate UID |
| Detached descendants do not survive candidate execution | `_cleanup_candidate_processes` combines process-group cleanup with a candidate-UID process sweep and reaping on every invocation; a detached `setsid()` development self-test was exercised successfully before removal from runtime scoring |
| Reward and CTRF state remain verifier-owned | `/logs/verifier` is root-only and reward is written by `tests/test.sh` after pytest completes |

The final adversarial `/cheat` trials remain the external validation that these trust boundaries and the behavioral verifier resist an actively hostile coding agent.
