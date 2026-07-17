# Build Music Track Downloader for Windows 64-bit (folder + zip).
# Run in PowerShell:  .\build_windows.ps1
$ErrorActionPreference = "Stop"

$Root = $PSScriptRoot
Set-Location $Root

$AppShort = "MusicTrackDownloader"

function Resolve-Python {
    $candidates = @(
        (Get-Command python -ErrorAction SilentlyContinue),
        (Get-Command py -ErrorAction SilentlyContinue)
    ) | Where-Object { $_ }
    if (-not $candidates) {
        throw "Python not found. Install Python 3.10+ from https://www.python.org/downloads/"
    }
    return $candidates[0].Source
}

$Py = Resolve-Python
$Venv = Join-Path $Root ".venv-win"
$PyExe = Join-Path $Venv "Scripts\python.exe"
$Pip = Join-Path $Venv "Scripts\pip.exe"
$PyInstaller = Join-Path $Venv "Scripts\pyinstaller.exe"

if (-not (Test-Path $PyExe)) {
    & $Py -m venv $Venv
}
& $Pip install -q -r (Join-Path $Root "requirements.txt") pyinstaller imageio-ffmpeg
& $PyExe -c "from version import APP_VERSION; open('VERSION','w',encoding='utf-8').write(APP_VERSION+chr(10))"

Write-Host "Building Music Track Downloader (Windows x64)…"
if (Test-Path (Join-Path $Root "build")) { Remove-Item -Recurse -Force (Join-Path $Root "build") }
if (Test-Path (Join-Path $Root "dist")) { Remove-Item -Recurse -Force (Join-Path $Root "dist") }

& $PyInstaller --noconfirm --clean (Join-Path $Root "MusicTrackDownloader-win.spec")

$DistDir = Join-Path $Root "dist\$AppShort"
$Exe = Join-Path $DistDir "$AppShort.exe"
if (-not (Test-Path $Exe)) {
    throw "Build failed: $Exe not found"
}

$FfmpegCache = Join-Path $Root "build\ffmpeg-cache-win"
New-Item -ItemType Directory -Force -Path $FfmpegCache | Out-Null
$FfmpegZip = Join-Path $FfmpegCache "ffmpeg-win64.zip"
$FfmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"

if (-not (Test-Path (Join-Path $FfmpegCache "ffmpeg.exe"))) {
    Write-Host "Downloading ffmpeg + ffprobe (win64)…"
    Invoke-WebRequest -Uri $FfmpegUrl -OutFile $FfmpegZip -UseBasicParsing
    Expand-Archive -Path $FfmpegZip -DestinationPath $FfmpegCache -Force
    $BinDir = Get-ChildItem -Path $FfmpegCache -Recurse -Directory -Filter "bin" |
        Where-Object { Test-Path (Join-Path $_.FullName "ffmpeg.exe") } |
        Select-Object -First 1
    if (-not $BinDir) { throw "ffmpeg.exe not found in downloaded archive" }
    Copy-Item (Join-Path $BinDir.FullName "ffmpeg.exe") (Join-Path $FfmpegCache "ffmpeg.exe") -Force
    Copy-Item (Join-Path $BinDir.FullName "ffprobe.exe") (Join-Path $FfmpegCache "ffprobe.exe") -Force
}
Copy-Item (Join-Path $FfmpegCache "ffmpeg.exe") (Join-Path $DistDir "ffmpeg.exe") -Force
Copy-Item (Join-Path $FfmpegCache "ffprobe.exe") (Join-Path $DistDir "ffprobe.exe") -Force
Write-Host "Bundled ffmpeg + ffprobe."

$DenoCache = Join-Path $Root "build\deno-cache-win"
New-Item -ItemType Directory -Force -Path $DenoCache | Out-Null
$DenoZip = Join-Path $DenoCache "deno-win64.zip"
$DenoUrl = "https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip"

if (-not (Test-Path (Join-Path $DenoCache "deno.exe"))) {
    Write-Host "Downloading deno (win64)…"
    Invoke-WebRequest -Uri $DenoUrl -OutFile $DenoZip -UseBasicParsing
    Expand-Archive -Path $DenoZip -DestinationPath $DenoCache -Force
}
Copy-Item (Join-Path $DenoCache "deno.exe") (Join-Path $DistDir "deno.exe") -Force
Write-Host "Bundled deno."

$Zip = Join-Path $Root "dist\$AppShort-win64.zip"
if (Test-Path $Zip) { Remove-Item $Zip -Force }
Compress-Archive -Path $DistDir -DestinationPath $Zip -Force

$AppSize = (Get-ChildItem $DistDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
$ZipSize = (Get-Item $Zip).Length / 1MB

Write-Host ""
Write-Host "OK — ready to share:"
Write-Host "  Folder : $DistDir  ($([math]::Round($AppSize, 0)) MB)"
Write-Host "  Zip    : $Zip  ($([math]::Round($ZipSize, 0)) MB)"
Write-Host ""
Write-Host "For friends:"
Write-Host "  1) Send the .zip"
Write-Host "  2) Unzip -> $AppShort folder"
Write-Host "  3) Run $AppShort.exe (SmartScreen: More info -> Run anyway)"
Write-Host "  4) Files saved to %USERPROFILE%\Downloads\$AppShort"
