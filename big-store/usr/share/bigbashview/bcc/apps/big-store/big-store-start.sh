#!/bin/bash
#
# BigLinux Store 
# www.biglinux.com.br
# By Bruno Gonçalves
# 07/09/2020
# License: GPL v2 or greater 

cd /usr/share/bigbashview/bcc/apps/big-store/

HOME_FOLDER="$HOME/.bigstore"
TMP_FOLDER="/tmp/bigstore"

if [ ! -e "$HOME_FOLDER" ]; then
    ./update_cache_complete
else
    mkdir -p "$HOME_FOLDER"
fi


mkdir -p "$TMP_FOLDER"

# Save dynamic screenshot resolution
echo "$(xrandr | grep primary | sed 's|.*primary ||g;s|+.*||g;s|.*x||g') / 2" | bc > ${TMP_FOLDER}/screenshot-resolution.txt

/usr/share/bigbashview/bcc/apps/big-store/update_cache_flatpak &

bigbashview -w maximized index.sh.htm -i img/icon.png
