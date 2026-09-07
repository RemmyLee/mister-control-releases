#!/bin/sh
# Supervisor for mister-control. The MiSTer has no service manager, so a crashed
# or OOM-killed process used to stay dead until the next reboot. This loop
# restarts it, and writes its own pid so restart.sh can stop the loop first (a
# plain kill of the child would just be undone by this loop).
DIR=/media/fat/mister-control
BIN="$DIR/mister-control"
LOOP_PID=/tmp/mister-control-loop.pid
LOG="$DIR/mister-control.log"

echo $$ > "$LOOP_PID"

# Optional secrets (ScreenScraper credentials, etc.), not in git. Sourced so the
# MC_SS_* env vars reach the binary. Absent on a build without the feature.
[ -f "$DIR/screenscraper.env" ] && . "$DIR/screenscraper.env"
# Optional operator overrides (MC_LISTEN, MC_TLS_LISTEN, MC_MEMLIMIT_MB, MC_PPROF=1 ...),
# one KEY=value per line, exported to the binary. Absent on a normal install.
if [ -f "$DIR/env" ]; then
	set -a
	. "$DIR/env"
	set +a
fi

# Keep the log from growing without bound across restarts (no logrotate here).
if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 4000000 ]; then
	mv -f "$LOG" "$LOG.1"
fi

# Every exit is recorded for the app to report (Notifications) at its next
# start; the app deletes the file once it has read it.
RESTARTS="$DIR/restarts.log"

fast=0
while :; do
	echo "=== starting $(date)" >> "$LOG"
	start=$(date +%s)
	"$BIN" >> "$LOG" 2>&1
	code=$?
	now=$(date +%s)
	echo "=== exited with $code $(date)" >> "$LOG"
	echo "$now $code" >> "$RESTARTS"
	# A fast crash loop should not spin the CPU on a 2-core ARM board: after
	# three exits inside a minute, wait 30 s between tries (9,798 restarts at
	# 3 s each kept the box at load 6 for two days, 2026-09-07).
	if [ $((now - start)) -lt 60 ]; then fast=$((fast + 1)); else fast=0; fi
	if [ $fast -ge 3 ]; then sleep 30; else sleep 3; fi
done
