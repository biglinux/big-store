#!/bin/bash
#
# BigLinux Store 
# www.biglinux.com.br
# By Bruno Gonçalves
# 11/01/2020
# License: GPL v2 or greater

#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store

TMP_FOLDER="/tmp/bigstore"
COUNT=0

rm -f ${TMP_FOLDER}/aurbuild.html
#  ./search_aur.py $@ >> ${TMP_FOLDER}/aurbuild.html
# mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html

OIFS=$IFS
IFS=$'\n'

for i  in  $(LANG=C yay --sortby popularity -Ssa --topdown $(echo $@ | sed "s| |\n|g") | awk 'ORS=NR%2?" ":"\n"'); do

    TITLE="$(echo "$i" | awk 'ORS=NR%2?" ":"\n"' | cut -f2-5 -d/ | cut -f1 -d" ")"

    if [ "$(grep "^${TITLE}$" '/usr/share/bigbashview/bcc/apps/big-store/aur_list.txt')" != "" ]; then
    
        TITLE_SIMPLE="$(echo "$TITLE" | cut -f1 -d"-")"
        DESCRIPTION="$(echo "$i" | awk -F"    " '{print $NF }')"
        INSTALLED="$(echo "$i"| grep '(Installed')"
        VERSION="$(echo "$i"| cut -f2 -d" ")"
        let COUNT=COUNT+1; 
        
        echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=$TITLE\">" >> ${TMP_FOLDER}/aurbuild.html
        echo '<div class="col s12 m6 l3"' >> ${TMP_FOLDER}/aurbuild.html

        if [ "$INSTALLED" = "" ]; then
            if [ "$(echo "$TITLE" | grep "$(echo "$@" | cut -f1 -d" ")")" != "" ]; then
                echo 'id="AurP2">' >> ${TMP_FOLDER}/aurbuild.html
            else
                echo 'id="AurP3">' >> ${TMP_FOLDER}/aurbuild.html
            fi
        else
            echo 'id="AurP1">' >> ${TMP_FOLDER}/aurbuild.html
        fi



        # Try enable icons
        # PKG_ICON="$(find icons/ /usr/share/app-info/icons/archlinux-arch-community/64x64/ /usr/share/app-info/icons/archlinux-arch-extra/64x64/ /var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/ -type f -iname "*${TITLE_SIMPLE}*" -print -quit)"

        echo '<div class="showapp">' >> ${TMP_FOLDER}/aurbuild.html
        
        if [ -e "icons/${TITLE}.png" ]; then
            echo "<div id=aur_icon><div class=icon_middle><img class=\"icon\" src=\"icons/${TITLE}.png\"></div>" >> ${TMP_FOLDER}/aurbuild.html
        else
            echo "<div id=aur_icon><div class=icon_middle><div class=avatar_aur>${TITLE:0:3}</div></div>" >> ${TMP_FOLDER}/aurbuild.html
        fi
        
        # echo '<div id=appstream_icon><img class="icon" loading="lazy" src="' "$PKG_ICON" '">' >> ${TMP_FOLDER}/aurbuild.html
        echo "<div id=aur_name><div id=limit_title_name>$TITLE</div>" >> ${TMP_FOLDER}/aurbuild.html
        echo "<div id=version>$VERSION</div></div></div>" >> ${TMP_FOLDER}/aurbuild.html
        
        SUMMARY_FILE="description/${TITLE}/$(echo $LANG | cut -f1 -d".")/summary"
        if [ -e "$SUMMARY_FILE" ]; then
            echo "<div id=box_aur_desc><div id=aur_desc>$(cat "$SUMMARY_FILE")</div></div>" >> ${TMP_FOLDER}/aurbuild.html
        else
            echo "<div id=box_aur_desc><div id=aur_desc>$DESCRIPTION</div></div>" >> ${TMP_FOLDER}/aurbuild.html
        fi

        if [ "$INSTALLED" = "" ]; then
            echo '<div id=aur_not_installed>' $"Instalar" '</div></a></div></div>' >> ${TMP_FOLDER}/aurbuild.html
        else
            echo '<div id=aur_installed>' $"Remover" '</div></a></div></div>' >> ${TMP_FOLDER}/aurbuild.html
        fi

        if [ "$COUNT" = "50" ]; then
            break
        fi
    fi
done

if [ "$COUNT" -gt "0" ]; then
        echo '<script>$(document).ready(function() {$("#box_aur").show();});</script>' >> ${TMP_FOLDER}/aurbuild.html
        echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >> ${TMP_FOLDER}/aurbuild.html
        mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html
else
        echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' > ${TMP_FOLDER}/aurbuild.html
        mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html
fi

echo "$COUNT" > "${TMP_FOLDER}/aur_number.html"

IFS=$OIFS
