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

readarray -t -d"|" myarray <<<"$(grep "|$search|" ~/.bigstore/flatpak.cache)"

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
PKG_ICON="$(find /var/lib/flatpak/appstream/ -type f -iname "$PKG_ID.png" -print -quit)"

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
<div id=button_flatpak class=\"tooltipped\" data-position=\"left\" data-tooltip=\"" $ABOUT_FLATPAK "\">"
echo '<svg role="img" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg" style="width:20px;margin-right:1px;margin-left:5px;"><path fill="var(--text-a-color)" d="m 200,5.9523902 c -8.98514,0 -17.97169,2.3280645 -26.03677,6.9844298 L 51.016633,83.920269 C 34.886486,93.233022 24.979868,110.38745 24.979868,129.01293 v 141.97046 c 0,18.62546 9.906618,35.77989 26.036765,45.09264 l 122.946597,70.98701 c 16.13013,9.31276 35.9434,9.31276 52.07354,0 l 122.94659,-70.98701 c 16.13016,-9.31275 26.03677,-26.46718 26.03677,-45.09264 V 129.01293 c 0,-18.62548 -9.90661,-35.779908 -26.03677,-45.092661 L 226.03677,12.93682 C 217.9717,8.2804547 208.98514,5.9523902 200,5.9523902 Z m 0,38.1331378 c 2.41371,0 4.82858,0.621233 6.97729,1.861803 l 122.94663,70.983449 c 2.14873,1.24057 3.89441,3.02162 5.10127,5.11195 L 200,199.99993 v 155.91086 c -2.41371,0 -4.82859,-0.62123 -6.97731,-1.86182 L 70.07608,283.06553 c -4.297468,-2.48115 -6.977319,-7.11987 -6.977319,-12.08214 V 129.01293 c 0,-2.48114 0.669184,-4.87986 1.876048,-6.9702 L 200,199.99993 Z"/></svg> '
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
