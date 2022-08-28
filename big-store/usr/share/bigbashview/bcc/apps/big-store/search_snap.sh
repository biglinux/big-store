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
# Le os pacotes instalados em snap
SNAP_INSTALLED_LIST="|$(snap list | cut -f1 -d" " | tail -n +2 | tr '\n' '|')"

VERSION="Versão: "
PACKAGE="Pacote: "
HOME_FOLDER="$HOME/.bigstore"
TMP_FOLDER="/tmp/bigstore"

# Uncomment to debug in terminal
## portuguese
# Remova o comentário para fazer testes no terminal
#search="office"

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
    PKG_ID="${myarray[1]}"
    PKG_ICON="${myarray[2]}"
    PKG_DESC="${myarray[3]}"
    PKG_VERSION="${myarray[4]}"
    PKG_CMD="${myarray[5]}"


    # Improve order of packages
    ##
    # Melhora a ordem de exibição dos pacotes, funciona em conjunto com o css que irá reordenar de acordo com o id da div, que aqui é representado pela variavel $PKG_ORDER
    PKG_NAME_CLEAN="$(echo "$search" | cut -f1 -d" ")"

    # Verify if package are installed
    ## portuguese
    # Verifica se o pacote está instalado
    if [ "$(echo "$SNAP_INSTALLED_LIST" | grep -i -m1 "|$PKG_CMD|")" != "" ]; then
        PKG_INSTALLED=$"Remover"
        LIST_INSTALL="remove"
        DIV_SNAP_INSTALLED="appstream_installed"
        PKG_ORDER="SnapP1"
    else
        PKG_INSTALLED=$"Instalar"
        LIST_INSTALL="install"
        DIV_SNAP_INSTALLED="appstream_not_installed"

        if [ "$(echo "$PKG_NAME $PKG_CMD" | grep -i -m1 "$PKG_NAME_CLEAN")" != "" ]
        then
            PKG_ORDER="SnapP2"
        else
            PKG_ORDER="SnapP3"
        fi\
    fi

    # Make html code
    ## portuguese
    # Cria o codigo html que sera exibido para o usuario
    
    # If not found use generic icon
    ## portuguese
    # Se nao detectar ícone, utiliza um generico
if [ "$PKG_ICON" = "" ]; then


    ## titulo,remove,snap
    lineCheck="$PKG_ID,remove,snap,$PKG_ICON,$PKG_NAME,$PKG_VERSION"
    ## titulo,remove,snap,caminho do icon,nome app,versao
    INPUT=$(grep -o "$PKG_ID,remove,snap" /tmp/big-select.tmp)   
    
        if [ -n "$INPUT" ]; then
cat >>  ${TMP_FOLDER}/snapbuild.html << EOF
<!--$PKG_NAME--><a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=snap_icon><div class=icon_middle><div class=avatar_snap>${PKG_NAME:0:3}</div></div><div id=snap_name>$PKG_NAME<div id=version>$PKG_VERSION</div></div></div><div id=box_snap_desc><div id=snap_desc>$PKG_DESC</div></div><div id=$DIV_SNAP_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id='itemSelect-$PKG_ID-snap' name=itemSelect class=checkboxitemSelect-snap value="$lineCheck" checked><label for='itemSelect-$PKG_ID-snap'></label></div></form></div>
EOF
        else
cat >>  ${TMP_FOLDER}/snapbuild.html << EOF
<!--$PKG_NAME--><a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=snap_icon><div class=icon_middle><div class=avatar_snap>${PKG_NAME:0:3}</div></div><div id=snap_name>$PKG_NAME<div id=version>$PKG_VERSION</div></div></div><div id=box_snap_desc><div id=snap_desc>$PKG_DESC</div></div><div id=$DIV_SNAP_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id='itemSelect-$PKG_ID-snap' name=itemSelect class=checkboxitemSelect-snap value="$lineCheck"><label for='itemSelect-$PKG_ID-snap'></label></div></form></div>
EOF
        fi

    else
    
    ## titulo,install,snap
    lineCheck="$PKG_ID,install,snap,$PKG_ICON,$PKG_NAME,$PKG_VERSION"
    ## titulo,install,snap,caminho do icon,nome app,versao
    INPUT2=$(grep -o "$PKG_ID,install,snap" /tmp/big-select.tmp)
    
        if [ -n "$INPUT2" ]; then    
