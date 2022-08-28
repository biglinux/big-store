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
    PKG_ICON="$(find /var/lib/flatpak/appstream/$PKG_REMOTE/x86_64/active/icons/64x64/ -type f -iname "$PKG_ID.png" -print -quit)"
    # If not found try another way
    if [ "$PKG_ICON" = "" ]; then
    
        PKG_ICON="$(find /var/lib/flatpak/appstream/$PKG_REMOTE -type f -iname "$PKG_ID.png" -print -quit)"
    
        if [ "$PKG_ICON" = "" ]; then
        # If cached icon not found, try online
        PKG_ICON="$(awk /\<id\>$PKG_ID\<\\/id\>/,/\<\\/component\>/ $PKG_XML_APPSTREAM | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g;s|.*">||g')"

            # If online icon not found, try another way
            if [ "$PKG_ICON" = "" ]; then
                PKG_ICON="$(awk /\<id\>$PKG_ID.desktop\<\\/id\>/,/\<\\/component\>/ $PKG_XML_APPSTREAM | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g;s|.*">||g')"
            fi
            
        fi

    fi

PKGNAMEFLATPAK="$(echo "$PKG_ID" | sed 's|.org||g;s|org.||g;s|com.||g;s|.desktop||g;s|.io||g')"    
    
echo "<div id=content_flatpak_install>
<div id=titleBar>
<div id=title>"

if [ "$PKG_ICON" != "" ] ; then
echo "<img class=\"icon_view\" src=\"$PKG_ICON\">"
else
echo "<div class=icon_middle><div class=icon_middle><div class=avatar_flatpak>${PKG_NAME:0:3}</div></div></div>"
fi


echo "<div id=titleName>$PKGNAMEFLATPAK / $PKG_NAME</div></div></div>"

echo "<div id=description>$PKG_DESC</div></div>"

echo '<div class="row center">'


    # Verify if package are installed
    if [ "$(echo "$FLATPAK_INSTALLED_LIST" | LC_ALL=C grep -i -m1 "|$PKG_ID|")" != "" ]; then
        if [ "$(echo "$PKG_UPDATE" | tr -d '\n')" != "" ]; then

            ## titulo,remove,flatpak
            lineCheck="$PKG_ID,remove,flatpak,$PKG_ICON,$PKG_NAME,$PKG_VERSION"
            ## titulo,install,remove,caminho do icon,nome app,versao
            INPUT=$(grep -o "$PKG_ID,remove,flatpak" /tmp/big-select.tmp)           
            
            if [ -n "$INPUT" ]; then
                echo "<form id=formcheckbox><div><input type=checkbox id=itemSelect-$search name=itemSelect class=checkboxitemSelect-flatpak value=\"$lineCheck\" checked><label for=itemSelect-$search>" $"Adicionar na lista" "</label></div></form>"
            else
                echo "<form id=formcheckbox><div><input type=checkbox id=itemSelect-$search name=itemSelect class=checkboxitemSelect-flatpak value=\"$lineCheck\"><label for=itemSelect-$search>" $"Adicionar na lista" "</label></div></form>"
            fi
        
            echo "<button class=\"btn btnSpace waves-effect waves-light yellow darken-4\" type=\"submit\" name=\"action\" onclick=\"disableBodyFlatpakInstall();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_install=y'\">"
            echo $"Atualizar" "</button>"
            echo "<button class=\"btn btnSpace waves-effect waves-light blue darken-3\" type=\"submit\" name=\"action\" onclick=\"_run( 'flatpak run $search' )\">" $"Executar" "</button>"
        else
        
        
            ## titulo,remove,flatpak
            lineCheck="$PKG_ID,remove,flatpak,$PKG_ICON,$PKG_NAME,$PKG_VERSION"
            ## titulo,remove,flatpak,caminho do icon,nome app,versao
            INPUT2=$(grep -o "$PKG_ID,remove,flatpak" /tmp/big-select.tmp)        
            
            
            if [ -n "$INPUT2" ]; then
                echo "<form id=formcheckbox><div><input type=checkbox id=itemSelect-$search name=itemSelect class=checkboxitemSelect-flatpak value=\"$lineCheck\" checked><label for=itemSelect-$search>" $"Adicionar na lista" "</label></div></form>"
            else
                echo "<form id=formcheckbox><div><input type=checkbox id=itemSelect-$search name=itemSelect class=checkboxitemSelect-flatpak value=\"$lineCheck\"><label for=itemSelect-$search>" $"Adicionar na lista" "</label></div></form>"
            fi        
           
            echo "<button class=\"btn btnSpace waves-effect waves-light red accent-4\" type=\"submit\" name=\"action\" onclick=\"disableBodyFlatpakRemove();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_remove=y'\">"
            echo $"Remover" "</button>"
            echo "<button class=\"btn btnSpace waves-effect waves-light blue darken-3\" type=\"submit\" name=\"action\" onclick=\"_run( 'flatpak run $search' )\">" $"Executar" "</button>"
        fi
    else

    
        ## titulo,install,flatpak
        lineCheck="$PKG_ID,install,flatpak,$PKG_ICON,$PKG_NAME,$PKG_VERSION"
        ## titulo,install,flatpak,caminho do icon,nome app,versao
        INPUT3=$(grep -o "$PKG_ID,install,flatpak" /tmp/big-select.tmp)     
       
        
        if [ -n "$INPUT3" ]; then
            echo "<form id=formcheckbox><div><input type=checkbox id=itemSelect-$search name=itemSelect class=checkboxitemSelect-flatpak value=\"$lineCheck\" checked><label for=itemSelect-$search>" $"Adicionar na lista" "</label></div></form>"
        else
            echo "<form id=formcheckbox><div><input type=checkbox id=itemSelect-$search name=itemSelect class=checkboxitemSelect-flatpak value=\"$lineCheck\"><label for=itemSelect-$search>" $"Adicionar na lista" "</label></div></form>"
        fi        
    
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


echo "<script>
// CHECKBOX LIST APPS
\$(function () {
  \$('.checkboxitemSelect-flatpak').on('change',function(e){
    e.preventDefault();
    console.log(this);
    var newquantidade = this.value;
    \$.ajax({
      type: 'get',
      url: 'big-select.run?line='+newquantidade,
      success: function () {
        //alert('view_flatpak.sh: ' + newquantidade);
        \$('#btnFull').show();
        //\$('#btnInstall').load('/tmp/big-install.tmp');
        //\$('#btnRemove').load('/tmp/big-remove.tmp');
        
        \$('#btnInstall').load('/tmp/big-install.tmp', function(e) {
        if (e) {
            \$('#btnFull').show();
        } else {
            \$('#btnRemove').load('/tmp/big-remove.tmp', function(e) {
            if (e) {
                \$('#btnFull').show();
            } else {
                \$('#btnFull').hide();
            }
            });
        }
        });
        \$('#btnRemove').load('/tmp/big-remove.tmp', function(e) {
        if (e) {
            \$('#btnFull').show();
        } else {
            \$('#btnInstall').load('/tmp/big-install.tmp', function(e) {
            if (e) {
                \$('#btnFull').show();
            } else {
                \$('#btnFull').hide();
            }
            });
        }
        });
        
      }
    });
  });
});
// FIM CHECKBOX LIST APPS
</script>"

IFS=$OIFS
