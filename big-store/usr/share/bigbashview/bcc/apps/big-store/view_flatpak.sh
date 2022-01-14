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

# Read installed packages
## portuguese
# Le os pacotes instalados em flatpak
FLATPAK_INSTALLED_LIST="|$(flatpak list | cut -f2 -d$'\t' | tr '\n' '|')"

VERSION=$"Versão: "
PACKAGE=$"Pacote: "
NOT_VERSION=$"Não informada"
HOME_FOLDER="$HOME/.bigstore"
TMP_FOLDER="/tmp/bigstore"


# Read parameter and use as $search
## portuguese
# Le o parametro passado via terminal e cria a variavel $search
search="$*"

# Change delimiter
## portuguese
# Muda o delimitador para somente quebra de linha
OIFS=$IFS
IFS=$'\n'

# Start function to turn possible uses assincronous mode
## portuguese
# Inicia uma função para possibilitar o uso em modo assíncrono

    readarray -t -d"|" myarray <<< "$(grep "|$search|" ~/.bigstore/flatpak.cache)"

    PKG_NAME="${myarray[0]}"
    PKG_DESC="${myarray[1]}"
    PKG_ID="${myarray[2]}"
    PKG_VERSION="${myarray[3]}"
    PKG_STABLE="${myarray[4]}"
    PKG_REMOTE="${myarray[5]}"
    PKG_UPDATE="${myarray[6]}"

    # Select xml file to work
    ## portuguese
    # Seleciona o arquivo xml para filtrar os dados
    
    PKG_XML_APPSTREAM="/var/lib/flatpak/appstream/$PKG_REMOTE/x86_64/active/appstream.xml"

    PKG_VERSION_ORIG="$PKG_VERSION"
    if [ "$PKG_VERSION" = "" ]; then
        PKG_VERSION="$NOT_VERSION"
    fi

    # ICON
    # Example to run
    # awk /\<id\>com.eduke32.EDuke32\<\\/id\>/,/\<\\/component\>/ /var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml | grep -m1 -e icon -e cached | sed 's|.*">||g;s|</icon>||g'
    PKG_ICON=""
    
    # Search icon
    PKG_ICON="$(find /var/lib/flatpak/appstream/  -type f -iname "$PKG_ID.png" -print -quit)"
    
    # If not found try another way
    if [ "$PKG_ICON" = "" ]; then

        # If cached icon not found, try online
        PKG_ICON="$(awk /\<id\>$PKG_ID\<\\/id\>/,/\<\\/component\>/ $PKG_XML_APPSTREAM | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g')"

        
            # If online icon not found, try another way
            if [ "$PKG_ICON" = "" ]; then
                PKG_ICON="$(awk /\<id\>$PKG_ID.desktop\<\\/id\>/,/\<\\/component\>/ $PKG_XML_APPSTREAM | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g')"
            fi

    fi






# cat >>  ${TMP_FOLDER}/flatpakbuild.html << EOF
# <a href="flatpak_view.sh?$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp tooltipped" data-position="top" data-tooltip="${PACKAGE}$PKG_ID<br><br>${VERSION}$PKG_VERSION"><div id=flatpak_package></div><div id=flatpak_icon><img height="64" width="64" loading="lazy" src="$PKG_ICON"><div id=version>$PKG_VERSION_ORIG</div></div><div id=flatpak_name>$PKG_NAME</div><div id=flatpak_desc>$PKG_DESC</div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div></div>
# EOF



            # If all fail, use generic icon
#             if [ "$PKG_ICON" = "" ] || [ "$(echo "$PKG_ICON" | LC_ALL=C grep -i -m1 'type=')" != "" ] || [ "$(echo "$PKG_ICON" | LC_ALL=C grep -i -m1 '<description>')" != "" ]; then
# cat << EOF
# <a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><div class=icon_middle><div class=avatar_flatpak>${PKG_NAME:0:3}</div></div></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div></div>
# EOF
#             else
# cat << EOF
# <a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div></div>
# EOF
#             fi

    

    
    
    
    
    

echo "<div id=box_flatpak_install><div id=title_flatpak_install>
<div id=button_flatpak class=\"tooltipped\" data-position=\"left\" data-tooltip=\"" $"Informações sobre programas nativos" "\">"

echo $"Programas Flatpak"

echo "</div></div><div id=content_flatpak_install>
<div id=titleBar>
<div id=title>
<img class=\"icon_view\" src=\"$PKG_ICON\">"

echo "<div id=titleName>$PKG_NAME</div></div></div>"

echo "<div id=description>$PKG_DESC</div></div>"

echo '<div class="row center">'


    # Verify if package are installed
    if [ "$(echo "$FLATPAK_INSTALLED_LIST" | LC_ALL=C grep -i -m1 "|$PKG_ID|")" != "" ]; then
        if [ "$(echo "$PKG_UPDATE" | tr -d '\n')" != "" ]; then
            echo "<button class=\"btn btnSpace waves-effect waves-light yellow darken-4\" type=\"submit\" name=\"action\" onclick=\"disableBodyFlatpakInstall();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_install=y'\">"
            echo $"Atualizar" "</button>"
            echo "<button class=\"btn btnSpace waves-effect waves-light blue darken-3\" type=\"submit\" name=\"action\" onclick=\"_run( 'flatpak run $search' )\">" $"Executar" "</button>"
        else
            echo "<button class=\"btn btnSpace waves-effect waves-light red accent-4\" type=\"submit\" name=\"action\" onclick=\"disableBodyFlatpakRemove();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_remove=y'\">"
            echo $"Remover" "</button>"
            echo "<button class=\"btn btnSpace waves-effect waves-light blue darken-3\" type=\"submit\" name=\"action\" onclick=\"_run( 'flatpak run $search' )\">" $"Executar" "</button>"
        fi
    else
        echo "<button class=\"btn btnSpace waves-effect waves-light green accent-4\" type=\"submit\" name=\"action\" onclick=\"disableBodyFlatpakInstall();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_install=y'\">"
        echo $"Instalar" "</button>"
    fi


















echo "<div class=grid-container>
<div class=gridLeft> " $"Pacote:" " </div>"

echo "<div class=gridRight> $search </div></div>"

echo "<div class=grid-container>
<div class=gridLeft> " $"Versão disponível:" " </div>"

echo "<div class=gridRight> $PKG_VERSION_ORIG
 </div></div>"
 
echo "<div class=grid-container>
<div class=gridLeft> " $"Repositório:" " </div>"

echo "<div class=gridRight> flathub </div></div>"
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



IFS=$OIFS


