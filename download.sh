#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VENV="$ROOT/.venv"

resolve_python() {
  if command -v python3.10 >/dev/null 2>&1; then
    command -v python3.10
  elif [[ -x /opt/homebrew/bin/python3.10 ]]; then
    echo /opt/homebrew/bin/python3.10
  else
    echo "Python 3.10 is required. Install with: brew install python@3.10" >&2
    exit 1
  fi
}

ensure_venv() {
  local py
  py="$(resolve_python)"

  if [[ -d "$VENV" ]]; then
    local current
    current="$("$VENV/bin/python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
    if [[ "$current" != "3.10" ]]; then
      echo "Recreating .venv with Python 3.10 (was $current)..."
      rm -rf "$VENV"
    fi
  fi

  if [[ ! -d "$VENV" ]]; then
    echo "Creating .venv with $($py --version)..."
    "$py" -m venv "$VENV"
  fi

  "$VENV/bin/pip" install -q -r "$ROOT/requirements.txt"
}

if [[ "${1:-}" == "check-account" ]]; then
  BROWSER="${2:-chrome}"
  case "$BROWSER" in
    chrome)
      open -a "Google Chrome" "https://soundcloud.com/you"
      ;;
    safari)
      open -a "Safari" "https://soundcloud.com/you"
      ;;
    firefox)
      open -a "Firefox" "https://soundcloud.com/you"
      ;;
    *)
      echo "Unknown browser: $BROWSER (use chrome, safari, or firefox)" >&2
      exit 1
      ;;
  esac
  echo "Opened SoundCloud in $BROWSER."
  echo "Check the profile icon (top right) — that is the account used for --browser $BROWSER downloads."
  exit 0
fi

if [[ "${1:-}" == "list-missing" ]]; then
  shift
  ensure_venv
  exec "$VENV/bin/python" "$ROOT/list_missing.py" "$@"
fi

if [[ "${1:-}" == "gui" ]]; then
  ensure_venv
  exec "$VENV/bin/python" "$ROOT/app_gui.py"
fi

ensure_venv
exec "$VENV/bin/python" "$ROOT/download_playlist.py" "$@"
