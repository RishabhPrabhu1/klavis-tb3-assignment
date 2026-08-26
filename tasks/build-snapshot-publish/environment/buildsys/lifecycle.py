from __future__ import annotations

from pathlib import Path
from typing import Any

from .engine import BuildError


def read_snapshot(
    project: str | Path,
    output: str,
    hold_dir: str | Path,
    dest: str | Path,
) -> None:
    """Read one pinned published snapshot while allowing concurrent builds and GC."""
    raise BuildError("snapshot reads are not implemented")


def collect_garbage(project: str | Path, keep: int) -> dict[str, Any]:
    """Reclaim obsolete committed generations and unreachable cache objects."""
    raise BuildError("garbage collection is not implemented")
