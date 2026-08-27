from __future__ import annotations

from pathlib import Path

from .engine import Builder


def build_request(project: str | Path, target: str, request_id: str | None) -> dict[str, object]:
    """Starter request wrapper.

    Ordinary builds still work, but request IDs are not yet given exactly-once
    semantics. Candidates must implement the request protocol required by the
    task contract.
    """
    return Builder(project).build(target)
