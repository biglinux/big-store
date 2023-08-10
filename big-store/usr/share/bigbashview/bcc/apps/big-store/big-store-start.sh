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

#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store

if [[ $(ps -aux | grep Big-Store | grep bigbashview) ]]; then
    kdialog --passivepopup $"Big-Store está aberta."
    exit
fi

cd /usr/share/bigbashview/bcc/apps/big-store/

HOME_FOLDER="$HOME/.bigstore"
TMP_FOLDER="/tmp/bigstore"


if [[ $(find "$HOME/.bigstore/snap.cache" -mtime +1 -print) ]] || [ ! -e "$HOME/.bigstore/snap.cache" ] ; then
  ./update_cache_snap &
fi

if [[ $(find "$HOME/.bigstore/flatpak.cache" -mtime +1 -print) ]] || [ ! -e "$HOME/.bigstore/flatpak.cache" ] ; then
  ./update_cache_flatpak &
fi


TITLE=$"Big-Store"

mkdir -p "$TMP_FOLDER"

# Save dynamic screenshot resolution
echo "$(xrandr | grep primary | sed 's|.*primary ||g;s|+.*||g;s|.*x||g') / 2" | bc > ${TMP_FOLDER}/screenshot-resolution.txt

/usr/share/bigbashview/bcc/apps/big-store/update_cache_flatpak &

if [ "$1" != "" ]; then
    if [ "$1" = "category" ]; then
      QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized index.sh.htm?category="$2" -i icon.svg
    elif [ "$1" = "appstream" ]; then
      QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized view_appstream.sh.htm?pkg_name="$2" -i icon.svg
    elif [ "$1" = "aur" ]; then
      QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized view_aur.sh.htm?pkg_name="$2" -i icon.svg
    elif [ "$1" = "flatpak" ]; then
      QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized view_flatpak.sh.htm?pkg_name="$2" -i icon.svg
    elif [ "$1" = "snap" ]; then
      QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized view_snap.sh.htm?pkg_id="$2" -i icon.svg
    else
      QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized index.sh.htm?search="$1" -i icon.svg
    fi
else
    QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview  -n "$TITLE" -w maximized index.sh.htm -i icon.svg
fi

# Open Store searching for gimp
# big-store gimp

# Show Native page of gimp
# big-store appstream gimp

# Show AUR page of jre8
# big-store aur jre8

# Show Snap page of Gimp
# big-store snap KDHYbyuzZukmLhiogKiUksByRhXD2gYV

# Show Flatpak page of Gimp
# big-store flatpak org.gimp.GIMP
