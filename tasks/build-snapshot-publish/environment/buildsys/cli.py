from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from .engine import BuildError, Builder
from .lifecycle import collect_garbage, read_snapshot


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

    read = subparsers.add_parser("read")
    read.add_argument("--project", required=True)
    read.add_argument("--output", required=True)
    read.add_argument("--hold-dir", required=True)
    read.add_argument("--dest", required=True)

    gc = subparsers.add_parser("gc")
    gc.add_argument("--project", required=True)
    gc.add_argument("--keep", required=True, type=int)
    gc.add_argument("--report", required=True)

    args = parser.parse_args(argv)

    try:
        if args.command == "build":
            result = Builder(args.project).build(args.target)
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

        parser.error(f"unsupported command: {args.command}")
    except BuildError as exc:
        print(f"buildsys: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
