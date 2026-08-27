from __future__ import annotations

from pathlib import Path
from typing import Any

from .engine import BuildError


def capture_workspace(
    workspace: str | Path,
    plan: str | Path,
    request_id: str,
) -> dict[str, Any]:
    """Publish one exactly-once cross-project workspace snapshot."""
    raise BuildError("workspace snapshot capture is not implemented")


def read_workspace_snapshot(
    workspace: str | Path,
    member: str,
    output: str,
    hold_dir: str | Path,
    dest: str | Path,
) -> None:
    """Read one member output from a pinned workspace snapshot."""
    raise BuildError("workspace snapshot reads are not implemented")


def collect_workspace_garbage(workspace: str | Path, keep: int) -> dict[str, Any]:
    """Reclaim obsolete workspace snapshots."""
    raise BuildError("workspace garbage collection is not implemented")
