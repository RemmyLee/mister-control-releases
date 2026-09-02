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

# Keep the log from growing without bound across restarts (no logrotate here).
if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt 4000000 ]; then
	mv -f "$LOG" "$LOG.1"
fi

while :; do
	echo "=== starting $(date)" >> "$LOG"
	"$BIN" >> "$LOG" 2>&1
	code=$?
	echo "=== exited with $code $(date)" >> "$LOG"
	# A fast crash loop should not spin the CPU on a 2-core ARM board.
	sleep 3
done
