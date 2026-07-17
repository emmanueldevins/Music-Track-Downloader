#!/usr/bin/env python3
"""List playlist tracks that are not yet downloaded."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yt_dlp

from download_playlist import archive_path, fetch_playlist_titles, is_track_downloaded


def main() -> int:
    parser = argparse.ArgumentParser(description="List missing tracks from a playlist.")
    parser.add_argument("url", help="SoundCloud playlist URL")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path("downloads"),
        help="Download directory to check (default: ./downloads)",
    )
    parser.add_argument(
        "--browser",
        metavar="BROWSER",
        help="Browser for cookies (e.g. chrome), same as download script",
    )
    args = parser.parse_args()

    ydl_opts: dict = {
        "quiet": True,
        "extract_flat": "in_playlist",
        "ignoreerrors": True,
    }
    if args.browser:
        ydl_opts["cookiesfrombrowser"] = (args.browser,)

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(args.url, download=False)

    if not info:
        print("Could not read playlist.", file=sys.stderr)
        return 1

    entries = [entry for entry in (info.get("entries") or []) if entry]
    title_map = fetch_playlist_titles(args.url)
    missing: list[tuple[str, str, str]] = []

    for index, entry in enumerate(entries, start=1):
        if is_track_downloaded(args.output, index, entry, title_map):
            continue

        title = entry.get("title") or title_map.get(str(entry.get("id") or "")) or "Unknown"
        url = entry.get("url") or entry.get("webpage_url") or ""
        missing.append((f"{index:02d}", title, url))

    if not missing:
        print("All playlist tracks are already downloaded.")
        return 0

    print(f"Missing {len(missing)} track(s):\n")
    for idx, title, url in missing:
        print(f"{idx}. {title}")
        print(f"    {url}\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
