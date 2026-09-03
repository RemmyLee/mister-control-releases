#!/bin/sh
# MiSTer Control: install or update on this MiSTer.
#
# Put this file in /media/fat/Scripts and run it from the Scripts menu on the
# TV, or run it over SSH. It reads the release manifest, downloads the
# release, checks it, installs to /media/fat/mister-control, starts the
# service now and on every boot, and prints the address to open on a phone.
# Runs again to update. Needs: curl, unzip, sha256sum (all on MiSTer Linux).
#
#   sh mister-control.sh            install or update to the latest release
#   sh mister-control.sh --check    show the installed and latest versions only
#   sh mister-control.sh --force    reinstall the latest release even when it is installed
#
# MC_RELEASE_URL overrides the manifest (a test server, an older release).

RELEASE_URL="${MC_RELEASE_URL:-https://raw.githubusercontent.com/RemmyLee/mister-control-releases/main/release.json}"
SD=/media/fat
DIR=$SD/mister-control
WORK=$DIR/update
INI=$SD/MiSTer.ini
STARTUP=$SD/linux/user-startup.sh

# MiSTer's curl has no default CA bundle. update_all keeps a current one; the
# system one (2021) still verifies GitHub. SSL_CERT_FILE is read by curl.
for pem in "$SD/Scripts/.config/downloader/cacert.pem" /etc/ssl/certs/cacert.pem; do
	if [ -s "$pem" ]; then
		export SSL_CERT_FILE="$pem"
		break
	fi
done

fail() {
	echo "ERROR: $*" >&2
	exit 1
}

# field NAME: one value from the flat manifest (one "key": value per line).
field() {
	sed -n "s/^[[:space:]]*\"$1\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([^\",]*\)\"\{0,1\},\{0,1\}[[:space:]]*$/\1/p" "$WORK/release.json" | head -1
}

# fetch URL FILE SHA256 SIZE: download with a progress bar and verify.
fetch() {
	url=$1; out=$2; sha=$3; size=$4
	rm -f "$out"
	echo "Downloading $(basename "$out")"
	curl -fL --retry 3 --progress-bar -o "$out" "$url" || fail "download failed: $url"
	if [ -n "$size" ] && [ "$(wc -c < "$out")" -ne "$size" ]; then
		rm -f "$out"
		fail "$(basename "$out"): wrong size"
	fi
	got=$(sha256sum "$out" | cut -d' ' -f1)
	if [ "$got" != "$sha" ]; then
		rm -f "$out"
		fail "$(basename "$out"): checksum mismatch (the download is not the published file)"
	fi
}

installed_version() {
	[ -x "$DIR/mister-control" ] || { echo "none"; return; }
	v=$("$DIR/mister-control" -version 2>/dev/null)
	case "$v" in
	"") echo "unknown" ;;
	*) echo "$v" ;;
	esac
}

mkdir -p "$WORK" || fail "cannot write to $DIR"
echo "Reading $RELEASE_URL"
curl -fsSL --retry 3 -o "$WORK/release.json" "$RELEASE_URL" || fail "cannot read the release manifest"
LATEST=$(field version)
[ -n "$LATEST" ] || fail "the release manifest has no version"
CUR=$(installed_version)
echo "Installed: $CUR"
echo "Latest:    $LATEST"

if [ "${1:-}" = "--check" ]; then
	rm -rf "$WORK"
	exit 0
fi
if [ "$CUR" = "$LATEST" ] && [ "${1:-}" != "--force" ]; then
	echo "Already up to date."
	rm -rf "$WORK"
	exit 0
fi

# 1. The release zip: binary, web/, scripts, core-options data.
ZIP="$WORK/$(basename "$(field zip_url)")"
fetch "$(field zip_url)" "$ZIP" "$(field zip_sha256)" "$(field zip_size)"
rm -rf "$WORK/stage"
mkdir -p "$WORK/stage"
unzip -oq "$ZIP" -d "$WORK/stage" || fail "unzip failed"
[ -f "$WORK/stage/mister-control" ] || fail "the release zip has no mister-control binary"
[ -f "$WORK/stage/web/index.html" ] || fail "the release zip has no web/index.html"

# 2. The offline game catalogue (large, rarely changes): only when missing or
#    a different size than the manifest says.
LB_URL=$(field launchbox_url)
LB_SIZE=$(field launchbox_size)
if [ -n "$LB_URL" ]; then
	have=0
	[ -f "$DIR/data/launchbox.db" ] && have=$(wc -c < "$DIR/data/launchbox.db")
	if [ "$have" -ne "${LB_SIZE:-0}" ]; then
		fetch "$LB_URL" "$WORK/launchbox.db" "$(field launchbox_sha256)" "$LB_SIZE"
	fi
fi

# 3. ffmpeg for live broadcasting (optional, only when missing).
FF_URL=$(field ffmpeg_url)
if [ -n "$FF_URL" ] && [ ! -x "$DIR/ffmpeg" ]; then
	fetch "$FF_URL" "$WORK/ffmpeg" "$(field ffmpeg_sha256)" "$(field ffmpeg_size)"
