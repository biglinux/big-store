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

import gi
import subprocess
import sys
import os
import locale
import datetime
from gi.repository import Pamac


def print_pkg_details (details):
    
    if details.get_icon() is None:
        find_icon = subprocess.run(["find", "icons/", "/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/", "/usr/share/app-info/icons/archlinux-arch-community/64x64/", "/usr/share/app-info/icons/archlinux-arch-extra/64x64/","-type", "f", "-iname", '*' + details.get_name().split("-")[0] + '*', "-print", "-quit"], stdout=subprocess.PIPE, text=True)
        if find_icon.stdout == '':
            print ('<div class=icon_middle style="border-radius: 0px; width: 20px;"><div class=avatar_appstream>' + details.get_name()[0:3] + '</div></div>')
        else:
            print ('<img class="icon_view" style="border-radius: 0px; width: 20px;" src="', find_icon.stdout, '">')
    else:
        print ('<img class="icon_view" src="', details.get_icon(), '">')

if __name__ == "__main__":
    config = Pamac.Config(conf_path="/etc/pamac.conf")
    config.set_enable_aur(False)
    config.set_enable_flatpak(False)
    config.set_enable_snap(False)
    db = Pamac.Database(config=config)
    pkgname = sys.argv[1]


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



