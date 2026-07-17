# Music Track Downloader

> **Personal / educational use only. Not for commercial use. No warranty.**  
> See [Legal & disclaimer](#legal--disclaimer) before downloading or using this software.

Desktop tool to download **music tracks and playlists** as audio files (e.g. for personal DJ / USB practice).

**Supported today:** SoundCloud & YouTube (tracks + playlists)  
**Planned (maybe):** Deezer, Spotify  

> App binary name: **CHARLIEDL** (`CHARLIEDL.app` / `CHARLIEDL.exe`)

---

## Legal & disclaimer

**Read this first.**

This project is provided **for fun, learning, and personal use only**.

| Rule | Meaning |
|------|---------|
| **No commercial use** | Do not sell, rent, license, or use this software (or files obtained with it) in any business, paid gig pipeline, shop, SaaS, or monetized workflow. |
| **No redistribution as a product** | Do not repackage or sell this app. Sharing the GitHub link with friends is fine; selling copies is not. |
| **You are responsible** | You alone decide what you download. You must comply with the terms of service of SoundCloud, YouTube, and any other site, plus copyright and local law. |
| **No piracy endorsement** | This tool does not grant you rights to content you do not already have the right to use. Prefer content you own, created, or are allowed to copy. |
| **No warranty** | Provided **“as is”**, without any warranty. The authors are **not liable** for account bans, takedowns, data loss, legal claims, or any other damage. |
| **Platform ToS** | Using unofficial download methods may violate third-party terms and can lead to account suspension. Use at your own risk. |

By downloading or using this software, you agree to these terms. If you do not agree, do not use it.

Full text: see [`LICENSE`](LICENSE).

---

## Download (ready-made builds)

Stable downloads are published on **GitHub Releases** (not inside the git repo — binaries are large).

### Latest release

**[→ All downloads (Releases)](https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest)**

| Platform | File | Direct link |
|----------|------|-------------|
| **macOS** (Apple Silicon) | `CHARLIEDL-mac-arm64.zip` | [Download Mac](https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest/download/CHARLIEDL-mac-arm64.zip) |
| **Windows** (64-bit) | `CHARLIEDL-win64.zip` | [Download Windows](https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest/download/CHARLIEDL-win64.zip) |

> If a link 404s, the release is not published yet — open [Releases](https://github.com/emmanueldevins/Music-Track-Downloader/releases) or build from source below.

### Install notes

**macOS**

1. Download the Mac zip → unzip → `CHARLIEDL.app`
2. First launch: **right-click → Open** (Gatekeeper)
3. Files save to `~/Downloads/CHARLIEDL`

**Windows**

1. Download the Windows zip → unzip → run `CHARLIEDL.exe`
2. SmartScreen: **More info → Run anyway**
3. Files save to `%USERPROFILE%\Downloads\CHARLIEDL`

---

## How builds get onto Releases

Every push to **`main`** runs GitHub Actions (**Build & Release**):

1. Builds **macOS** (Apple Silicon) and **Windows** in the cloud  
2. Publishes both zips to the **[Latest builds](https://github.com/emmanueldevins/Music-Track-Downloader/releases/latest)** release  

README download links always point at that release — no need to upload Mac by hand.

You can also trigger a rebuild manually: **Actions → Build & Release → Run workflow**.

Do **not** commit `.app` / `.exe` / large zips into git — Releases stay the download source.

---

## Features

- Tracks **and** playlists
- SoundCloud + YouTube (more platforms maybe later)
- Optional browser login (Chrome / Edge / Firefox)
- YouTube fallback when a SoundCloud track fails
- Cover art when possible
- Rate-limit aware SoundCloud downloads
- Stop / skip existing / open folder when done

---

## Build from source

### macOS app

```bash
./build_app.sh
```

Produces `dist/CHARLIEDL.app` and `dist/CHARLIEDL-mac-arm64.zip`.

Upload the zip to a GitHub Release (or run `./publish_mac_release.sh v1.0.0` if `gh` is installed and authenticated).

### Windows app

Built automatically by CI on push to `main`. Manual rebuild: Actions → **Build & Release**.

On a Windows PC: `.\build_windows.ps1`

### Dev GUI (Mac)

```bash
./download.sh gui
```

Requires Python 3.10+. Optional: `brew install ffmpeg deno`.

---

## Tips

| Tip | Why |
|-----|-----|
| Use **Chrome** logged into the service | Fewer blocks / better quality |
| Enable **Ignorer déjà téléchargés** on retry | Only missing tracks are fetched again |
| Large SoundCloud sets are slower on purpose | Avoids HTTP 429 |

---

## Roadmap

- [x] SoundCloud tracks & playlists  
- [x] YouTube tracks & playlists  
- [x] macOS + Windows packaging  
- [ ] Deezer (maybe)  
- [ ] Spotify (maybe)  

---

## Project layout

| Path | Role |
|------|------|
| `app_gui.py` | Desktop UI |
| `download_playlist.py` | Download engine |
| `build_app.sh` | macOS package |
| `build_windows.ps1` | Windows package |
| `.github/workflows/build-and-release.yml` | Auto Mac + Windows build & release |
| `LICENSE` | Personal-use license / disclaimer |

---

## Contact / issues

Use [GitHub Issues](https://github.com/emmanueldevins/Music-Track-Downloader/issues) for bugs. This is a **hobby** project — no support SLA, no commercial offering.
