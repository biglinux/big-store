#!/usr/bin/python

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

# coding=utf-8
# -*- coding: utf-8 -*-

#Imported from https://gitlab.manjaro.org/applications/pamac/-/blob/master/examples/python/appstream.py

import os
import gi
import subprocess
import sys
import locale
import datetime

gi.require_version('Pamac', '11')
from gi.repository import Pamac

# Import gettext module
import gettext
lang_translations = gettext.translation('big-store', localedir='/usr/share/locale', fallback=True)
lang_translations.install()
# define _ shortcut for translations
_ = lang_translations.gettext


def print_pkg_details (details):
    if  details.get_app_id() is None:
        sys.exit()
    loc = '%d/%m/%Y' if locale.getlocale()[0] == 'pt_BR' else '%Y/%m/%d'
    #print (" -Name:", details.get_app_name())
    #print (" -Desc:", details.get_desc())
    #print (" -Long Desc:", details.get_long_desc())
    #print (" -Icon:", details.get_icon())
    #print (" -Screenshots:", details.get_screenshots())
    #print (" -Download Size:", details.get_download_size())
    #print (" -Installed Size:", details.get_installed_size())
    #print (" -License:", details.get_license())
    #print (" -Id:", details.get_id())
    #print (" -Installed Version:", details.get_installed_version())
    #print (" -Version:", details.get_version())
    #print (" -Repository:", details.get_repo())
    #print (" -Launchable:", details.get_launchable())
    #print (" -Url:", details.get_url())
    #print (" -Instaled Date:", details.get_install_date())
    #print (" -Dependences:", details.get_depends())
    #print (" -packager:", details.get_packager())
    #print (" -reason:", details.get_reason())
    #print (" -groups:", details.get_groups())
    #print (" -optdepends:", details.get_optdepends())
    #print (" -checkdepends:", details.get_checkdepends())
    #print (" -makedepends:", details.get_makedepends())
    #print (" -conflicts:", details.get_conflicts())
    #print (" -provides:", details.get_provides())
    #print (" -replaces:", details.get_replaces())
    #print (" -build_date:", details.get_build_date())
    #print (" -has_signature:", details.get_has_signature())
    #print (" -requiredby:", details.get_requiredby())
    #print (" -optionalfor:", details.get_optionalfor())
    #print (" -backups:", details.get_backups())


    print ('<div id=content_flatpak_install>')
    update_version = subprocess.run(["./pkg_flatpak_version", sys.argv[1]], stdout=subprocess.PIPE, text=True)
    update_available = subprocess.run(["./pkg_flatpak_update", sys.argv[1]], stdout=subprocess.PIPE, text=True)
    print ('<div id=titleBar>')
    print ('<div id=title>')
    #print ('<div id=titleName>', details.get_id(), '</div></div></div>')

    if details.get_icon() is None:
        print ('<div class=icon_middle><div class=avatar_appstream>' + details.get_name()[0:3] + '</div></div>')
        
        iconCheck = ''
        
    else:
        print ('<img class="icon_view" src="', details.get_icon(), '">')
        
        iconCheck = details.get_icon()
        
    #print ('<div id=titleName>', sys.argv[1], '</div></div></div>')
    print ('<div id=titleName>', sys.argv[1].replace(".org", "").replace("org.", "").replace("com.", "").replace(".desktop", "").replace(".io", ""), '/', details.get_app_name(), '</div></div></div>')
    print ('<div id=description>', details.get_desc(), '</div></div>')
    print ('<div class="row center">')
    
    if details.get_installed_version():
        
        with open(os.path.expanduser('/tmp/big-select.tmp')) as e:
            
            lineCheck = details.get_name() + ',remove,flatpak,' + iconCheck.strip() + ',' + sys.argv[1].replace(".org", "").replace("org.", "").replace("com.", "").replace(".desktop", "").replace(".io", "") + '/' + details.get_app_name() + ',' + details.get_version()

            checkedBoxItem = 'checked' if lineCheck in e.read() else ''             
            
        print ('<form id=formcheckbox><div><input type=checkbox id=itemSelect-' + sys.argv[1] + ' name=itemSelect class=checkboxitemSelect-flatpak value="'+ lineCheck +'" '+ checkedBoxItem +'><label for=itemSelect-' + sys.argv[1] + '>', _('Adicionar na lista'), '</label></div></form>')        
        
        print ('<button class="btn btnSpace waves-effect waves-light red accent-4" type="submit" name="action" onclick="disableBodyFlatpakRemove();location.href=' + "'view_flatpak.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_remove=y&pkg_id=" +details.get_id() + "'" + '">', _('Remover'), '</button>')

        if details.get_launchable():
            print ('<button class="btn btnSpace waves-effect waves-light blue darken-3" type="submit" name="action" onclick="_run(', "'" + 'gtk-launch', details.get_launchable() + "'", ')">', _('Executar'), '</button>')

        if update_available.stdout.replace("\n", "") != '':
            print ('<button class="btn btnSpace waves-effect waves-light yellow darken-4" type="submit" name="action" onclick="disableBodyFlatpakInstall();location.href=' + "'view_flatpak.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_install=y&pkg_id=" + details.get_id() + "'" + '">', _('Atualizar'), '</button>')
    else:
        
        with open(os.path.expanduser('/tmp/big-select.tmp')) as e:
            
            lineCheck = details.get_name() + ',install,flatpak,' + iconCheck.strip() + ',' + sys.argv[1].replace(".org", "").replace("org.", "").replace("com.", "").replace(".desktop", "").replace(".io", "") + '/' + details.get_app_name() + ',' + details.get_version()

            checkedBoxItem = 'checked' if lineCheck in e.read() else ''
                
        print ('<form id=formcheckbox><div><input type=checkbox id=itemSelect-' + sys.argv[1] + ' name=itemSelect class=checkboxitemSelect-flatpak value="'+ lineCheck +'" '+ checkedBoxItem +' ><label for=itemSelect-' + sys.argv[1] + '>', _('Adicionar na lista'), '</label></div></form>')        
        
        print ('<button class="btn btnSpace waves-effect waves-light green accent-4" type="submit" name="action" onclick="disableBodyFlatpakInstall();location.href=' + "'view_flatpak.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_install=y&pkg_id=" + details.get_id() + "'" + '">', _('Instalar'), '</button>')

    if details.get_long_desc() or details.get_screenshots():
        print ('<div id=descriptionbox>')
    if details.get_screenshots():
        screenshot_resolution = open("/tmp/bigstore/screenshot-resolution.txt", "r")

        print ('<div id=screenshotPkg><div class="slider"><ul class="slides">')
        for screenshot in details.get_screenshots():
            print ('<li><img class=screenshot src="', screenshot, '"></li>')
        print ('<script>jQuery(document).ready(function(){jQuery(".slider").slider({width:', screenshot_resolution.read(), '});});</script>')
        print ('</ul></div>')
    if details.get_long_desc():
        print ('<div id=pkgDescriptionBox><div id=pkgDescription>', details.get_long_desc(), '</div></div>')
    if details.get_long_desc() or details.get_screenshots():
        print ('</div></div>')
        
    print ('<br>')        

    print ('<div class="grid-container">')
    print ('<div class=gridLeft>', _('Pacote:'), '</div>')
    print ('<div class=gridRight>', sys.argv[1], '</div></div>')

    if update_version.stdout:
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Versão disponível:'), '</div>')
        print ('<div class="gridRight">', update_version.stdout, '</div></div>')
    
    if details.get_installed_version():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Versão instalada:'), '</div>')
        print ('<div class=gridRight>', details.get_installed_version(), '</div></div>')
    
    print ('<div class=grid-container><div class=gridLeft>', _('Uso de armazenamento:'), '</div><div class=gridRight id=Size>', str(round(details.get_installed_size() / (1024 * 1024), 1)), 'MB</div></div>')

    if details.get_download_size():
        print ('<div class=grid-container><div class=gridLeft>', _('Tamanho do download:'), '</div><div class=gridRight id=Size>', str(round(details.get_download_size() / (1024 * 1024), 1)), 'MB</div></div>')

    if details.get_url():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Site:'), '</div>')
        print ('<div class="gridRight clickpointer" onclick="_run(', "'" + 'xdg-open', details.get_url() + "'", ')">', details.get_url(), '</div></div>')

    if details.get_license():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Licença:'), '</div>')
        print ('<div class="gridRight">', details.get_license(), '</div></div>')

    if details.get_repo():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Repositório:'), '</div>')
        print ('<div class="gridRight">', details.get_repo(), '</div></div>')

    if details.get_install_date():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Data de instalação:'), '</div>')
        print ('<div class="gridRight">')
        print (datetime.datetime.fromtimestamp(
            int(details.get_install_date().to_unix())
        ).strftime(loc))
        print ('</div></div>')

    subprocess.run(["./pkg_flatpak_verify"], stdout=subprocess.PIPE, text=True)
    if details.get_installed_version():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', _('Arquivos do pacote:'), '</div>')
        print ('<div class="gridRight">')
        print ('<a class="modal-trigger" href="#modal1" id="listPgkFiles">', _('Clique aqui para ver os arquivos'), '</a><script>')
        print ("$('#listPgkFiles').click(function(e){$.get('./load.sh','pkg_installed_flatpak " + sys.argv[1] + "',function(data){$('#files_in_package').html(data);})})")
        print ('</script>')
        print ('</div></div>')



