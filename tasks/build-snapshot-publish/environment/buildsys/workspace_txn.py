from __future__ import annotations

from pathlib import Path
from typing import Any

from .engine import BuildError


def build_workspace(
    workspace: str | Path,
    plan: str | Path,
    request_id: str,
) -> dict[str, Any]:
    """Build and publish an optimistic multi-project workspace transaction."""
    raise BuildError("workspace build transactions are not implemented")
