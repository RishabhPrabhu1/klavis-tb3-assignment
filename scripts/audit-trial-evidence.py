#!/usr/bin/env python3
"""Reclassify Harbor trial summaries from result.json exception state.

The shell runners intentionally keep their console parsing simple. This auditor is
the qualification authority for whether a completed Harbor invocation is a valid
model trial: any non-null Harbor result.json exception_info invalidates the trial,
even when the Harbor process exits 0 and a verifier reward is present.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def _meaningful(value: Any) -> bool:
    return value not in (None, {}, [], "")


def audit_summary(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    run_dir = path.parent
    result_paths = sorted((run_dir / "harbor-output").rglob("result.json"))

    trial_results: list[tuple[Path, dict[str, Any]]] = []
    parse_errors: list[str] = []
    for result_path in result_paths:
        try:
            result = json.loads(result_path.read_text(encoding="utf-8"))
        except Exception as exc:  # evidence corruption must not be treated as valid
            parse_errors.append(f"{result_path}: {type(exc).__name__}: {exc}")
            continue
        if isinstance(result, dict) and (
            "verifier_result" in result or "exception_info" in result
        ):
            trial_results.append((result_path, result))

    result_exceptions: list[dict[str, Any]] = []
    for result_path, result in trial_results:
        exc = result.get("exception_info")
        if _meaningful(exc):
            result_exceptions.append(
                {
                    "result_json": str(result_path),
                    "exception_info": exc,
                }
            )

    old_execution = data.get("execution_class")
    harbor_status = data.get("harbor_exit_status")
    reward = data.get("reward")

    if parse_errors:
        execution = "result-json-parse-error"
    elif not trial_results:
        execution = "result-json-missing-or-unparseable"
    elif result_exceptions:
        execution = "completed-with-exceptions"
    elif harbor_status not in (None, 0):
        execution = "infrastructure-or-run-error"
    elif reward is None:
        execution = "completed-but-reward-unparsed"
    else:
        execution = "valid-completed-trial"

    exception_types: list[str] = []
    for item in result_exceptions:
        exc = item["exception_info"]
        if isinstance(exc, dict):
            typ = exc.get("exception_type") or exc.get("type")
            if typ:
                exception_types.append(str(typ))
        else:
            exception_types.append(type(exc).__name__)

    data["execution_class_before_evidence_audit"] = old_execution
    data["execution_class"] = execution
    data["evidence_audited"] = True
    data["result_json_parse_errors"] = parse_errors
    data["result_exceptions"] = result_exceptions
    data["result_exception_types"] = sorted(set(exception_types))
    data["trial_result_files"] = [str(p) for p, _ in trial_results]
    data["qualification_valid"] = execution == "valid-completed-trial"

    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

    audit_path = run_dir / "evidence-audit.json"
    audit_payload = {
        "summary_json": str(path),
        "execution_class_before": old_execution,
        "execution_class_after": execution,
        "qualification_valid": data["qualification_valid"],
        "result_exception_types": data["result_exception_types"],
        "result_exceptions": result_exceptions,
        "result_json_parse_errors": parse_errors,
        "trial_result_files": data["trial_result_files"],
    }
    audit_path.write_text(json.dumps(audit_payload, indent=2) + "\n", encoding="utf-8")
    return audit_payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "paths",
        nargs="+",
        help="Run directory, summary.json, or evidence root to audit recursively.",
    )
    args = parser.parse_args()

    summaries: set[Path] = set()
    for raw in args.paths:
        target = Path(raw).expanduser()
        if target.is_file() and target.name == "summary.json":
            summaries.add(target)
        elif target.is_dir():
            direct = target / "summary.json"
            if direct.is_file():
                summaries.add(direct)
            summaries.update(target.rglob("summary.json"))

    if not summaries:
        print("No summary.json files found; nothing audited.")
        return 0

    for summary in sorted(summaries):
        try:
            audit = audit_summary(summary)
        except Exception as exc:
            print(f"AUDIT ERROR {summary}: {type(exc).__name__}: {exc}")
            return 2
        status = "VALID" if audit["qualification_valid"] else "INVALID"
        types = ",".join(audit["result_exception_types"]) or "none"
        print(
            f"{status} {summary} execution={audit['execution_class_after']} "
            f"result_exceptions={types}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
