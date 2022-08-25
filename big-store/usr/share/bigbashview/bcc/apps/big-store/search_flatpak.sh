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
parallel_filter () {

    readarray -t -d"|" myarray <<< "$1"

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

    # Improve order of packages
    PKG_NAME_CLEAN="${search% *}"

    # Verify if package are installed
    if [ "$(echo "$FLATPAK_INSTALLED_LIST" | LC_ALL=C grep -i -m1 "|$PKG_ID|")" != "" ]; then
        if [ "$(echo "$PKG_UPDATE" | tr -d '\n')" != "" ]; then
            PKG_INSTALLED=$"Atualizar"
            LIST_INSTALL="remove"
            DIV_FLATPAK_INSTALLED="flatpak_upgradable"
            PKG_ORDER="FlatpakP1"
        else
            PKG_INSTALLED=$"Remover"
            LIST_INSTALL="remove"
            DIV_FLATPAK_INSTALLED="flatpak_installed"
            PKG_ORDER="FlatpakP1"
        fi
    else
        PKG_INSTALLED=$"Instalar"
        LIST_INSTALL="install"
        DIV_FLATPAK_INSTALLED="flatpak_not_installed"

        if [ "$(echo "$PKG_NAME $PKG_ID" | grep -i -m1 "$PKG_NAME_CLEAN")" != "" ]
        then
            PKG_ORDER="FlatpakP2"

        elif [ "$(echo "$ID" | grep -i -m1 "$PKG_NAME_CLEAN")" != "" ]
        then
            PKG_ORDER="FlatpakP3"
        else
            PKG_ORDER="FlatpakP4"
        fi
    fi




# cat >>  ${TMP_FOLDER}/flatpakbuild.html << EOF
# <a href="flatpak_view.sh?$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp tooltipped" data-position="top" data-tooltip="${PACKAGE}$PKG_ID<br><br>${VERSION}$PKG_VERSION"><div id=flatpak_package></div><div id=flatpak_icon><img height="64" width="64" loading="lazy" src="$PKG_ICON"><div id=version>$PKG_VERSION_ORIG</div></div><div id=flatpak_name>$PKG_NAME</div><div id=flatpak_desc>$PKG_DESC</div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div></div>
# EOF

            # If all fail, use generic icon
            if [ "$PKG_ICON" = "" ] || [ "$(echo "$PKG_ICON" | LC_ALL=C grep -i -m1 'type=')" != "" ] || [ "$(echo "$PKG_ICON" | LC_ALL=C grep -i -m1 '<description>')" != "" ]; then
                INPUT=$(grep -o "$PKG_ID," /tmp/big-select.tmp)
                if [ -n "$INPUT" ]; then                
cat >>  ${TMP_FOLDER}/flatpakbuild.html << EOF
<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><div class=icon_middle><div class=avatar_flatpak>${PKG_NAME:0:3}</div></div></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-$PKG_ID name=itemSelect class=checkboxitemSelect-flatpak value=$PKG_ID,$LIST_INSTALL,flatpak checked><label for=itemSelect-$PKG_ID></label></div></form></div>
EOF
                else
cat >>  ${TMP_FOLDER}/flatpakbuild.html << EOF
<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><div class=icon_middle><div class=avatar_flatpak>${PKG_NAME:0:3}</div></div></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-$PKG_ID name=itemSelect class=checkboxitemSelect-flatpak value=$PKG_ID,$LIST_INSTALL,flatpak><label for=itemSelect-$PKG_ID></label></div></form></div>
EOF
                fi
            else
                INPUT2=$(grep -o "$PKG_ID," /tmp/big-select.tmp)
                if [ -n "$INPUT2" ]; then              
cat >>  ${TMP_FOLDER}/flatpakbuild.html << EOF
<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-$PKG_ID name=itemSelect class=checkboxitemSelect-flatpak value=$PKG_ID,$LIST_INSTALL,flatpak checked><label for=itemSelect-$PKG_ID></label></div></form></div>
EOF
                else
cat >>  ${TMP_FOLDER}/flatpakbuild.html << EOF
<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-$PKG_ID name=itemSelect class=checkboxitemSelect-flatpak value=$PKG_ID,$LIST_INSTALL,flatpak><label for=itemSelect-$PKG_ID></label></div></form></div>
EOF
                fi
            fi

    


}

if [ "$resultFilter_checkbox" = "" ]; then
    cacheFile="${HOME_FOLDER}/flatpak.cache"
else
    cacheFile="${HOME_FOLDER}/flatpak_filtered.cache"
fi
COUNT=0
case "$(echo "$search" | wc -w)" in

    1)
        for i  in  $(grep -i  -m 60 -e "$(echo "$search" | cut -f1 -d" " | sed 's|"||g')" $cacheFile); do
            let COUNT=COUNT+1; 
            parallel_filter "$i" &
             if [ "$COUNT" = "60" ]; then
                break
            fi
        done
    ;;

    2)
        for i  in  $(grep -i  -e "$(echo "$search" | cut -f1 -d" " | sed 's|"||g')" $cacheFile | grep -i  -m 60 -e "$(echo "$search" | cut -f2 -d" ")"); do
            let COUNT=COUNT+1; 
            parallel_filter "$i" &
             if [ "$COUNT" = "60" ]; then
                break
            fi
        done
    ;;

    *)
        for i  in  $(grep -i  -e "$(echo "$search" | cut -f1 -d" " | sed 's|"||g')" $cacheFile | grep -i -e "$(echo "$search" | cut -f2 -d" ")" | grep -i  -m 60 -e "$(echo "$search" | cut -f3 -d" ")"); do
            let COUNT=COUNT+1; 
            parallel_filter "$i" &
             if [ "$COUNT" = "60" ]; then
                break
            fi
        done
    ;;

esac



wait

if [ "$COUNT" -gt "0" ]; then
    echo '<script>
runAvatarFlatpak();
$(document).ready(function () {
$("#box_flatpak").show();});
</script>' >> ${TMP_FOLDER}/flatpakbuild.html 
fi

echo "$COUNT" > "${TMP_FOLDER}/flatpak_number.html"

echo "<script>
// CHECKBOX LIST APPS
\$(function () {
  \$('.checkboxitemSelect-flatpak').on('change',function(e){
    e.preventDefault();
    console.log(this);
    var newquantidade = this.value;
    \$.ajax({
      type: 'post',
      url: 'big-select.run',
      data: newquantidade,
      success: function () {
        //alert('search_flatpak.sh ' + newquantidade);
        \$('#btnFull').show();
        \$('#btnInstall').load('/tmp/big-install.tmp');
        \$('#btnRemove').load('/tmp/big-remove.tmp');
      }
    });
  });
});
// FIM CHECKBOX LIST APPS
</script>" >> ${TMP_FOLDER}/flatpakbuild.html



mv -f ${TMP_FOLDER}/flatpakbuild.html ${TMP_FOLDER}/flatpak.html

IFS=$OIFS


