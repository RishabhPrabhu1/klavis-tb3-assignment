# Wrong vs. Correct Abstraction

## Wrong abstraction

The build state is the union of independently valid files:

```text
latest object for target A
latest record for target A
latest output for target A
latest object for target B
latest record for target B
latest output for target B
```

Each write can be atomic while the collection is still inconsistent. A process interruption after one target is materialized can expose a new producer output beside an old downstream output. A later cache lookup may also trust a record that belongs to a different publication attempt.

## Correct abstraction

A build result is an immutable generation. The generation contains the complete target snapshot and references immutable objects. One atomic selector identifies the visible generation. Readers resolve that selector once; builders write only to an unreachable staging generation until every required target and record is ready.

The selector is the commit boundary. A crash before the selector switch leaves the previous generation visible. A crash after the switch is allowed only when the new generation is complete. Orphaned staging data is garbage, not visible build state.

## Observable distinction

For a graph where `package` consumes `app` and `docs`, an interrupted rebuild may produce either:

```text
old app + old docs + old package + old fingerprint
new app + new docs + new package + new fingerprint
```

It must never produce `new app + old package`, a missing required output, or a report whose cache decisions refer to a different visible generation.

The distinction is deterministic: the verifier computes the old and new complete snapshots independently and checks every observed output set against those snapshots after each controlled interruption.
