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

# Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store

install_text=$"Instalar"
remove_text=$"Remover"

declare -i n=1
declare -g -i total=0

TMP_FOLDER="/tmp/bigstore-$USER"

rm -f ${TMP_FOLDER}/aurbuild.html

# LANG=C yay --sortby popularity -Ssa --singlelineresults --topdown $(echo $@ | sed "s| |\n|g")
IFS=$'\n'
# for line in $(LC_ALL=C yay -Ssa $* --sortby popularity --topdown ); do
for line in $(LC_ALL=C paru -Ssa $* --limit 60 --sortby popularity --searchby name-desc); do

    if [ $n = 1 ]; then
        n+=1
        pkg=${line#aur/}
        pkg=${pkg%% *}
        pkgicon=${pkg//-bin}
        pkgicon=${pkgicon//-git}
        pkgicon=${pkgicon//-beta}
        title=${pkg//-/ }
        unset title_uppercase_first_letter
        
        IFS=' '; for word in $title; do

            title_uppercase_first_letter+=" ${word^}"
        done
        IFS=$'\n'
        
        version=${line#* }
        version=${version%% *}
        
        if [[ $line = *' [Installed]'* ||  $line = *'Installed'* ]]; then
            button="<div id=aur_installed>$remove_text</div>"
            aur_priority="AurP1"
        else
            button="<div id=aur_not_installed>$install_text</div>"
            if [[ "$1" =~ .*"$title".* ]]; then
                aur_priority="AurP2"
            else
                aur_priority="AurP3"            
            fi
        fi

        if [ -e "icons/$pkgicon.png" ]; then
            icon="<img class=\"icon\" src=\"icons/$pkgicon.png\">"
        elif [ -e "/usr/share/bigbashview/bcc/apps/big-store/description/$pkgicon/flatpak_icon.txt" ]; then
            
            if [ -e "$(</usr/share/bigbashview/bcc/apps/big-store/description/$pkgicon/flatpak_icon.txt)" ]; then
                icon="<img class=\"icon\" src=\"$(</usr/share/bigbashview/bcc/apps/big-store/description/$pkgicon/flatpak_icon.txt)\">"
            else
                icon="<div class=avatar_aur>${pkgicon:0:3}</div>"
            fi
        else
            icon="<div class=avatar_aur>${pkgicon:0:3}</div>"
        fi

    else
        n=1
        total+=1
        if [ -e "description/$pkg/pt_BR/summary" ]; then
            summary=$(<description/$pkg/pt_BR/summary)
        else
            summary=$line
        fi
        # Generate HTML output
        echo "<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=$pkg\">" >> "$TMP_FOLDER/aurbuild.html"
        echo "<div class=\"col s12 m6 l3\" id=$aur_priority>" >> "$TMP_FOLDER/aurbuild.html"
        echo "<div class=\"showapp\">" >> "$TMP_FOLDER/aurbuild.html"
        echo "<div id=aur_icon><div class=icon_middle>$icon</div>" >> "$TMP_FOLDER/aurbuild.html"
        echo "<div id=aur_name><div id=limit_title_name>$title_uppercase_first_letter</div>" >> "$TMP_FOLDER/aurbuild.html"
        echo "<div id=version>$version</div></div></div>" >> "${TMP_FOLDER}/aurbuild.html"
        echo "<div id=box_aur_desc><div id=aur_desc>$summary</div></div>" >> "$TMP_FOLDER/aurbuild.html"
        echo "$button</a></div></div>" >> "$TMP_FOLDER/aurbuild.html"
    fi


done

echo "$total" > "$TMP_FOLDER/aur_number.html"

if [ $total -gt 0 ]; then
    echo '<script>$(document).ready(function() {$("#box_aur").show();});</script>' >> "$TMP_FOLDER/aurbuild.html"
fi

echo '<script>document.getElementById("aur_icon_loading").innerHTML = ""; runAvatarAur();</script>' >> "$TMP_FOLDER/aurbuild.html"

# Move temporary HTML file to final location
mv $TMP_FOLDER/aurbuild.html $TMP_FOLDER/aur.html
