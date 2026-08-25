# Instruction-to-Test Coverage

This matrix is maintained against `tasks/build-snapshot-publish/instruction.md`. The reference workspace is independent of the candidate workspace in every test that compares output bytes.

| Instruction requirement | Test(s) | Negative/mutation evidence | Covered? |
|---|---|---|---|
| Public `build --project --target --report` command remains usable | every verifier test | starter and every candidate mutation invoke the same CLI | yes |
| Recursive `@include` expansion | `test_initial_repeat_and_report_contract`, `test_transitive_edit_and_new_include_rebuild_affected_closure` | starter and incomplete-closure behavior fail dependency/output assertions | yes |
| `concat` and `sha256` target semantics | every report/output assertion | independent `reference.py` derives expected bytes | yes |
| Outputs are project-relative paths beneath `out/`; report paths and SHA-256 fields are correct | `_assert_report` in every successful-build test | `no-selector`, `trust-object`, and `publish-in-place` mutants fail physical/output checks | yes |
| Dependency-order events and sorted dependencies | `_assert_report`; initial report | event order and dependency assertions are checked independently of candidate source shape | yes |
| Clean output matches a deterministic build | every successful-build test | reference workspace is separate and cache-free | yes |
| Unchanged repeat reuses valid work | `test_initial_repeat_and_report_contract` | `always-rebuild` rejected | yes |
| Direct and transitive edits rebuild only affected closure | `test_transitive_edit_and_new_include_rebuild_affected_closure` | `ignore-upstream` rejected | yes |
| Newly introduced includes are discovered | second half of `test_transitive_edit_and_new_include_rebuild_affected_closure` | starter/incomplete closure behavior fails dependency/output checks | yes |
| Unrelated input stays cached | `test_unrelated_input_and_target_definition_invalidate_selectively` | `always-rebuild` rejected | yes |
| Target definition participates in cache identity | second half of `test_unrelated_input_and_target_definition_invalidate_selectively` | `ignore-definition` rejected | yes |
| Required-target output identity propagates | transitive-edit and corruption tests | `ignore-upstream` rejected | yes |
| Missing/corrupt cache object recovery | first half of `test_cache_object_and_materialized_output_recovery` | `trust-object` rejected | yes |
| Missing/corrupt materialized output recovery | second half of `test_cache_object_and_materialized_output_recovery` | `trust-object` and `no-selector` rejected | yes |
| Interrupted publication exposes only a complete old or new snapshot | `test_interrupted_publication_exposes_only_complete_snapshot`; all four target cases in `test_failpoint_occurs_after_named_target_progress` | starter and `publish-in-place` rejected | yes |
| `after-target:TARGET` fires only after the named target has produced its new result | all four target cases in `test_failpoint_occurs_after_named_target_progress` | `failpoint-shortcut` rejected | yes |
| Interrupted staging is recoverable on the next ordinary build | both interruption test families' post-interruption build | starter exposes mixed output; generation solution converges to the new complete snapshot | yes |
| Do not hard-code the visible project | independent reference workspace plus source/manifest mutations | mutation suite changes inputs and definitions without changing candidate code | yes |