if __name__ == "__main__":
    config = Pamac.Config(conf_path="/etc/pamac.conf")
    config.set_enable_aur(False)
    config.set_enable_flatpak(True)
    config.set_enable_snap(False)
    db = Pamac.Database(config=config)
    pkgname = '^'+sys.argv[1]+'$'


    # To multi packages
    #db.enable_appstream()
    #pkgs = db.search_pkgs (pkgname)
    #for pkg in pkgs:
        #print_pkg_details (pkg)
        #break


    # To single package
    #db.enable_appstream()
    pkg = db.get_app_by_id(sys.argv[1])
    print_pkg_details (pkg)

SCRIPT = '''<script>
// CHECKBOX LIST APPS
$(function () {
$(".checkboxitemSelect-flatpak").on("change",function(e){
e.preventDefault();
console.log(this.value);
var newquantidade = this.value;
$.ajax({
type: "get",
url: "big-select.run?line="+newquantidade,
success: function () {
$("#btnFull").show();
$("#btnInstall").load("/tmp/big-install.tmp", function(e) {
if (e) {
$("#btnFull").show();
} else {
$("#btnRemove").load("/tmp/big-remove.tmp", function(e) {
if (e) {
$("#btnFull").show();
} else {
$("#btnFull").hide();
}
});
}
});
$("#btnRemove").load("/tmp/big-remove.tmp", function(e) {
if (e) {
$("#btnFull").show();
} else {
$("#btnInstall").load("/tmp/big-install.tmp", function(e) {
if (e) {
$("#btnFull").show();
} else {
$("#btnFull").hide();
}
});
}
});
}
});
});
});
// FIM CHECKBOX LIST APPS
</script>'''

print(str(SCRIPT), end='')
