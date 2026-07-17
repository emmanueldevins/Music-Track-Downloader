# Music Track Downloader

Desktop app to download **music tracks and playlists** as audio for DJ / USB use.

**Supported today:** SoundCloud & YouTube (tracks + playlists)  
**Planned:** Deezer, Spotify

Paste a link → pick a folder name → download. Files land ready for your USB stick.

> App binary name: **CHARLIEDL** (`CHARLIEDL.app` / `CHARLIEDL.exe`)

---

## Features

- Tracks **and** playlists (not playlists only)
- SoundCloud + YouTube (more platforms planned)
- Optional browser login (Chrome / Edge / Firefox) for better quality + fewer blocks
- Automatic YouTube fallback when a SoundCloud track fails
- Cover art when possible
- Parallel downloads with SoundCloud rate-limit protection
- Stop button, skip already downloaded, auto-open folder when done
- Packaged apps: **macOS** (`.app`) and **Windows** (`.exe` via CI)

---

## Download (friends / non-devs)

### macOS (Apple Silicon)

1. Get `CHARLIEDL-mac-arm64.zip`
2. Unzip → `CHARLIEDL.app`
3. First launch: **right-click → Open** (Gatekeeper)
4. Files go to `~/Downloads/CHARLIEDL`

Build locally:

```bash
./build_app.sh
```

Output: `dist/CHARLIEDL.app` and `dist/CHARLIEDL-mac-arm64.zip`

### Windows (64-bit)

Built by GitHub Actions / GitLab CI (no Windows PC required).

1. Push this repo → wait for the **Build Windows** workflow
2. Download artifact `CHARLIEDL-win64.zip`
3. Unzip → run `CHARLIEDL.exe`  
   (SmartScreen: **More info → Run anyway**)
4. Files go to `%USERPROFILE%\Downloads\CHARLIEDL`

Or on a Windows machine:

```powershell
.\build_windows.ps1
```

---

## Dev setup (Mac)

Requires **Python 3.10+**.

```bash
./download.sh gui
```

Or manually:

```bash
python3.10 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app_gui.py
```

Optional (better YouTube / postprocess if not using the bundled app):

```bash
brew install ffmpeg deno
```

CLI download:

```bash
./download.sh download "https://soundcloud.com/…" chrome
```

---

## Tips

| Tip | Why |
|-----|-----|
| Use **Chrome** logged into SoundCloud / YouTube | Better quality, fewer “not a bot” / 403 errors |
| Enable **Ignorer déjà téléchargés** on retry | Only missing tracks are re-downloaded |
| Large SoundCloud sets run a bit slower | Avoids HTTP 429 rate limits |
| Quit Chrome if cookie export fails | Unlocks the cookie database on macOS |

---

## Roadmap

- [x] SoundCloud tracks & playlists
- [x] YouTube tracks & playlists
- [x] macOS app + Windows CI build
- [ ] Deezer
- [ ] Spotify

---

## Project layout

| Path | Role |
|------|------|
| `app_gui.py` | PySide6 desktop UI |
| `download_playlist.py` | Download engine (yt-dlp) |
| `build_app.sh` | Build macOS `.app` + zip |
| `build_windows.ps1` | Build Windows folder + zip |
| `CHARLIEDL.spec` | PyInstaller (macOS) |
| `CHARLIEDL-win.spec` | PyInstaller (Windows) |
| `.github/workflows/build-windows.yml` | Windows CI on GitHub |
| `.gitlab-ci.yml` | Windows CI on GitLab |

---

## License / use

Personal / DJ USB tooling. Respect platform terms of service and artists’ rights. Only download content you have the right to use.
