#!/usr/bin/env bash
# Upload the Mac zip to an existing (or new) GitHub Release.
# Requires: GitHub CLI (`brew install gh`) logged in as emmanueldevins.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

TAG="${1:-v1.0.0}"
ZIP="$ROOT/dist/CHARLIEDL-mac-arm64.zip"

if [[ ! -f "$ZIP" ]]; then
  echo "Missing $ZIP — run ./build_app.sh first." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found." >&2
  echo "Install: brew install gh && gh auth login" >&2
  echo "" >&2
  echo "Or upload manually:" >&2
  echo "  1) Open https://github.com/emmanueldevins/Music-Track-Downloader/releases" >&2
  echo "  2) Edit release ${TAG} (or create it)" >&2
  echo "  3) Drag & drop: ${ZIP}" >&2
  exit 1
fi

if ! gh release view "$TAG" >/dev/null 2>&1; then
  echo "Creating release ${TAG}…"
  gh release create "$TAG" "$ZIP" \
    --title "Music Track Downloader ${TAG}" \
    --notes "Personal / educational use only — no commercial use. See LICENSE."
else
  echo "Uploading Mac zip to release ${TAG}…"
  gh release upload "$TAG" "$ZIP" --clobber
fi

echo ""
echo "Mac download URL:"
echo "  https://github.com/emmanueldevins/Music-Track-Downloader/releases/download/${TAG}/CHARLIEDL-mac-arm64.zip"
echo "Latest:"
echo "  https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest/download/CHARLIEDL-mac-arm64.zip"
