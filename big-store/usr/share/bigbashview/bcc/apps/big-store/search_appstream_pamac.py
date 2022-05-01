#!/usr/bin/python
# coding=utf-8
# -*- coding: utf-8 -*-

#Imported from https://gitlab.manjaro.org/applications/pamac/-/blob/master/examples/python/appstream.py

import gi
import subprocess
import sys
import os
import locale
gi.require_version('Pamac', '11')
from gi.repository import Pamac

# Import gettext module
import gettext
lang_translations = gettext.translation('big-store', localedir='./locale', fallback=True)
lang_translations.install()
# define _ shortcut for translations
_ = lang_translations.gettext

def print_pkg_details (details):
    print ('<a onclick="disableBody();" href="view_appstream.sh.htm?pkg_name=' + details.get_name() + '">')
    print ('<div class="col s12 m6 l3"')
    if details.get_installed_version() != None:
        print ('id="AppstreamP1">')
    else:
        if details.get_id().find(sys.argv[1].split()[0]) != -1 or details.get_desc().find(sys.argv[1].split()[0]) != -1:
            print ('id="AppstreamP2">')
        else:
            print ('id="AppstreamP3">')

    print ('<div class="showapp">')

    if details.get_icon() == None:
        find_icon = subprocess.run(["find", "icons/", "/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/", "/usr/share/app-info/icons/archlinux-arch-community/64x64/", "/usr/share/app-info/icons/archlinux-arch-extra/64x64/","-type", "f", "-iname", '*' + details.get_name().split("-")[0] + '*', "-print", "-quit"], stdout=subprocess.PIPE, text=True)
        if find_icon.stdout == '':
            print ('<div id=appstream_icon><div class=icon_middle><div class=avatar_appstream>' + details.get_name()[0:3] + '</div></div>')
        else:
            print ('<div id=appstream_icon><div class=icon_middle><img class="icon" loading="lazy" src="', find_icon.stdout, '"></div>')
    else:
        print ('<div id=appstream_icon><div class=icon_middle><img class="icon" loading="lazy" src="', details.get_icon(), '"></div>')
    print ('<div id=appstream_name><div id=limit_title_name>', details.get_id(), '</div>')
    print ('<div id=version>', details.get_version(), '</div></div></div>')
    if os.path.exists('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/summary'):
        print ('<div id=box_appstream_desc><div id=appstream_desc>')
        print(open('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/summary', "r").read())
        print ('</div></div>')
    else:
        print ('<div id=box_appstream_desc><div id=appstream_desc>', details.get_desc(), '</div></div>')

    if details.get_installed_version() == None:
        print ('<div id=appstream_not_installed>'+_('Instalar')+'</div></a></div></div>')
    else:
        with open('/tmp/bigstore/upgradeable.txt') as f:
            if '\n' + details.get_name() + '\n' in f.read():
                print ('<div id=appstream_upgradable>'+_('Atualizar')+'</div></a></div></div>')
            else:
                print ('<div id=appstream_installed>'+_('Remover')+'</div></a></div></div>')

if __name__ == "__main__":
    config = Pamac.Config(conf_path="/etc/pamac.conf")
    config.set_enable_aur(False)
    config.set_enable_flatpak(False)
    config.set_enable_snap(False)
    db = Pamac.Database(config=config)
    pkgname = sys.argv[1]

    #print ("Without appstream support:")
    #pkgs = db.search_pkgs (pkgname)
    #for pkg in pkgs:
        #print_pkg_details (pkg)

    db.enable_appstream()
    pkgs = db.search_pkgs(pkgname)
    num = 0
    pkg_filter=" "+sys.argv[1].split()[0].lower()+" "
    without_duplicates = []

    # Filtered Search
    for pkg in pkgs:
            # filter by title and desc
            if pkg.get_desc():
                desc_filter = ' '+pkg.get_desc().lower()+' '
                if desc_filter.find(pkg_filter) != -1 or pkg.get_id().find(sys.argv[1].split()[0]) != -1:
                    #Remove from list
                    blocklist = open("blocklist.txt", "r")
                    if pkg.get_id()+'\n' not in blocklist.read():
                            #Remove duplicate
                            if pkg not in without_duplicates:
                                without_duplicates.append(pkg.get_name())
                                print_pkg_details (pkg)
                                num += 1
                                if num == 50:
                                    break
    if num > 0:
        print ('<script>runAvatarAppstream(); $(document).ready(function () {$("#box_appstream").show();});</script>')
    print ('<script>document.getElementById("appstream_number").innerHTML = "', num, '";</script>')

    # Simple Search
    #for pkg in pkgs:
        #print_pkg_details (pkg)
        #num += 1
        #if num == 50:
            #break
    #if num > 0:
        #print ('<script>$(document).ready(function () {$("#box_appstream").show();});</script>')
    #print ('<script>document.getElementById("appstream_number").innerHTML = "', num, '"</script>')
