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


OIFS=$IFS
IFS=$'\n'

if [ "$ACTION" = "reinstall_pamac" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pamac reinstall $PACKAGE_NAME --no-confirm
fi

if [ "$ACTION" = "install_flatpak" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    flatpak install --or-update $REPOSITORY $PACKAGE_ID -y
    if [ ! -e "$HOME/.bigstore/disable_flatpak_unused_remove" ]; then
        flatpak uninstall --unused -y
    fi
    ./update_cache_flatpak
fi

if [ "$ACTION" = "remove_flatpak" ]; then
   MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    flatpak remove $PACKAGE_ID -y
    if [ ! -e "$HOME/.bigstore/disable_flatpak_unused_remove" ]; then
        flatpak uninstall --unused -y
    fi
    ./update_cache_flatpak
fi

if [ "$ACTION" = "install_snap" ]; then
MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &

    if [ ! -e "$HOME/.bigstore/disable_snap_unused_remove" ]; then
        pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $(pwd)/snap_clean.sh install $PACKAGE_NAME
    else
        snap install $PACKAGE_NAME
    fi
fi

if [ "$ACTION" = "remove_snap" ]; then
MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &

    if [ ! -e "$HOME/.bigstore/disable_snap_unused_remove" ]; then
        pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $(pwd)/snap_clean.sh remove $PACKAGE_NAME
    else
        snap remove $PACKAGE_NAME
    fi

fi

if [ "$ACTION" = "update_pacman" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pacman -Syy --noconfirm
fi

if [ "$ACTION" = "update_mirror" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $(pwd)/run-pacman-mirror
fi

if [ "$ACTION" = "update_keys" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --fix-keys
fi

if [ "$ACTION" = "force_upgrade" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --upgrade-now
fi

if [ "$ACTION" = "reinstall_allpkg" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $(pwd)/reinstall_allpkg.sh
fi

if [ "$ACTION" = "system_upgrade" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac update --no-confirm
fi

if [ "$ACTION" = "system_upgradetotal" ]; then
    MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$" WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bigsudo pacman -Syyu --noconfirm
fi

if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
    kill -9 $PID_BIG_DEB_INSTALLER
    exit 0
fi

IFS=$OIFS
