# MiSTer Control

MiSTer Control turns your phone into a second screen and a controller for the
[MiSTer FPGA](https://mister-devel.github.io/MkDocs_MiSTer/).

It is one program that runs on the MiSTer and hosts a web page. Open that page on your phone,
tablet, or computer and you get the game on a screen in your hand, a touch pad to play it with, and
your whole game library with the box art. You never install anything on a PC. There is no account
to make and nothing talks to a cloud.

![Home on a laptop](shots/home-desktop.png)

This repository is where you download it. The source code for the app is not public.

## Install

1. Grab **`mister-control.sh`** from the file list above and drop it in `/media/fat/Scripts/` on
   your MiSTer. Samba, FTP, or the SD card in a computer all work.
2. On the TV, open the MiSTer menu, go to **Scripts**, and run **`mister-control`**. If you would
   rather use SSH: `sh /media/fat/Scripts/mister-control.sh`
3. It installs itself, starts up, and tells you the address to open.

Behind the scenes the script grabs the latest build, checks it, and installs it to
`/media/fat/mister-control/`. It starts the app now and again on every boot. It also flips two
settings in `MiSTer.ini` and keeps a backup at `MiSTer.ini.mister-control.bak`. One,
`log_file_entry=1`, makes the MiSTer write down which game is running so the app can tell what you
are playing. The other, `debug=2`, makes the MiSTer log its own messages so the app can see when a
cheat actually turns on. Both take effect the next time you load a core.

The first run also pulls down the offline game catalogue (box art and details, about 150 MB) and a
copy of ffmpeg for the live broadcast feature (about 32 MB). Updates keep both.

## Open it on your phone

The app runs on port **8110**. On your phone's browser, go to `http://<your-MiSTer-IP>:8110`, for
example `http://192.168.1.50:8110`.

You don't have to hunt for the IP. The install script prints the address, and so does the MiSTer's
own menu. Inside the app, **Settings > Network and access** puts a QR code up on the TV, so you can
just point your camera at it. Once it is open, use "Add to Home Screen" and it runs full screen
like a real app.

Sharing your network with other people? Set a token with `-token`, or `MC_TOKEN` in `run.sh`. After
that a phone has to pair once with a 6-digit PIN.

## Features

### Home and the live picture

Home shows the game you are playing right now, and the picture is live inside the tile. Your recent
games sit next to it. Tap any of them to jump in. If you are on an MC core (more on that below), the
tile even shows things like your world, lives, and score.

<img src="shots/home-playing-phone.png" width="270" alt="Home on a phone with the game live in the tile">

### Play on your phone

Tap the game that is running and a gamepad slides up under the live picture. There are Capture and
Clip buttons right on the screen.

<img src="shots/controller-phone.png" width="270" alt="Touch gamepad with the live picture">

### Library

Look through every system on your card. Each game shows its box art, the year, who made it, and its
genre. You can search, star the ones you love, and put games into collections. Filters let you
narrow by first letter, region, genre, decade, or how many players it takes. Most of the art is
already on the card. When a game is missing its cover, you can grab it from ScreenScraper using your
own account.

<img src="shots/library-tas-filter-phone.png" width="270" alt="Library with box art and filters">

### Game sheet

Press and hold a game to bring up its sheet. From there you can start it, restart it, star it, add
it to a collection, pin it to the TV menu, or fix its title and year. There are handy links out to
GameFAQs, StrategyWiki, Wikipedia, and a longplay video. When a game is running, the sheet also has
its save state slots (save and load right from your phone), its cheats, its core options, and how
long you have spent in it.

<img src="shots/gamesheet-cheats-phone.png" width="270" alt="Cheat switches on the game sheet"> <img src="shots/gamesheet-live-phone.png" width="270" alt="Live machine state on the game sheet">

### MC-NES, our own NES core

Open **Settings > Install** and you can add MC-NES. It is our own build of the NES core that sits
right beside the stock one and uses the same games, saves, and cheats. The difference is that it
tells the app what the game is doing on every single frame: the memory, the CPU, the controller.
That is what feeds the live values on the game sheet and under the Home tile.

<img src="shots/settings-install-phone.png" width="270" alt="Installing the MC-NES core">

### TAS playback

Here is the fun part. On MC-NES the FPGA can play back a tool-assisted speedrun on your TV. The app
takes the checksum of your ROM, finds the exact matching version on
[TASVideos](https://tasvideos.org), and shows you every run people have published for it. Pick one,
it downloads to the card, and the core plays the inputs out frame by frame with the hardware keeping
time. The Library flags every game you own that has a run available. If you have your own `.fm2`
file, you can drop that in too.

<img src="shots/gamesheet-tasvideos-phone.png" width="270" alt="TASVideos runs for the running ROM">

### And the rest

- **Album**: every screenshot the MiSTer took and every clip you grabbed, in one place, tagged by
  system.
- **Manuals**: thousands of game manuals are catalogued, but nothing lands on your card until you
  ask for a specific one.
- **Saves**: pull your SRAM saves off, or put them back, one core at a time.
- **Install**: a shop of cores, homebrew, wallpaper, and scripts. It goes through the MiSTer's own
  downloader, so update_all still owns your files.
- **TV menu editor**: rearrange the folders and shortcuts on the TV menu.
- **Quick settings**: hold the Home button for volume, mute, a screenshot, the OSD, reset, and
  Bluetooth pairing, without dropping out of your game.
- **Music**, **wallpaper**, **backups**, **automation**, and a live broadcast to an RTMP URL of
  your choosing.

<img src="shots/play-activity-phone.png" width="270" alt="Play activity and stats"> <img src="shots/album-phone.png" width="270" alt="Screenshot and clip album"> <img src="shots/quick-settings-phone.png" width="270" alt="Quick settings panel">

## Updating

Take your pick:

- In the app, go to **Settings > About > Install**. It checks here once an hour anyway.
- Run `mister-control` from the Scripts menu again.
- Let update_all do it. Turn on "update_all" in Settings > About, or add this to `downloader.ini`:

```ini
[mister_control]
db_url = 'https://raw.githubusercontent.com/RemmyLee/mister-control-releases/main/db.json.zip'
```

## What is in this repository

| File | What it is |
|---|---|
| Releases | `mister-control-<version>-armv7.zip`, `launchbox.db`, `ffmpeg-armhf` |
| `release.json` | the current version, its URLs and SHA-256 checksums, read by the app and the installer |
| `db.json.zip` | the update_all database |
| `cores/db.json.zip` | the update_all database for the MC cores, like MC-NES |
| `catalog.json` | the list behind the in-app Install page |
| `files/` | the release broken into single files for the downloader |
| `mister-control.sh` | the installer |

## Safety

The app only listens on your own network. There is no account and no cloud. If you share the
network with other people, set a token as described above. The live broadcast only sends video to
the RTMP URL you type in, and your stream key never leaves the MiSTer.

`ffmpeg-armhf` is the unmodified static build from https://johnvansickle.com/ffmpeg/ (GPL v3).
