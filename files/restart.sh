#!/bin/sh
# Restart mister-control on the device. Run on the MiSTer itself.
# Stops the supervisor loop FIRST, then the server, then starts a new loop fully
# detached so the SSH session returns. busybox has no pkill, and matching by
# process name self-matches this script, so both are stopped by pid file.
DIR=/media/fat/mister-control
LOOP_PID=/tmp/mister-control-loop.pid
APP_PID=/tmp/mister-control.pid

stop_pidfile() {
	[ -f "$1" ] || return 0
	p=$(cat "$1" 2>/dev/null)
	[ -n "$p" ] && kill "$p" 2>/dev/null
	rm -f "$1"
}

stop_pidfile "$LOOP_PID"   # first, or it would immediately respawn the server
stop_pidfile "$APP_PID"
sleep 1
# Anything left over from an older install or a lost pid file.
for p in $(ps w | grep '[m]ister-control/mister-control' | awk '{print $1}'); do
	kill "$p" 2>/dev/null
done
sleep 1

setsid sh "$DIR/run.sh" >/dev/null 2>&1 </dev/null &
sleep 2
if [ -f "$APP_PID" ]; then
	echo "mister-control restarted (pid $(cat "$APP_PID"))"
else
	echo "mister-control did not report a pid, check $DIR/mister-control.log"
fi
exit 0
