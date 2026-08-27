#!/usr/bin/env bash
set -euo pipefail

VENV_ROOT=${VENV_ROOT:-"$HOME/.cache/klavis-tb3-tools/verifier-py313"}
PYTHON="$VENV_ROOT/bin/python"

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

command -v uv >/dev/null 2>&1 || fail "uv is required to provision the pinned local verifier environment"

needs_install=1
if [[ -x "$PYTHON" ]]; then
  if "$PYTHON" - <<'PY' >/dev/null 2>&1
import sys
from importlib.metadata import version
assert sys.version_info[:2] == (3, 13)
assert version("pytest") == "9.1.1"
assert version("pytest-json-ctrf") == "0.5.2"
PY
  then
    needs_install=0
  fi
fi

if [[ $needs_install -eq 1 ]]; then
  echo "Provisioning pinned local verifier environment at $VENV_ROOT" >&2
  rm -rf "$VENV_ROOT"
  uv python install 3.13 >&2
  uv venv --python 3.13 "$VENV_ROOT" >&2
  uv pip install --python "$PYTHON" \
    pytest==9.1.1 \
    pytest-json-ctrf==0.5.2 >&2
fi

"$PYTHON" - <<'PY' >&2
import sys
from importlib.metadata import version
assert sys.version_info[:2] == (3, 13)
assert version("pytest") == "9.1.1"
assert version("pytest-json-ctrf") == "0.5.2"
print(f"Local verifier Python: {sys.version.split()[0]}")
print(f"pytest: {version('pytest')}")
print(f"pytest-json-ctrf: {version('pytest-json-ctrf')}")
PY

printf '%s\n' "$PYTHON"
