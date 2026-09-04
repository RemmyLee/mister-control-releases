# MiSTer Control

Web-based second screen and controller for the [MiSTer FPGA](https://mister-devel.github.io/MkDocs_MiSTer/).
One binary runs on the MiSTer and serves a web app on your LAN. Open it on a phone to watch the game
live and play with a touch pad. Your library is there too. Nothing is installed on a PC. There is no
account and no cloud service.

![Home on a laptop](shots/home-desktop.png)

Downloads only. The app source is not public.

## Install

1. Copy `mister-control.sh` (in the file list above) to `/media/fat/Scripts/` on the MiSTer.
2. On the TV, run it from the Scripts menu. Over SSH: `sh /media/fat/Scripts/mister-control.sh`
3. It installs itself, then prints the address to open.

The installer puts the app in `/media/fat/mister-control/` and starts it on every boot. It sets two
keys in `MiSTer.ini` and keeps a backup at `MiSTer.ini.mister-control.bak`. `log_file_entry=1` lets
the app read which game is running. `debug=2` lets it confirm when a cheat turns on. Both take effect
at the next core load. The first run also downloads the game catalogue (about 150 MB) and a copy of
ffmpeg for broadcasting (about 32 MB).

## Accessing the web app

The app runs on port 8110. On a browser on the same network, go to `http://<MiSTer-IP>:8110`, for
example `http://192.168.1.50:8110`. The install script and the MiSTer menu both show the IP. Inside
the app, Settings > Network and access puts a QR code on the TV. "Add to Home Screen" runs it full
screen.

If you share the network with other people, set a token with `-token` or `MC_TOKEN` in `run.sh`. A
phone then pairs once with a 6-digit PIN.

## Features

### Home

The game you are playing shows live inside its tile, with your recent games beside it. Tap one to
launch it. On an MC core the tile also shows the game's own state, such as your current lives.

<img src="shots/home-playing-phone.png" width="270" alt="Home with the live game in the tile">

### Play on your phone

Tap the running game and a touch gamepad opens under the live picture. Capture and Clip buttons sit
on the picture.

<img src="shots/controller-phone.png" width="270" alt="Touch gamepad">

### Library

Every system on your card, each game with its box art. Search it, set favorites, and make your own
collections. A row of filters narrows a big system down (by letter, region, genre, decade, or player
count). Most box art is included offline. If a game has no cover, the app can fetch it from
ScreenScraper with your account.

<img src="shots/library-tas-filter-phone.png" width="270" alt="Library">

### Game sheet

Long-press a game to open its sheet. From there you can:

- Launch or restart it, favorite it, or add it to a collection
- Pin a shortcut to the TV menu, or fix a wrong title or year
- Open a longplay or the game's page on GameFAQs, StrategyWiki, or Wikipedia

While the game runs, the sheet also holds its save state slots (saved and loaded from your phone),
its cheats, its core options, and your play time.

<img src="shots/gamesheet-cheats-phone.png" width="270" alt="Cheats"> <img src="shots/gamesheet-live-phone.png" width="270" alt="Live state">

### MC-NES

Our own build of the NES core, added from Settings > Install. It uses the same game folder as the
stock core. It sends the game's RAM and register state to the app on every frame, which powers the
live values on Home and the game sheet.

<img src="shots/settings-install-phone.png" width="270" alt="Install MC-NES">

### TAS playback

On MC-NES the FPGA can play a TASVideos run on your TV. The app takes the checksum of your ROM and
finds the matching version on [TASVideos](https://tasvideos.org), then lists the runs published for
it. Pick one and it downloads to the card, and the core plays it back frame by frame. The Library
flags any game you own that has a matching run. Your own `.fm2` files work too.

<img src="shots/gamesheet-tasvideos-phone.png" width="270" alt="TASVideos runs">

### Everything else

- **Album** for the screenshots the MiSTer took and the clips you grabbed
- **Manuals** downloaded one at a time, only when you ask
- **Saves** you can pull off the card or push back on
- **Install** for cores, homebrew, wallpaper, and scripts, through the MiSTer's own downloader
- **TV menu editor** for the folders and shortcuts on the TV
- **Quick settings** on a hold of the Home button, without leaving the game
- **Music**, **wallpaper**, **backups**, **automation**, and a broadcast to an RTMP URL

<img src="shots/play-activity-phone.png" width="270" alt="Play activity"> <img src="shots/album-phone.png" width="270" alt="Album"> <img src="shots/quick-settings-phone.png" width="270" alt="Quick settings">

## Update

- In the app: Settings > About > Install. It checks here every hour.
- From the Scripts menu: run `mister-control` again.
- With update_all: turn it on in Settings > About, or add this to `downloader.ini`:

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

The app listens on your LAN only. It has no account and no cloud. Set a token if other people share
the network. A broadcast goes only to the RTMP URL you enter, and the stream key stays on the MiSTer.
`ffmpeg-armhf` is the unmodified static build from https://johnvansickle.com/ffmpeg/ (GPL v3).
