#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/install_terminal.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2022/01/11
#  Altered: 2023/08/11
#
#  Copyright (c) 2023-2023, Vilmar Catafesta <vcatafesta@gmail.com>
#                2022-2023, Bruno Gonçalves <www.biglinux.com.br>
#                2022-2023, Rafael Ruscher <rruscher@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

APP="${0##*/}"
_VERSION_="1.0.0-20230811"
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
BOOTLOG="/tmp/bigcontrolcenter-$USER-$(date +"%d%m%Y").log"
LOGGER='/dev/tty8'
[[ -f "${LIBRARY}/bcclib.sh" ]] && source "${LIBRARY}/bcclib.sh"
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

OIFS=$IFS
IFS=$'\n'

if [[ -n "$ACTION" ]]; then
	MARGIN_TOP_MOVE="-90"
	WINDOW_HEIGHT=12
	PID_BIG_DEB_INSTALLER="$$"
	WINDOW_ID="$WINDOW_ID"
	TERMINAL_RESIZE="./install_terminal_resize.sh"
	SNAP_CLEAN_SCRIPT="./snap_clean.sh"
	eval $TERMINAL_RESIZE

	case "$ACTION" in
	"reinstall_pamac") pamac reinstall $PACKAGE_NAME --no-confirm ;;
	"install_flatpak")
		flatpak install --or-update $REPOSITORY $PACKAGE_ID -y
		if [ ! -e "$HOME/.bigstore/disable_flatpak_unused_remove" ]; then
			flatpak uninstall --unused -y
		fi
		sh_update_cache_flatpak
		;;
	"remove_flatpak")
		flatpak remove $PACKAGE_ID -y
		if [ ! -e "$HOME/.bigstore/disable_flatpak_unused_remove" ]; then
			flatpak uninstall --unused -y
		fi
		sh_update_cache_flatpak
		;;
	"install_snap")
		if [ ! -e "$HOME/.bigstore/disable_snap_unused_remove" ]; then
			pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $SNAP_CLEAN_SCRIPT install $PACKAGE_NAME
		else
			snap install $PACKAGE_NAME
		fi
		;;
	"remove_snap")
		if [ ! -e "$HOME/.bigstore/disable_snap_unused_remove" ]; then
			pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $SNAP_CLEAN_SCRIPT remove $PACKAGE_NAME
		else
			snap remove $PACKAGE_NAME
		fi
		;;
	"update_pacman")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pacman -Syy --noconfirm ;;
#	"update_mirror")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY ./run-pacman-mirror ;;
	"update_mirror")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY sh_run_pacman_mirror ;;
	"update_keys")         pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --fix-keys ;;
	"force_upgrade")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --upgrade-now ;;
	"reinstall_allpkg")    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY ./reinstall_allpkg.sh ;;
	"system_upgrade")      pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac update --no-confirm ;;
	"system_upgradetotal") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bigsudo pacman -Syyu --noconfirm ;;
	esac
fi

if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
	kill -9 $PID_BIG_DEB_INSTALLER
	exit 0
fi

IFS=$OIFS
