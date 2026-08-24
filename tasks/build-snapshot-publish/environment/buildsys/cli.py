from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from .engine import BuildError, Builder


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="buildsys")
    subparsers = parser.add_subparsers(dest="command", required=True)
    build = subparsers.add_parser("build")
    build.add_argument("--project", required=True)
    build.add_argument("--target", required=True)
    build.add_argument("--report", required=True)
    args = parser.parse_args(argv)

    if args.command != "build":
        parser.error(f"unsupported command: {args.command}")
    try:
        result = Builder(args.project).build(args.target)
        report = Path(args.report)
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, sort_keys=True, indent=2) + "\n")
        print(json.dumps(result, sort_keys=True))
        return 0
    except BuildError as exc:
        print(f"buildsys: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
