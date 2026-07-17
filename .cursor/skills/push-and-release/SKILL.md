---
name: push-and-release
description: >-
  Commit with emoji conventional messages, push to main, and ensure a GitHub
  Release is published for Music Track Downloader. Use when the user asks to
  push, commit and push, ship, release, or publish this project.
---

# Push & Release (Music Track Downloader)

When the user asks to **push**, **commit and push**, **ship**, or **release**:

## 1. Commit (emoji + clear why)

Always use an emoji-prefixed conventional commit via HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
<emoji> <type>: <short why>

EOF
)"
```

| Emoji | Type | When |
|-------|------|------|
| ✨ | `feat` | New user-facing feature |
| 🐛 | `fix` | Bug fix |
| 💄 | `ui` | Visual / copy / layout only |
| 📝 | `docs` | README, LICENSE, comments |
| 🔧 | `chore` | Build, CI, deps, tooling |
| ♻️ | `refactor` | Internal cleanup, no behavior change |
| 🔒 | `security` | Security-related fix |
| 🚀 | `release` | Release-only / ship chore |

Examples:

- `🐛 fix: restore GitHub update check SSL in frozen Mac builds`
- `💄 ui: add personal-use footer for own music`
- `✨ feat: show orange banner when a newer version exists`

Follow the repo git safety rules (no force push to main, no amend unless allowed, no secrets).

## 2. Push to `main`

```bash
git pull --rebase origin main   # if needed
git push -u origin HEAD
```

Remote: `origin` → `emmanueldevins/Music-Track-Downloader` (SSH host `github.com-emmanuel`).

## 3. GitHub Release (automatic via CI)

Pushing to `main` runs **Build & Release**:

1. Bumps patch version (`VERSION` + `version.py`) with `[skip ci]`
2. Builds Mac + Windows zips
3. Publishes a **versioned** GitHub Release `vX.Y.Z` (marked latest)

After push:

1. Confirm the Actions run started (API or Actions URL).
2. Tell the user the run URL and that the release will appear at:
   https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest
3. Do **not** manually create a duplicate release unless CI failed and the user asks to recover.

### Manual recovery (only if CI publish failed)

```bash
# After artifacts exist / local zips ready — prefer re-running the failed job.
gh release create "vX.Y.Z" \
  --title "Music Track Downloader vX.Y.Z" \
  --notes "Personal use only — for your own music." \
  dist/MusicTrackDownloader-mac-arm64.zip \
  dist/MusicTrackDownloader-win64.zip
```

## Checklist

- [ ] Diff reviewed; no secrets staged
- [ ] Emoji commit message written
- [ ] Pushed to `main`
- [ ] CI / release URL shared with the user
