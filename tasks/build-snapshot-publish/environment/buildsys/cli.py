from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from .engine import BuildError
from .lifecycle import collect_garbage, read_snapshot
from .request_protocol import build_request
from .workspace import capture_workspace, collect_workspace_garbage, read_workspace_snapshot
from .workspace_txn import build_workspace


def _write_json(path: str | Path, value: dict[str, object]) -> None:
    report = Path(path)
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(value, sort_keys=True, indent=2) + "\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="buildsys")
    subparsers = parser.add_subparsers(dest="command", required=True)

    build = subparsers.add_parser("build")
    build.add_argument("--project", required=True)
    build.add_argument("--target", required=True)
    build.add_argument("--report", required=True)
    build.add_argument("--request-id")

    read = subparsers.add_parser("read")
    read.add_argument("--project", required=True)
    read.add_argument("--output", required=True)
    read.add_argument("--hold-dir", required=True)
    read.add_argument("--dest", required=True)

    gc = subparsers.add_parser("gc")
    gc.add_argument("--project", required=True)
    gc.add_argument("--keep", required=True, type=int)
    gc.add_argument("--report", required=True)

    workspace_capture = subparsers.add_parser("workspace-capture")
    workspace_capture.add_argument("--workspace", required=True)
    workspace_capture.add_argument("--plan", required=True)
    workspace_capture.add_argument("--request-id", required=True)
    workspace_capture.add_argument("--report", required=True)

    workspace_build = subparsers.add_parser("workspace-build")
    workspace_build.add_argument("--workspace", required=True)
    workspace_build.add_argument("--plan", required=True)
    workspace_build.add_argument("--request-id", required=True)
    workspace_build.add_argument("--report", required=True)

    workspace_read = subparsers.add_parser("workspace-read")
    workspace_read.add_argument("--workspace", required=True)
    workspace_read.add_argument("--member", required=True)
    workspace_read.add_argument("--output", required=True)
    workspace_read.add_argument("--hold-dir", required=True)
    workspace_read.add_argument("--dest", required=True)

    workspace_gc = subparsers.add_parser("workspace-gc")
    workspace_gc.add_argument("--workspace", required=True)
    workspace_gc.add_argument("--keep", required=True, type=int)
    workspace_gc.add_argument("--report", required=True)

    args = parser.parse_args(argv)

    try:
        if args.command == "build":
            result = build_request(args.project, args.target, args.request_id)
            _write_json(args.report, result)
            print(json.dumps(result, sort_keys=True))
            return 0

        if args.command == "read":
            read_snapshot(args.project, args.output, args.hold_dir, args.dest)
            return 0

        if args.command == "gc":
            if args.keep < 0:
                raise BuildError("--keep must be nonnegative")
            result = collect_garbage(args.project, args.keep)
            _write_json(args.report, result)
            print(json.dumps(result, sort_keys=True))
            return 0

        if args.command == "workspace-capture":
            result = capture_workspace(args.workspace, args.plan, args.request_id)
            _write_json(args.report, result)
            print(json.dumps(result, sort_keys=True))
            return 0

        if args.command == "workspace-build":
            result = build_workspace(args.workspace, args.plan, args.request_id)
            _write_json(args.report, result)
            print(json.dumps(result, sort_keys=True))
            return 0

        if args.command == "workspace-read":
            read_workspace_snapshot(
                args.workspace,
                args.member,
                args.output,
                args.hold_dir,
                args.dest,
            )
            return 0

        if args.command == "workspace-gc":
            if args.keep < 0:
                raise BuildError("--keep must be nonnegative")
            result = collect_workspace_garbage(args.workspace, args.keep)
            _write_json(args.report, result)
            print(json.dumps(result, sort_keys=True))
            return 0

        parser.error(f"unsupported command: {args.command}")
    except BuildError as exc:
        print(f"buildsys: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
