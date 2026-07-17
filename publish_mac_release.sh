#!/usr/bin/env bash
# Upload the Mac zip to an existing (or new) GitHub Release.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

TAG="${1:-latest}"
ZIP="$ROOT/dist/MusicTrackDownloader-mac-arm64.zip"

if [[ ! -f "$ZIP" ]]; then
  echo "Missing $ZIP — run ./build_app.sh first." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Install: brew install gh && gh auth login" >&2
  echo "Or drag & drop the zip onto the GitHub Release page." >&2
  exit 1
fi

if ! gh release view "$TAG" >/dev/null 2>&1; then
  gh release create "$TAG" "$ZIP" \
    --title "Music Track Downloader" \
    --notes "Personal / educational use only — no commercial use. See LICENSE."
else
  gh release upload "$TAG" "$ZIP" --clobber
fi

echo "Mac: https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest/download/MusicTrackDownloader-mac-arm64.zip"
