# Buildsys example

Run:

```text
python3 -m buildsys.cli build --project /app/project --target fingerprint --report /app/build-report.json
```

The manifest is intentionally small. The `app` bundle includes a file which includes another file. The package target depends on both the application and documentation bundles.
