#!/bin/bash

case $1 in
    pkg_not_installed)
		pacman -Flq "$2" | sed 's|^|/|'
    ;;

    pkg_installed)
        pacman -Qk "$2"
		pacman -Qlq "$2"
	;;

    pkg_installed_flatpak)
    echo "Folder base: $(flatpak info --show-location "$2")"
    find $(flatpak info --show-location "$2") | sed "s|$(flatpak info --show-location "$2")||g"
	;;
esac
