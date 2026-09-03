# MiSTer Control
<img width="2940" height="1674" alt="image" src="https://github.com/user-attachments/assets/ab0744d4-6a22-4488-81be-0654c5f7045f" />
<img width="2940" height="1664" alt="image" src="https://github.com/user-attachments/assets/26d2c0d7-b7c8-4eee-8c6b-b291d1a0f7e0" />


The second screen and controller for the MiSTer FPGA. One program runs on the MiSTer
itself and serves a web app to any phone, tablet or computer on your network: see the TV
picture live on the phone, play with a touch gamepad, launch any game from your library
with box art, take screenshots and clips, manage saves, backups, manuals, wallpapers,
update_all, the TV menu, and more. Nothing to install on a PC.

This repository holds the downloads. The application source is not published.

## Install

1. Download `mister-control.sh` from this page and put it in `/media/fat/Scripts/` on
   your MiSTer (over Samba, FTP, or with the SD card in a computer).
2. On the TV, open the MiSTer menu, go to Scripts, and run `mister-control`.
   Or over SSH: `sh /media/fat/Scripts/mister-control.sh`
3. The script prints the address to open, for example `http://192.168.1.50:8110`.
   Open it on your phone. Settings > Network can show the address as a QR code on the TV.

The installer downloads the current release, checks it, installs to
`/media/fat/mister-control/`, starts the app now and at every boot
(`/media/fat/linux/user-startup.sh`), and sets `log_file_entry=1` in `MiSTer.ini`
(backup: `MiSTer.ini.mister-control.bak`). That setting makes the MiSTer write the
running game's path to `/tmp`, which is how the app knows what is playing.

The first install also downloads the offline game catalogue (150 MB) and a static
ffmpeg for live broadcasting (32 MB). Both are kept across updates.

## Update

Any of these:

- In the app: Settings > About > Install. The app checks this page once an hour.
- Run `mister-control` from the Scripts menu again.
- update_all: turn on "update_all" in Settings > About, or add this to `downloader.ini`:

```ini
[mister_control]
db_url = 'https://raw.githubusercontent.com/RemmyLee/mister-control-releases/main/db.json.zip'
```

## Files here

| File | What it is |
|---|---|
| Releases | `mister-control-<version>-armv7.zip`, `launchbox.db`, `ffmpeg-armhf` |
| `release.json` | the current version, URLs and SHA-256 checksums; read by the app and the installer |
| `db.json.zip` | the update_all downloader database |
| `files/` | the release's files one by one, for the downloader |
| `mister-control.sh` | the installer |

## Safety

The app listens on your LAN only and has no account or cloud side. Set a token
(`-token` or `MC_TOKEN` in `run.sh`) if other people share your network; the app can
then pair a phone with a 6-digit PIN. Live broadcasting sends video only where you
point it (an RTMP URL you enter); the stream key stays on the MiSTer.

`ffmpeg-armhf` is the static build from https://johnvansickle.com/ffmpeg/ (GPL v3), unchanged.