cat >>  ${TMP_FOLDER}/snapbuild.html << EOF
<!--$PKG_NAME--><a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=snap_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=snap_name>$PKG_NAME<div id=version>$PKG_VERSION</div></div></div><div id=box_snap_desc><div id=snap_desc>$PKG_DESC</div></div><div id=$DIV_SNAP_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id='itemSelect-$PKG_ID-snap' name=itemSelect class=checkboxitemSelect-snap value="$lineCheck" checked><label for='itemSelect-$PKG_ID-snap'></label></div></form></div>
EOF
        else
cat >>  ${TMP_FOLDER}/snapbuild.html << EOF
<!--$PKG_NAME--><a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=snap_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=snap_name>$PKG_NAME<div id=version>$PKG_VERSION</div></div></div><div id=box_snap_desc><div id=snap_desc>$PKG_DESC</div></div><div id=$DIV_SNAP_INSTALLED>$PKG_INSTALLED</div></a></div><form id=formcheckbox><div id=checkboxItem><input type=checkbox id='itemSelect-$PKG_ID-snap' name=itemSelect class=checkboxitemSelect-snap value="$lineCheck"><label for='itemSelect-$PKG_ID-snap'></label></div></form></div>
EOF
        fi
        
    fi



# Close function
## portuguese
# Finaliza a função
}

    
# Start loop
## portuguese
# Inicia o loop, filtrando o conteudo do arquivo ${HOME_FOLDER}/snap.cache

rm -f  ${TMP_FOLDER}/snapbuild.html

if [ "$resultFilter_checkbox" = "" ]; then
    cacheFile="${HOME_FOLDER}/snap.cache"
else
    cacheFile="${HOME_FOLDER}/snap_filtered.cache"
fi

COUNT=0
case "$(echo "$search" | wc -w)" in

    1)
        for i  in  $(grep -i  -m 60 -e "$(echo "$search" | cut -f1 -d" ")" $cacheFile); do
            let COUNT=COUNT+1; 
            parallel_filter "$i" &
             if [ "$COUNT" = "60" ]; then
                break
            fi
        done
    ;;

    2)
        for i  in  $(grep -i  -e "$(echo "$search" | cut -f1 -d" ")" $cacheFile | grep -i  -m 60 -e "$(echo "$search" | cut -f2 -d" ")"); do
            let COUNT=COUNT+1; 
            parallel_filter "$i" &
             if [ "$COUNT" = "60" ]; then
                break
            fi
        done
    ;;

    *)
        for i  in  $(grep -i  -e "$(echo "$search" | cut -f1 -d" ")" $cacheFile | grep -i -e "$(echo "$search" | cut -f2 -d" ")" | grep -i  -m 60 -e "$(echo "$search" | cut -f3 -d" ")"); do
            let COUNT=COUNT+1; 
            parallel_filter "$i" &
             if [ "$COUNT" = "60" ]; then
                break
            fi
        done
    ;;

esac


# Wait to all results before show to the user
## portuguese
# Aguarda todos os resultados antes de exibir para o usuário

wait

# If have result use javascript to show in screen
## portuguese
# Se houver resultados utiliza o javascript para exibir na tela


if [ "$COUNT" -gt "0" ]; then
    echo '<script>
runAvatarSnap();
$(document).ready(function () {
$("#box_snap").show();});
</script>' >> ${TMP_FOLDER}/snapbuild.html 
fi
echo "$COUNT" > "${TMP_FOLDER}/snap_number.html"


OIFS=$IFS
IFS=$'\n'

echo "<script>
// CHECKBOX LIST APPS
\$(function () {
  \$('.checkboxitemSelect-snap').on('change',function(e){
    e.preventDefault();
    console.log(this);
    var newquantidade = this.value;
    \$.ajax({
      type: 'get',
      url: 'big-select.run?line=' + newquantidade,
      success: function () {
        //alert('search_snap.sh: ' + newquantidade);
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
</script>" >> ${TMP_FOLDER}/snapbuild.html


mv -f ${TMP_FOLDER}/snapbuild.html ${TMP_FOLDER}/snap.html

IFS=$OIFS
