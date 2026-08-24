# Oracle Plan — Build Snapshot Publication

## Public behavior

Keep the build command shape and target graph small enough to explore:

```text
python3 -m buildsys.cli build --project PROJECT --target TARGET --report REPORT
```

The environment also exposes deterministic test hooks that stop a build after a named publication boundary. They model a process interruption; they are not a second solution API.

## Starter

The starter will retain correct target evaluation, content-addressed object validation, ordinary cache reuse, and direct dependency propagation. It will publish target outputs and records directly into the current output namespace. A controlled interruption between target publications can therefore expose a mixed graph generation.

The starter must not contain an unused return value, TODO, comment, or helper name that states the repair. Its failure should be visible only by running repeated builds with an interrupted publication and reading the complete output set.

## Reference repair

The oracle will:

1. read the selected committed generation;
2. evaluate changed targets and reuse valid immutable objects for unchanged targets;
3. write a complete new generation in a private staging directory;
4. validate the staged target records, object digests, dependency outputs, and materialized files;
5. atomically replace one `CURRENT` selector;
6. materialize or read outputs through the selected generation;
7. discard or ignore incomplete staging generations on the next invocation.

The intended implementation is an architectural state transition across the cache and output namespace, not a patch to one dependency list. The oracle should remain under roughly 300 meaningful changed lines after the starter is finalized.

## Kill test

If the first oracle can be expressed as a local reorder of two writes, or if the verifier cannot distinguish a mixed output set from a valid old/new snapshot without timing sleeps, reject this design and move to `cas-lease-gc`.
