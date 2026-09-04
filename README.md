# MiSTer Control

Web-based second screen and controller for the [MiSTer FPGA](https://mister-devel.github.io/MkDocs_MiSTer/).
One binary runs on the MiSTer and serves a web app on your LAN. Open it on a phone to see the live
game, play with a touch pad, and browse your library. No PC install, no account, no cloud.

![Home on a laptop](shots/home-desktop.png)

Downloads only. The app source is not public.

## Install

1. Copy **`mister-control.sh`** (in the file list above) to `/media/fat/Scripts/` on the MiSTer.
2. TV menu > Scripts > **`mister-control`**. Or over SSH: `sh /media/fat/Scripts/mister-control.sh`
3. It installs, starts, and prints the address.

The installer downloads the release to `/media/fat/mister-control/` and autostarts it on boot. It
sets two `MiSTer.ini` keys (backup at `MiSTer.ini.mister-control.bak`): `log_file_entry=1` so the
app can read the running game, and `debug=2` so it can confirm cheats. Both apply at the next core
load. First run also downloads the game catalogue (~150 MB) and ffmpeg (~32 MB); updates keep both.

## Accessing the web app

Port **8110**: `http://<MiSTer-IP>:8110` (e.g. `http://192.168.1.50:8110`). The install script and
the MiSTer menu both show the IP. **Settings > Network and access** shows a QR code on the TV. Use
"Add to Home Screen" to run it full screen.

Shared network: set a token (`-token`, or `MC_TOKEN` in `run.sh`); phones then pair with a 6-digit
PIN.

## Features

**Home**: the running game live in the tile, plus recent games. Tap to launch. On an MC core, the
tile shows game state (lives, score).

<img src="shots/home-playing-phone.png" width="270" alt="Home with the live game in the tile">

**Play**: tap the running game for a touch gamepad under the live picture, with Capture and Clip.

<img src="shots/controller-phone.png" width="270" alt="Touch gamepad">

**Library**: every system with box art, year, publisher, genre. Search, favorites, collections.
Filters: letter, region, genre, decade, players. Art ships offline; missing covers scrape from
ScreenScraper with your account.

<img src="shots/library-tas-filter-phone.png" width="270" alt="Library">

**Game sheet** (long press): launch/restart, favorite, collection, TV-menu shortcut, edit
title/year, links to GameFAQs/StrategyWiki/Wikipedia/longplay. While running: save state slots,
cheats, core options, play time.

<img src="shots/gamesheet-cheats-phone.png" width="270" alt="Cheats"> <img src="shots/gamesheet-live-phone.png" width="270" alt="Live state">

**MC-NES** (from Install): our NES core beside the stock one, same games/saves/cheats. Reports work
RAM, CPU registers, and controller reads every frame. Feeds the live values on Home and the sheet.

<img src="shots/settings-install-phone.png" width="270" alt="Install MC-NES">

**TAS playback**: on MC-NES, play a TASVideos run on the TV. The app matches your ROM by checksum
to the [TASVideos](https://tasvideos.org) version, lists its runs, downloads the one you pick, and
the core plays it frame by frame. The Library flags games with a matching run. Your own `.fm2` files
work too.

<img src="shots/gamesheet-tasvideos-phone.png" width="270" alt="TASVideos runs">

**Also**: screenshot/clip album, on-demand game manuals, SRAM save up/download, one-tap Install
catalogue (cores, homebrew, wallpaper, scripts) via the MiSTer downloader, TV menu editor, quick
settings (hold Home), music, wallpaper, backups, automation, RTMP broadcast.

<img src="shots/play-activity-phone.png" width="270" alt="Play activity"> <img src="shots/album-phone.png" width="270" alt="Album"> <img src="shots/quick-settings-phone.png" width="270" alt="Quick settings">

## Update

- App: **Settings > About > Install** (auto-checks hourly).
- Scripts menu: run `mister-control` again.
- update_all: enable it in Settings > About, or add to `downloader.ini`:

```ini
[mister_control]
db_url = 'https://raw.githubusercontent.com/RemmyLee/mister-control-releases/main/db.json.zip'
```

## Contents

| File | What it is |
|---|---|
| Releases | `mister-control-<version>-armv7.zip`, `launchbox.db`, `ffmpeg-armhf` |
| `release.json` | version, URLs, SHA-256s; read by the app and installer |
| `db.json.zip` | update_all database |
| `cores/db.json.zip` | update_all database for the MC cores (MC-NES) |
| `catalog.json` | in-app Install catalogue |
| `files/` | release split per file for the downloader |
| `mister-control.sh` | installer |

## Notes

LAN only, no account, no cloud. Set a token if others share the network. The RTMP broadcast goes
only to the URL you enter; the stream key stays on the MiSTer. `ffmpeg-armhf` is the unmodified
static build from https://johnvansickle.com/ffmpeg/ (GPL v3).
