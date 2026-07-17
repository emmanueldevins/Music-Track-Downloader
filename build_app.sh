#!/usr/bin/env bash
# Build Music Track Downloader.app for Mac (Apple Silicon).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This build is for macOS only." >&2
  exit 1
fi

APP_NAME="Music Track Downloader"
APP_SHORT="MusicTrackDownloader"

resolve_python() {
  if [[ -n "${PYTHON_BIN:-}" && -x "${PYTHON_BIN}" ]]; then
    echo "$PYTHON_BIN"
    return
  fi
  if command -v python3.11 >/dev/null 2>&1; then
    command -v python3.11
    return
  fi
  if command -v python3.10 >/dev/null 2>&1; then
    command -v python3.10
    return
  fi
  if [[ -x /opt/homebrew/bin/python3.10 ]]; then
    echo /opt/homebrew/bin/python3.10
    return
  fi
  if command -v python3 >/dev/null 2>&1; then
    command -v python3
    return
  fi
  echo "Python 3.10+ required" >&2
  exit 1
}

PY="$(resolve_python)"
VENV="$ROOT/.venv"
if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
  VENV="$ROOT/.venv-ci"
fi
if [[ ! -x "$VENV/bin/python" ]]; then
  "$PY" -m venv "$VENV"
fi

"$VENV/bin/pip" install -q -U pip
"$VENV/bin/pip" install -q -r "$ROOT/requirements.txt" pyinstaller imageio-ffmpeg

# Keep VERSION file in sync with version.py
"$VENV/bin/python" -c "from version import APP_VERSION; open('VERSION','w').write(APP_VERSION+'\n')"

echo "Building ${APP_NAME}.app (takes a few minutes)…"
chmod -R u+w "$ROOT/build" "$ROOT/dist" 2>/dev/null || true
rm -rf "$ROOT/build" "$ROOT/dist"
"$VENV/bin/pyinstaller" --noconfirm --clean "$ROOT/MusicTrackDownloader.spec"

APP="$ROOT/dist/${APP_SHORT}.app"
if [[ ! -d "$APP" ]]; then
  echo "Build failed: $APP not found" >&2
  exit 1
fi

find "$APP" -type f \( -name 'ffmpeg' -o -name 'ffmpeg-*' \) -exec chmod +x {} \;

FFMPEG_CACHE="$ROOT/build/ffmpeg-cache"
mkdir -p "$FFMPEG_CACHE"
bundle_ffmpeg_tool() {
  local name="$1"
  local url="https://ffmpeg.martin-riedl.de/redirect/latest/macos/arm64/release/${name}.zip"
  local zip="$FFMPEG_CACHE/${name}.zip"
  local bin="$FFMPEG_CACHE/${name}"
  if [[ ! -x "$bin" ]]; then
    echo "Downloading static ${name} (arm64)…"
    curl -fsSL -o "$zip" "$url"
    unzip -o -q -j "$zip" "$name" -d "$FFMPEG_CACHE"
    chmod +x "$bin"
  fi
  cp "$bin" "$APP/Contents/MacOS/${name}"
  chmod +x "$APP/Contents/MacOS/${name}"
}
if bundle_ffmpeg_tool ffmpeg && bundle_ffmpeg_tool ffprobe; then
  echo "Bundled ffmpeg + ffprobe into the app."
else
  echo "Warning: could not bundle ffmpeg/ffprobe — YouTube postprocess may fail." >&2
fi

DENO_BIN="$(command -v deno || true)"
if [[ -z "$DENO_BIN" && -x /opt/homebrew/bin/deno ]]; then
  DENO_BIN=/opt/homebrew/bin/deno
fi
if [[ -z "$DENO_BIN" || ! -x "$DENO_BIN" ]]; then
  DENO_CACHE="$ROOT/build/deno-cache"
  mkdir -p "$DENO_CACHE"
  ARCH="$(uname -m)"
  if [[ "$ARCH" == "arm64" ]]; then
    DENO_ZIP_URL="https://github.com/denoland/deno/releases/latest/download/deno-aarch64-apple-darwin.zip"
  else
    DENO_ZIP_URL="https://github.com/denoland/deno/releases/latest/download/deno-x86_64-apple-darwin.zip"
  fi
  echo "Downloading Deno…"
  curl -fsSL -o "$DENO_CACHE/deno.zip" "$DENO_ZIP_URL"
  unzip -o -q "$DENO_CACHE/deno.zip" -d "$DENO_CACHE"
  DENO_BIN="$DENO_CACHE/deno"
  chmod +x "$DENO_BIN"
fi
if [[ -n "$DENO_BIN" && -x "$DENO_BIN" ]]; then
  cp "$DENO_BIN" "$APP/Contents/MacOS/deno"
  chmod +x "$APP/Contents/MacOS/deno"
  echo "Bundled deno into the app."
else
  echo "Warning: deno not found — YouTube downloads may fail in the .app." >&2
fi

ZIP="$ROOT/dist/${APP_SHORT}-mac-arm64.zip"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

SIZE="$(du -sh "$APP" | awk '{print $1}')"
ZIPSIZE="$(du -sh "$ZIP" | awk '{print $1}')"

echo ""
echo "OK — prêt à partager :"
echo "  App : $APP  ($SIZE)"
echo "  Zip : $ZIP  ($ZIPSIZE)"
echo ""
echo "Pour tes potes :"
echo "  1) Envoie le .zip"
echo "  2) Ils dézippent → ${APP_SHORT}.app (Music Track Downloader)"
echo "  3) Première fois : clic droit → Ouvrir (Gatekeeper)"
echo "  4) Fichiers dans ~/Downloads/${APP_SHORT}"
echo ""
echo "Note : build Apple Silicon (M1/M2/M3/M4)."
