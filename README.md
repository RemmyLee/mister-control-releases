# MiSTer Control

MiSTer Control is a web app that runs on the MiSTer FPGA itself. You open it in a browser on your
phone or computer. It shows the TV picture live and doubles as a controller. It also manages your
game library. Nothing gets installed on a PC and nothing talks to an outside service.

![Home on a laptop](shots/home-desktop.png)

This repo has the downloads. The app source is not public.

## Install

1. Copy `mister-control.sh` from this repo to `/media/fat/Scripts/` on the MiSTer.
2. Run it from the Scripts menu on the TV, or over SSH: `sh /media/fat/Scripts/mister-control.sh`
3. When it finishes it prints the address of the web app.

The installer puts the app in `/media/fat/mister-control/` and registers it to start at boot. It
changes two settings in `MiSTer.ini` and saves a backup first. `log_file_entry=1` makes the MiSTer
record which game is running. `debug=2` makes the MiSTer write the log the app uses to verify
cheats. Both apply on the next core load. The first install also downloads the offline game
database (about 150 MB) and ffmpeg (about 32 MB).

## Accessing the web app

The app listens on port 8110. Open `http://<MiSTer-IP>:8110` in a browser on the same network. The
installer prints the address, and Settings > Network and access can show it as a QR code on the TV.
Your browser's "Add to Home Screen" makes it act like an installed app.

If other people use your network, set a token with `-token` or `MC_TOKEN` in `run.sh`. Each device
then has to enter a 6-digit PIN once.

## Features

### Home

The home screen shows the game that is currently running, with live video inside the tile. Recent
games are next to it and tapping one launches it. When the game runs on an MC core, the tile also
shows information read from inside the game, like your remaining lives.

<img src="shots/home-playing-phone.png" width="270" alt="Home with the live game in the tile">

### Play on your phone

Tapping the running game opens a touch controller with the live video above it. Buttons on the
video take a screenshot or record a clip.

<img src="shots/controller-phone.png" width="270" alt="Touch gamepad">

### Library

The library lists every system on your SD card with box art for each game. It has search and
favorites, and games can be grouped into collections. Filters narrow big systems down. The box art
comes from an offline database, and missing covers can be fetched from ScreenScraper if you have an
account there.

<img src="shots/library-tas-filter-phone.png" width="270" alt="Library">

### Game sheet

Holding down on a game opens its detail page, where you can:

- launch or restart it
- mark it as a favorite or put it in a collection
- add a shortcut for it to the TV menu
- correct its title or year
- open GameFAQs, StrategyWiki, Wikipedia, or a longplay video

While the game is running, the page also shows the save state slots, the cheats, the core options,
and your play time.

<img src="shots/gamesheet-cheats-phone.png" width="270" alt="Cheats"> <img src="shots/gamesheet-live-phone.png" width="270" alt="Live state">

### MC-NES

MC-NES is our own build of the NES core, installed from Settings > Install. It behaves like the
stock core and reads the same game folder. The difference is that it streams the console's internal
state to the app once per frame. That is where the live game info on the home screen comes from.

<img src="shots/settings-install-phone.png" width="270" alt="Install MC-NES">

### TAS playback

With MC-NES installed, the app can play back tool-assisted speedruns from
[TASVideos](https://tasvideos.org) on the real hardware. It identifies your exact ROM by checksum
and lists the published runs for it. A run you pick is downloaded to the SD card and played back
frame by frame in the core. Games with an available run get a TAS badge in the library. You can
also upload your own `.fm2` files.

<img src="shots/gamesheet-tasvideos-phone.png" width="270" alt="TASVideos runs">

### Everything else

- Album for the MiSTer's screenshots and your recorded clips
- Game manuals, downloaded per game on request
- SRAM save download and upload
- Install catalog for cores, homebrew, wallpapers, and scripts, through the MiSTer's own downloader
- TV menu editor
- Quick settings panel on holding the Home button
- Music player, wallpapers, backups, automation, RTMP broadcasting

<img src="shots/play-activity-phone.png" width="270" alt="Play activity"> <img src="shots/album-phone.png" width="270" alt="Album"> <img src="shots/quick-settings-phone.png" width="270" alt="Quick settings">

## Updating

- From the app: Settings > About > Install. It checks for new versions hourly.
- Run `mister-control` from the Scripts menu again.
- Through update_all: enable it in Settings > About, or add this to `downloader.ini`:

```ini
[mister_control]
db_url = 'https://raw.githubusercontent.com/RemmyLee/mister-control-releases/main/db.json.zip'
```

## What's in this repo

| File | Purpose |
|---|---|
| Releases | `mister-control-<version>-armv7.zip`, `launchbox.db`, `ffmpeg-armhf` |
| `release.json` | current version with URLs and SHA-256 checksums |
| `db.json.zip` | update_all database |
| `cores/db.json.zip` | update_all database for the MC cores |
| `catalog.json` | the in-app Install catalog |
| `files/` | the release split into single files for the downloader |
| `mister-control.sh` | the installer |

## Notes

The app is only reachable on your own network. Broadcasting sends video to the RTMP URL you
configure and nowhere else. `ffmpeg-armhf` is an unmodified static build from
https://johnvansickle.com/ffmpeg/ (GPL v3).