fi

# 4. Swap the files in. Renames keep the running binary's inode alive, and the
#    previous copies stay as .prev until the next update.
echo "Installing to $DIR"
mkdir -p "$DIR/data" "$DIR/media-cache"
rm -rf "$DIR/mister-control.prev" "$DIR/web.prev"
[ -f "$DIR/mister-control" ] && mv -f "$DIR/mister-control" "$DIR/mister-control.prev"
mv -f "$WORK/stage/mister-control" "$DIR/mister-control" || fail "cannot install the binary"
chmod +x "$DIR/mister-control"
[ -d "$DIR/web" ] && mv -f "$DIR/web" "$DIR/web.prev"
mv -f "$WORK/stage/web" "$DIR/web" || fail "cannot install web/"
for f in run.sh restart.sh mister-control.sh; do
	[ -f "$WORK/stage/$f" ] && cp -f "$WORK/stage/$f" "$DIR/$f" && chmod +x "$DIR/$f"
done
if [ -d "$WORK/stage/data/confstr" ]; then
	mkdir -p "$DIR/data/confstr"
	cp -f "$WORK/stage/data/confstr/"* "$DIR/data/confstr/"
fi
[ -f "$WORK/launchbox.db" ] && mv -f "$WORK/launchbox.db" "$DIR/data/launchbox.db"
if [ -f "$WORK/ffmpeg" ]; then
	mv -f "$WORK/ffmpeg" "$DIR/ffmpeg"
	chmod +x "$DIR/ffmpeg"
fi
# The Scripts menu copy: the next update can start from the TV.
if [ -d "$SD/Scripts" ] && [ -f "$DIR/mister-control.sh" ]; then
	cp -f "$DIR/mister-control.sh" "$SD/Scripts/mister-control.sh"
fi
rm -rf "$WORK"

# 5. Start on boot. user-startup.sh survives update_all (the firmware runs it
#    at boot and the updater never touches it).
[ -f "$STARTUP" ] || printf '#!/bin/sh\n' > "$STARTUP"
if ! grep -qF "mister-control/run.sh" "$STARTUP"; then
	printf '%s\n' "[ -x /media/fat/mister-control/run.sh ] && setsid sh /media/fat/mister-control/run.sh > /dev/null 2>&1 &" >> "$STARTUP"
fi
chmod +x "$STARTUP"

# 6. log_file_entry=1 makes the firmware write the running game's path to
#    /tmp, which is how the app knows what is playing. Backup first.
if [ -f "$INI" ] && ! grep -q '^[[:space:]]*log_file_entry[[:space:]]*=[[:space:]]*1[[:space:]]*$' "$INI"; then
	cp -f "$INI" "$INI.mister-control.bak"
	if grep -q '^[[:space:]]*log_file_entry[[:space:]]*=' "$INI"; then
		sed -i 's/^[[:space:]]*log_file_entry[[:space:]]*=.*$/log_file_entry=1/' "$INI"
	elif grep -q '^\[MiSTer\]' "$INI"; then
		sed -i 's/^\[MiSTer\]\r\{0,1\}$/&\nlog_file_entry=1/' "$INI"
	else
		printf '\nlog_file_entry=1\n' >> "$INI"
	fi
	echo "MiSTer.ini: set log_file_entry=1 (backup: MiSTer.ini.mister-control.bak)"
fi

# 6b. debug=2 makes the firmware write its own printf output to /tmp/debug.txt
#     (cfg.cpp:436-443). The app reads that file to confirm a cheat toggle. It
#     applies at the next core load. Same backup rule as above.
if [ -f "$INI" ] && ! grep -q '^[[:space:]]*debug[[:space:]]*=[[:space:]]*2[[:space:]]*$' "$INI"; then
	[ -f "$INI.mister-control.bak" ] || cp -f "$INI" "$INI.mister-control.bak"
	if grep -q '^[[:space:]]*debug[[:space:]]*=' "$INI"; then
		sed -i 's/^[[:space:]]*debug[[:space:]]*=.*$/debug=2/' "$INI"
	elif grep -q '^\[MiSTer\]' "$INI"; then
		sed -i 's/^\[MiSTer\]\r\{0,1\}$/&\ndebug=2/' "$INI"
	else
		printf '\ndebug=2\n' >> "$INI"
	fi
	echo "MiSTer.ini: set debug=2 (backup: MiSTer.ini.mister-control.bak)"
fi

# 7. Start (or restart) the service.
sh "$DIR/restart.sh"

IP=$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.*src \([0-9.]*\).*/\1/p' | head -1)
HOST=$(hostname 2>/dev/null)
echo
echo "MiSTer Control $LATEST is installed."
[ -n "$IP" ] && echo "Open on a phone:  http://$IP:8110"
[ -n "$HOST" ] && echo "or:               http://$HOST.local:8110"
echo "Settings > Network in the app can show this address as a QR code on the TV."
exit 0
