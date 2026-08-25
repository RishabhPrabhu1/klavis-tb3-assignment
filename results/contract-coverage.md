# Instruction-to-Test Coverage

This matrix is maintained against `tasks/build-snapshot-publish/instruction.md`. The reference workspace is independent of the candidate workspace in every test that compares output bytes.

| Instruction requirement | Test(s) | Negative/mutation evidence | Covered? |
|---|---|---|---|
| Public `build --project --target --report` command remains usable | every verifier test | starter and every candidate mutation invoke the same CLI | yes |
| Recursive `@include` expansion | `test_initial_repeat_and_report_contract`, `test_transitive_edit_and_new_include_rebuild_affected_closure` | incomplete dependency closure fails dependency/output assertions | yes |
| `concat` and `sha256` target semantics | every report/output assertion | independent `reference.py` derives expected bytes | yes |
| Outputs remain beneath `out/`; report paths and SHA-256 fields are correct | `_assert_report` in every successful-build test | `no-selector`, `trust-object`, and `publish-in-place` mutants fail physical/output checks | yes |
| Dependency-order events and sorted dependencies | `_assert_report`; initial report | event order and dependency assertions are checked independently of candidate source shape | yes |
| Clean output matches a deterministic build | every successful-build test | reference workspace is separate and cache-free | yes |
| Unchanged repeat reuses valid work | `test_initial_repeat_and_report_contract` | `always-rebuild` rejected | yes |
| Direct and transitive edits rebuild only affected closure | `test_transitive_edit_and_new_include_rebuild_affected_closure` | `ignore-upstream` rejected | yes |
| Newly introduced includes are discovered | second half of `test_transitive_edit_and_new_include_rebuild_affected_closure` | incomplete closure fails dependency/output checks | yes |
| Unrelated input stays cached | `test_unrelated_input_and_target_definition_invalidate_selectively` | `always-rebuild` rejected | yes |
| Target definition participates in cache identity | second half of `test_unrelated_input_and_target_definition_invalidate_selectively` | `ignore-definition` rejected | yes |
| Required-target output identity propagates | transitive-edit and corruption tests | `ignore-upstream` rejected | yes |
| Missing/corrupt cache object recovery | first half of `test_cache_object_and_materialized_output_recovery` | `trust-object` rejected; corruption is performed with candidate privileges rather than verifier-root writes | yes |
| Missing/corrupt materialized output recovery | second half of `test_cache_object_and_materialized_output_recovery` | `trust-object` and `no-selector` rejected; mutations run with candidate privileges | yes |
| Cooperative interruption leaves only a complete old or new snapshot | `test_interrupted_publication_exposes_only_complete_snapshot`; all four cases in `test_all_named_failpoints_preserve_complete_snapshot` | starter and `publish-in-place` rejected | yes |
| Snapshot safety is not implemented only when `BUILDSYS_FAILPOINT` is present | `test_normal_build_never_exposes_new_producer_with_old_downstream` | verifier uses only normal regular files and no failpoint variable; `failpoint-only-staging` is rejected | yes |
| Interrupted/staged state is recoverable on the next ordinary build | every cooperative interruption case performs a following successful build | generation solution converges to the new complete snapshot | yes |
| Candidate code cannot survive verification by detaching from its original process group | `test_cleanup_kills_detached_candidate_process` plus `_cleanup_candidate_processes` on every invocation | verifier records the pre-run `nobody` UID process set and kills every new candidate-UID process, including `setsid()` escapees | yes (Linux verifier image) |
| Candidate code cannot replace the root-only sibling reference workspace | `test_candidate_cannot_replace_reference_workspace_entry`; workspace pair uses a root-owned `0711` parent | a `nobody` subprocess attempts to rename the reference directory and must receive `EACCES`/`EPERM` | yes (Linux verifier image) |
| Candidate code cannot plant source/manifest symlinks for later verifier-root mutations | `test_candidate_cannot_replace_verifier_controlled_inputs`; candidate project root is sticky `01777`, while source tree and manifest are root-owned/read-only | `nobody` attempts to rename both top-level source and manifest entries and must receive `EACCES`/`EPERM` | yes (Linux verifier image) |
| Verifier corruption tests cannot become a root confused deputy through candidate-owned output/cache paths | `_candidate_write`, `_candidate_unlink`, `_run_candidate_fs_action` | all candidate-owned state mutations execute after dropping to `nobody`; root only mutates protected verifier-owned source inputs | yes |
| Hidden verifier truth is isolated from candidate code | root-only `/tests`; root-only reference workspace; candidate subprocess drops to `nobody` | candidate receives only the declared `/app/buildsys/` artifact and writable generated-state namespaces | yes |
| Do not hard-code the visible project | independent reference workspace plus source/manifest mutations and a separate wide hidden graph | hidden verifier schedules change inputs, definitions, and graph shape without changing candidate code | yes |
