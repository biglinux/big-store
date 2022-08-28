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

TMP_FOLDER="/tmp/bigstore"
COUNT=0
rm -f ${TMP_FOLDER}/aurbuild.html
OIFS=$IFS
IFS=$'\n'
PKG="$@"

for i  in  $(LANGUAGE=C yay -a -Sii $@ | grep -e ^Name -e ^Version -e ^Description | cut -f2-10 -d":" | awk '{if (NR%3) {ORS="";print "|"$0} else {ORS="\n";print "|"$0}}' | sed 's/^| //g;s/| /|/g'); do
    TITLE="$(echo "$i" | cut -f1 -d"|")"
    VERSION="$(echo "$i"| cut -f2 -d"|")"
    DESCRIPTION="$(echo "$i" | cut -f3 -d"|")"
    INSTALLED="$(pacman -Q "$TITLE" 2> /dev/null)"
    
    echo '<div class="col s12 m6 l3"' >> ${TMP_FOLDER}/aurbuild.html
    if [ "$INSTALLED" = "" ]; then
        echo 'id="AurP2">' >> ${TMP_FOLDER}/aurbuild.html
    else
        echo 'id="AurP1">' >> ${TMP_FOLDER}/aurbuild.html
    fi

    echo '<a onclick="disableBody();" href="view_aur.sh.htm?pkg_name='$TITLE'">' >> ${TMP_FOLDER}/aurbuild.html    
    

    echo '<div class="showapp">' >> ${TMP_FOLDER}/aurbuild.html
    if [ -e "icons/${TITLE}.png" ]; then
        echo "<div id=aur_icon><div class=icon_middle><img class=\"icon\" src=\"icons/${TITLE}.png\"></div>" >> ${TMP_FOLDER}/aurbuild.html
        ##Create path icon
        PKG_ICON="/usr/share/bigbashview/bcc/apps/big-store/icons/${TITLE}.png"
    else
        echo "<div id=aur_icon><div class=icon_middle><div class=avatar_aur>${TITLE:0:3}</div></div>" >> ${TMP_FOLDER}/aurbuild.html
        PKG_ICON=""
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
        
        ## titulo,install,aur
        lineCheck="$TITLE,install,aur,$PKG_ICON,$TITLE,$VERSION"
        ## titulo,install,aur,caminho do icon,nome app,versao
        INPUT=$(grep -o "$TITLE,install,aur" /tmp/big-select.tmp)
        
        if [ -n "$INPUT" ]; then
            echo '<div id=aur_not_installed>' $"Instalar" '</div></div></a><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-'$TITLE'-aur name=itemSelect class=checkboxitemSelect-aur value="'$lineCheck'" checked><label for=itemSelect-'$TITLE'-aur></label></div></form></div>' >> ${TMP_FOLDER}/aurbuild.html
        else
            echo '<div id=aur_not_installed>' $"Instalar" '</div></div></a><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-'$TITLE'-aur name=itemSelect class=checkboxitemSelect-aur value="'$lineCheck'"><label for=itemSelect-'$TITLE'-aur></label></div></form></div>' >> ${TMP_FOLDER}/aurbuild.html
        fi

    else
    
        ## titulo,remove,aur
        lineCheck="$TITLE,remove,aur,$PKG_ICON,$TITLE,$VERSION"
        ## titulo,remove,aur,caminho do icon,nome app,versao
        INPUT2=$(grep -o "$TITLE,remove,aur" /tmp/big-select.tmp)    
    
        if [ -n "$INPUT2" ]; then
            echo '<div id=aur_installed>' $"Remover" '</div></div></a><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-'$TITLE'-aur name=itemSelect class=checkboxitemSelect-aur value="'$lineCheck'" checked><label for=itemSelect-'$TITLE'-aur></label></div></form></div>' >> ${TMP_FOLDER}/aurbuild.html
        else
            echo '<div id=aur_installed>' $"Remover" '</div></div></a><form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-'$TITLE'-aur name=itemSelect class=checkboxitemSelect-aur value="'$lineCheck'"><label for=itemSelect-'$TITLE'-aur></label></div></form></div>' >> ${TMP_FOLDER}/aurbuild.html        
        fi

    fi

let COUNT=COUNT+1; 
done

IFS=$OIFS

if [ "$COUNT" -gt "0" ]; then
    echo '<script>$(document).ready(function() {$("#box_aur").show();});</script>' >> ${TMP_FOLDER}/aurbuild.html
fi
echo '<script>document.getElementById("aur_icon_loading").innerHTML = "";</script>' >> ${TMP_FOLDER}/aurbuild.html
echo '<script>runAvatarAur();</script>' >> ${TMP_FOLDER}/aurbuild.html
echo "<script>
// CHECKBOX LIST APPS
\$(function () {
  \$('.checkboxitemSelect-aur').on('change',function(e){
    e.preventDefault();
    console.log(this);
    var newquantidade = this.value;
    \$.ajax({
      type: 'get',
      url: 'big-select.run?line='+newquantidade,
      success: function () {
        //alert('category_aur.sh: ' + newquantidade);
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
</script>" >> ${TMP_FOLDER}/aurbuild.html
mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html
