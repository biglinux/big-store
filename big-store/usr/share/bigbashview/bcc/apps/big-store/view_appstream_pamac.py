#!/usr/bin/python
# coding=utf-8
# -*- coding: utf-8 -*-

#Imported from https://gitlab.manjaro.org/applications/pamac/-/blob/master/examples/python/appstream.py

import gi
import subprocess
import sys
import os
import locale
import datetime
from gi.repository import Pamac



def print_pkg_details (details):
    #print (" -Name:", details.get_name())
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
    print ('<div id=box_appstream_install><div id=title_appstream_install>')
    print ('<div id=button_appstream class="tooltipped" data-position="left" data-tooltip="Informações sobre programas nativos">')
    print ('Programas Nativos')
    print ('</div></div><div id=content_appstream_install>')
    update_version = subprocess.run(["pacman", "-Qu", sys.argv[1], '|', "awk","'{print $NF}'"], stdout=subprocess.PIPE, text=True)
    print ('<div id=titleBar>')
    print ('<div id=title>')
    if details.get_icon() == None:
        find_icon = subprocess.run(["find", "icons/", "/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/", "/usr/share/app-info/icons/archlinux-arch-community/64x64/", "/usr/share/app-info/icons/archlinux-arch-extra/64x64/","-type", "f", "-iname", '*' + details.get_name().split("-")[0] + '*', "-print", "-quit"], stdout=subprocess.PIPE, text=True)
        if find_icon.stdout == '':
            print ('<div class=icon_middle><div class=avatar_appstream>' + details.get_name()[0:3] + '</div></div>')
        else:
            print ('<img class="icon_view" src="', find_icon.stdout, '">')
    else:
        print ('<img class="icon_view" src="', details.get_icon(), '">')
    print ('<div id=titleName>', details.get_id(), '</div></div></div>')

    if os.path.exists('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/summary'):
        print ('<div id=description>')
        print(open('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/summary', "r").read())
        print ('</div></div>')
    else:
        print ('<div id=description>', details.get_desc(), '</div></div>')
    print ('<div class="row center">')
    if details.get_installed_version():
        print ('<button class="btn btnSpace waves-effect waves-light red accent-4" type="submit" name="action" onclick="disableBody();location.href=' + "'view_appstream.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_remove=y'" + '">', 'Remover', '</button>')

        if details.get_launchable():
            print ('<button class="btn btnSpace waves-effect waves-light blue darken-3" type="submit" name="action" onclick="_run(', "'" + 'gtk-launch', details.get_launchable() + "'", ')">', 'Executar', '</button>')

        with open('/tmp/bigstore/upgradeable.txt') as f:
            if '\n' + details.get_name() + '\n' in f.read():
                print ('<button class="btn btnSpace waves-effect waves-light yellow darken-4" type="submit" name="action" onclick="disableBody();location.href=' + "'view_appstream.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_install=y'" + '">', 'Atualizar', '</button>')
            else:
                if details.get_repo():
                    print ('<button class="btn btnSpace waves-effect waves-light green darken-3" type="submit" name="action" onclick="disableBody();location.href=' + "'view_appstream.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_install=y'" + '">', 'Reinstalar', '</button>')
    else:
        print ('<button class="btn btnSpace waves-effect waves-light green accent-4" type="submit" name="action" onclick="disableBody();location.href=' + "'view_appstream.sh.htm?pkg_name=" + sys.argv[1] + "&pkg_install=y'" + '">', 'Instalar', '</button>')

    screenshot_store = 'description/' + details.get_name() + '/screenshot'
    if details.get_long_desc() or details.get_screenshots() or os.path.exists(screenshot_store) or os.path.exists('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/desc'):
        screenshot_resolution = open("/tmp/bigstore/screenshot-resolution.txt", "r")
        print ('<div id=descriptionbox>')
        if os.path.exists(screenshot_store):
            screenshot_list = open(screenshot_store, "r")
            print ('<div id=screenshotPkg><div class="slider"><ul class="slides">')
            for screenshot in screenshot_list.readlines():
                print ('<li><img class=screenshot src="', screenshot.replace("\n", ""), '"></li>')
            print ('<script>jQuery(document).ready(function(){jQuery(".slider").slider({width:', screenshot_resolution.read(), '});});</script>')
            print ('</ul></div>')
        else:
            if details.get_screenshots():
                print ('<div id=screenshotPkg><div class="slider"><ul class="slides">')
                for screenshot in details.get_screenshots():
                    print ('<li><img class=screenshot src="', screenshot, '"></li>')
                print ('<script>jQuery(document).ready(function(){jQuery(".slider").slider({width:', screenshot_resolution.read(), '});});</script>')
                print ('</ul></div>')

    if os.path.exists('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/desc'):
        print ('<div id=pkgDescriptionBox><div id=pkgDescription>')
        print(open('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/desc', "r").read())
        print ('</div></div></div></div>')
    else:
        if details.get_long_desc():
            print ('<div id=pkgDescriptionBox><div id=pkgDescription>', details.get_long_desc(), '</div></div>')
        if details.get_long_desc() or details.get_screenshots():
            print ('</div></div>')

    print ('<div class="grid-container">')
    print ('<div class=gridLeft>', 'Pacote:', '</div>')
    print ('<div class=gridRight>', sys.argv[1], '</div></div>')
    if details.get_installed_version():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Versão instalada:', '</div>')
        print ('<div class=gridRight>', details.get_installed_version(), '</div>')
        print ('</div>')
    else:
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Versão disponivel:', '</div>')
        print ('<div class=gridRight>', details.get_version(), '</div></div>')
    if update_version.stdout != '':
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Versão disponivel:', '</div>')
        print ('<div class=gridRight>', update_version.stdout, '</div></div>')

    print ('<div class=grid-container><div class=gridLeft>', 'Uso de armazenamento:', '</div><div class=gridRight id=Size>', str(round(details.get_installed_size() / (1024 * 1024), 1)), 'MB</div></div>')

    if details.get_download_size():
        print ('<div class=grid-container><div class=gridLeft>', 'Tamanho do download:', '</div><div class=gridRight id=Size>', str(round(details.get_download_size() / (1024 * 1024), 1)), 'MB</div></div>')

    if details.get_url():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Site:', '</div>')
        print ('<div class="gridRight clickpointer" onclick="_run(', "'" + 'xdg-open', details.get_url() + "'", ')">', details.get_url(), '</div></div>')

    if details.get_license():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Licença:', '</div>')
        print ('<div class="gridRight">', details.get_license(), '</div></div>')

    if details.get_repo():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Repositório:', '</div>')
        print ('<div class="gridRight">', details.get_repo(), '</div></div>')

    if details.get_packager():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Empacotador:', '</div>')
        print ('<div class="gridRight">', details.get_packager(), '</div></div>')

    if details.get_build_date():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Data do empacotamento:', '</div>')
        print ('<div class="gridRight">')
        print (datetime.datetime.fromtimestamp(
            int(details.get_build_date())
        ).strftime('%Y/%m/%d'))
        print ('</div></div>')

    if details.get_install_date():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Data de instalação:', '</div>')
        print ('<div class="gridRight">')
        print (datetime.datetime.fromtimestamp(
            int(details.get_install_date())
        ).strftime('%Y/%m/%d'))
        print ('</div></div>')

    if details.get_reason():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Motivo da instalação:', '</div>')
        print ('<div class="gridRight">', details.get_reason(), '</div></div>')

    if details.get_groups():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Grupos:', '</div>')
        print ('<div class="gridRight">')
        for group in details.get_groups():
            print (group + '<br>')
        print ('</div></div>')

    if details.get_has_signature():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Assinado:', '</div>')
        print ('<div class="gridRight">', details.get_has_signature(), '</div></div>')

    if details.get_optdepends():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Complementos:', '</div>')
        print ('<div class="gridRight">')
        print ('<div class="optdepends_box">')
        for optdepends in details.get_optdepends():
            optdepends_name=optdepends.split(':')[0];
            optdepends_desc=optdepends.split(':')[1];
            installed_dep = subprocess.run(["pacman", "-Qq", optdepends_name], stdout=subprocess.PIPE, text=True)
            print ('<div id=optdepends_breakline>')
            if installed_dep.stdout == '':
                print ('<div id=optdepends_install><a href="view_appstream.sh.htm?pkg_name='+ optdepends_name + '">')
                print ('<div id=optdepends_install_button>' + 'Instalar', optdepends_name, '</div></a>' + optdepends_desc)
            else:
                print ('<div id=optdepends_remove><a href="view_appstream.sh.htm?pkg_name='+ optdepends_name + '">')
                print ('<div id=optdepends_remove_button>' + 'Remover', optdepends_name, '</div></a>' + optdepends_desc)
            print ('</div></div>')
        print ('</div></div></div>')

    if details.get_depends():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Dependências:', '</div>')
        print ('<div class="gridRight">')
        for depends in details.get_depends():
            print (depends + '<br>')
        print ('</div></div>')

    if details.get_conflicts():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Remove:', '</div>')
        print ('<div class="gridRight">')
        for conflicts in details.get_conflicts():
            print (conflicts + '<br>')
        print ('</div></div>')

    if details.get_replaces():
        print ('<div class="grid-container">')
        print ('<div class=gridLeft>', 'Substitui:', '</div>')
        print ('<div class="gridRight">')
        for replaces in details.get_replaces():
            print (replaces + '<br>')
        print ('</div></div>')

    print ('<div class="grid-container">')
    print ('<div class=gridLeft>', 'Arquivos do pacote:', '</div>')
    print ('<div class="gridRight">')

    print ('<a class="modal-trigger" href="#modal1" id="listPgkFiles">', 'Clique aqui para ver os arquivos', '</a><script>')
    if details.get_installed_version():
        print ("$('#listPgkFiles').click(function(e){$.get('./load.sh','pkg_installed " + sys.argv[1] + "',function(data){$('#files_in_package').html(data);})})")
    else:
        print ("$('#listPgkFiles').click(function(e){$.get('./load.sh','pkg_not_installed " + sys.argv[1] + "',function(data){$('#files_in_package').html(data);})})")
    print ('</script>')
    print ('</div></div>')


if __name__ == "__main__":
    config = Pamac.Config(conf_path="/etc/pamac.conf")
    config.set_enable_aur(False)
    config.set_enable_flatpak(False)
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
    db.enable_appstream()
    pkg = db.get_pkg(sys.argv[1])
    print_pkg_details (pkg)
