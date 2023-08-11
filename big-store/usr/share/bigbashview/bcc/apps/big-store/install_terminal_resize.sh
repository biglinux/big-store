#!/bin/bash
##################################
#  Author Create: Bruno Gonçalves (www.biglinux.com.br)
#  Author Modify: Rafael Ruscher (rruscher@gmail.com)
#  Create Date:    2020/01/11
#  Modify Date:    2022/05/09
#
#  Description: Big Store installing programs for BigLinux
#
#  Licensed by GPL V2 or greater
##################################
#Install .deb packages

STOP=0
while [ "$STOP" = "0" ]; do
	WINDOW_HEIGHT_DETECT="$(xwininfo -id $WINDOW_ID | grep Height: | sed 's|.* ||g')"
	WINDOW_WIDTH="$(xwininfo -id $WINDOW_ID | grep Width: | sed 's|.* ||g')"
	WIDTH_TERMINAL="$(echo "$WINDOW_WIDTH * 0.7 / 10" | bc | cut -f1 -d".")"
	MARGIN_LEFT="$(echo "$WINDOW_WIDTH * 0.15" | bc | cut -f1 -d".")"
	MARGIN_TOP="$(echo "$WINDOW_HEIGHT_DETECT * 0.5" $MARGIN_TOP_MOVE | bc | cut -f1 -d".")"
	xtermset -geom ${WIDTH_TERMINAL}x${WINDOW_HEIGHT}+${MARGIN_LEFT}+${MARGIN_TOP}
	sleep 1
	# if close bigbashview window, kill terminal too
	if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
		kill -9 $PID_TERM_BIG_STORE
		exit 0
	fi
done
