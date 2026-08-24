from __future__ import annotations

import hashlib
import json
import os
import tempfile
from pathlib import Path, PurePosixPath
from typing import Any


class BuildError(RuntimeError):
    """Raised when a project cannot be built deterministically."""


def _safe_relative(raw: Any) -> str:
    if not isinstance(raw, str) or not raw:
        raise BuildError(f"invalid project-relative path: {raw!r}")
    path = PurePosixPath(raw)
    if path.is_absolute() or ".." in path.parts or "." in path.parts:
        raise BuildError(f"path escapes the project: {raw!r}")
    return path.as_posix()


def _unique_paths(paths: list[str]) -> list[str]:
    return sorted(set(paths))


def _json_bytes(value: Any) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


class Builder:
    def __init__(self, project: str | Path):
        self.project = Path(project).resolve()
        if not self.project.is_dir():
            raise BuildError(f"project directory does not exist: {project}")
        try:
            self.manifest = json.loads((self.project / "manifest.json").read_text())
        except (OSError, ValueError) as exc:
            raise BuildError("could not read manifest.json") from exc
        if not isinstance(self.manifest, dict) or not isinstance(
            self.manifest.get("targets"), dict
        ):
            raise BuildError("manifest targets must be an object")
        self.targets: dict[str, dict[str, Any]] = self.manifest["targets"]
        self.cache = self.project / ".build-cache"
        self.records = self.cache / "records"
        self.objects = self.cache / "objects"
        self.records.mkdir(parents=True, exist_ok=True)
        self.objects.mkdir(parents=True, exist_ok=True)
        self.events: list[dict[str, Any]] = []
        self._results: dict[str, dict[str, Any]] = {}
        self._active: list[str] = []

    def build(self, target: str) -> dict[str, Any]:
        self._build_target(target)
        outputs = {
            name: {
                "path": result["output"],
                "sha256": result["output_digest"],
            }
            for name, result in self._results.items()
        }
        return {"target": target, "events": self.events, "outputs": outputs}

    def _build_target(self, name: str) -> dict[str, Any]:
        if name in self._results:
            return self._results[name]
        if name in self._active:
            cycle = " -> ".join(self._active + [name])
            raise BuildError(f"target dependency cycle: {cycle}")
        definition = self.targets.get(name)
        if not isinstance(definition, dict):
            raise BuildError(f"unknown target: {name}")
        self._active.append(name)
        try:
            requires = definition.get("requires", [])
            if not isinstance(requires, list) or any(
                not isinstance(item, str) for item in requires
            ):
                raise BuildError(f"target {name} has invalid requires")
            dependencies = {dep: self._build_target(dep) for dep in requires}
            kind = definition.get("kind")
            if kind not in {"bundle", "concat", "sha256"}:
                raise BuildError(f"target {name} has unsupported kind")
            output = _safe_relative(definition.get("output"))
            record = self._read_record(name)

            candidate_files = self._direct_files(definition)
            if kind == "bundle" and record:
                previous = [
                    item
                    for item in record.get("dependencies", [])
                    if isinstance(item, str)
                ]
                candidate_files = _unique_paths(candidate_files + previous)
            upstream = {
                dep: dependencies[dep]["output_digest"] for dep in requires
            }
            candidate_key = self._action_key(
                name, definition, candidate_files, upstream
            )
            if self._cache_is_valid(record, candidate_key):
                data = self._read_object(record["key"])
                self._materialize(output, data)
                result = {
                    "output": output,
                    "output_digest": record["output_digest"],
                    "bytes": data,
                }
                self.events.append(
                    {
                        "target": name,
                        "status": "cached",
                        "key": record["key"],
                        "dependencies": record["dependencies"],
                    }
                )
                self._results[name] = result
                return result

            data, discovered = self._execute(name, definition, dependencies)
            final_key = self._action_key(name, definition, discovered, upstream)
            output_digest = _sha256(data)
            self._write_object(final_key, data)
            self._materialize(output, data)
            self._write_record(
                name,
                {
                    "key": final_key,
                    "dependencies": discovered,
                    "output": output,
                    "output_digest": output_digest,
                },
            )
            result = {"output": output, "output_digest": output_digest, "bytes": data}
            self.events.append(
                {
                    "target": name,
                    "status": "built",
                    "key": final_key,
                    "dependencies": discovered,
                }
            )
            self._results[name] = result
            return result
        finally:
            self._active.pop()

    def _direct_files(self, definition: dict[str, Any]) -> list[str]:
        if definition.get("kind") != "bundle":
            return []
        return [_safe_relative(definition.get("entry"))]

    def _execute(
        self,
        name: str,
        definition: dict[str, Any],
        dependencies: dict[str, dict[str, Any]],
    ) -> tuple[bytes, list[str]]:
        kind = definition["kind"]
        if kind == "bundle":
            entry = _safe_relative(definition.get("entry"))
            data, discovered = self._expand(entry, [])
            return data, _unique_paths(discovered)
        required = definition.get("requires", [])
        chunks = [dependencies[dep]["bytes"] for dep in required]
        combined = b"".join(chunks)
        if kind == "concat":
            return combined, []
        if kind == "sha256":
            return (_sha256(combined) + "\n").encode("ascii"), []
        raise BuildError(f"target {name} has unsupported kind")

    def _expand(self, relative: str, active: list[str]) -> tuple[bytes, list[str]]:
        if relative in active:
            cycle = " -> ".join(active + [relative])
            raise BuildError(f"include cycle: {cycle}")
        path = self.project / relative
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as exc:
            raise BuildError(f"could not read included file: {relative}") from exc
        discovered = [relative]
        chunks: list[bytes] = []
        next_active = active + [relative]
        for line in text.splitlines(keepends=True):
            if line.startswith("@include "):
                child = _safe_relative(line[len("@include ") :].strip())
                child_data, child_deps = self._expand(child, next_active)
                chunks.append(child_data)
                discovered.append(child)
            elif line.startswith("@glob "):
                directory = _safe_relative(line[len("@glob ") :].strip())
                child_data, child_deps = self._expand_glob(directory, next_active)
                chunks.append(child_data)
                discovered.append(f"dir:{directory}")
            else:
                chunks.append(line.encode("utf-8"))
        return b"".join(chunks), discovered

    def _expand_glob(
        self, directory: str, active: list[str]
    ) -> tuple[bytes, list[str]]:
        path = self.project / directory
        if not path.is_dir():
            raise BuildError(f"glob directory does not exist: {directory}")
        entries = sorted(
            child for child in path.iterdir() if child.is_file()
        )
        discovered = [f"dir:{directory}"]
        chunks: list[bytes] = []
        for entry in entries:
            relative = entry.relative_to(self.project).as_posix()
            child_data, child_deps = self._expand(relative, active)
            chunks.append(child_data)
            discovered.extend(child_deps)
        return b"".join(chunks), _unique_paths(discovered)

    def _action_key(
        self,
        name: str,
        definition: dict[str, Any],
        files: list[str],
        upstream: dict[str, str],
    ) -> str:
        signatures = []
        for relative in _unique_paths(files):
            if relative.startswith("dir:"):
                directory = _safe_relative(relative[4:])
                path = self.project / directory
                if not path.is_dir():
                    raise BuildError(f"glob directory does not exist: {directory}")
                entries = sorted(child.name for child in path.iterdir() if child.is_file())
                signatures.append({"directory": directory, "entries": entries})
                continue
            path = self.project / _safe_relative(relative)
            try:
                data = path.read_bytes()
            except FileNotFoundError:
                # A prior glob member may have been removed.  The missing
                # sentinel changes the action key so execution can rediscover
                # the current directory contents instead of failing while
                # inspecting stale dependency metadata.
                signatures.append({"path": relative, "missing": True})
                continue
            except OSError as exc:
                raise BuildError(f"could not read input file: {relative}") from exc
            signatures.append({"path": relative, "sha256": _sha256(data)})
        payload = {
            "engine": 1,
            "target": name,
            "definition": definition,
            "files": signatures,
            "upstream": upstream,
        }
        return _sha256(_json_bytes(payload))

    def _record_path(self, name: str) -> Path:
        return self.records / f"{_safe_relative(name).replace('/', '__')}.json"

    def _read_record(self, name: str) -> dict[str, Any] | None:
        try:
            value = json.loads(self._record_path(name).read_text())
        except (OSError, ValueError):
            return None
        if not isinstance(value, dict):
            return None
        if not isinstance(value.get("dependencies"), list):
            return None
        return value

    def _cache_is_valid(self, record: dict[str, Any] | None, key: str) -> bool:
        if not record or record.get("key") != key:
            return False
        object_key = record.get("key")
        expected = record.get("output_digest")
        if not isinstance(object_key, str) or not isinstance(expected, str):
            return False
        try:
            return _sha256(self._read_object(object_key)) == expected
        except (OSError, BuildError):
            return False

    def _read_object(self, key: str) -> bytes:
        if not isinstance(key, str) or len(key) != 64:
            raise BuildError("invalid cache object key")
        try:
            return (self.objects / f"{key}.bin").read_bytes()
        except OSError as exc:
            raise BuildError("cache object is unavailable") from exc

    def _write_object(self, key: str, data: bytes) -> None:
        _atomic_write(self.objects / f"{key}.bin", data)

    def _materialize(self, relative: str, data: bytes) -> None:
        _atomic_write(self.project / _safe_relative(relative), data)

    def _write_record(self, name: str, record: dict[str, Any]) -> None:
        _atomic_write(self._record_path(name), _json_bytes(record) + b"\n")


def _atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".tmp-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    except BaseException:
        try:
            os.unlink(temporary)
        except OSError:
            pass
        raise
