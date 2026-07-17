#!/usr/bin/env bash
# Build a double-clickable CHARLIEDL.app for Mac friends (Apple Silicon).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This build is for macOS only." >&2
  exit 1
fi

resolve_python() {
  if command -v python3.10 >/dev/null 2>&1; then
    command -v python3.10
  elif [[ -x /opt/homebrew/bin/python3.10 ]]; then
    echo /opt/homebrew/bin/python3.10
  else
    echo "Python 3.10 required: brew install python@3.10" >&2
    exit 1
  fi
}

PY="$(resolve_python)"
VENV="$ROOT/.venv"
if [[ ! -x "$VENV/bin/python" ]]; then
  "$PY" -m venv "$VENV"
fi

"$VENV/bin/pip" install -q -r "$ROOT/requirements.txt" pyinstaller imageio-ffmpeg

echo "Building CHARLIEDL.app (takes a few minutes)…"
chmod -R u+w "$ROOT/build" "$ROOT/dist" 2>/dev/null || true
rm -rf "$ROOT/build" "$ROOT/dist"
"$VENV/bin/pyinstaller" --noconfirm --clean "$ROOT/CHARLIEDL.spec"

APP="$ROOT/dist/CHARLIEDL.app"
if [[ ! -d "$APP" ]]; then
  echo "Build failed: $APP not found" >&2
  exit 1
fi

# Make sure imageio ffmpeg binaries inside the bundle are executable
find "$APP" -type f \( -name 'ffmpeg' -o -name 'ffmpeg-*' \) -exec chmod +x {} \;

# Bundle static ffmpeg + ffprobe (arm64) so friends don't need Homebrew
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

# Bundle Deno so YouTube JS challenges work without Homebrew on friends' Macs
DENO_BIN="$(command -v deno || true)"
if [[ -z "$DENO_BIN" && -x /opt/homebrew/bin/deno ]]; then
  DENO_BIN=/opt/homebrew/bin/deno
fi
if [[ -n "$DENO_BIN" && -x "$DENO_BIN" ]]; then
  cp "$DENO_BIN" "$APP/Contents/MacOS/deno"
  chmod +x "$APP/Contents/MacOS/deno"
  echo "Bundled deno into the app."
else
  echo "Warning: deno not found — YouTube downloads may fail in the .app." >&2
  echo "Install with: brew install deno" >&2
fi

# Zip for AirDrop / Drive (single file to send)
ZIP="$ROOT/dist/CHARLIEDL-mac-arm64.zip"
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
echo "  2) Ils dézippent → CHARLIEDL.app"
echo "  3) Première fois : clic droit → Ouvrir (Gatekeeper)"
echo "  4) Fichiers dans ~/Downloads/CHARLIEDL"
echo ""
echo "Note : build Apple Silicon (M1/M2/M3/M4). Mac Intel = autre build."
