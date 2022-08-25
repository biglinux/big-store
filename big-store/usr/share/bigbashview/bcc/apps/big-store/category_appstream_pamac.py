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
lang_translations = gettext.translation('big-store', localedir='/usr/share/locale', fallback=True)
lang_translations.install()
# define _ shortcut for translations
_ = lang_translations.gettext

def print_pkg_details (details):
        print ('<a onclick="disableBody();" href="view_appstream.sh.htm?pkg_name=' + details.get_name() + '">')
        print ('<div class="col s12 m6 l3"')
        if details.get_repo() is None:
            with open('/tmp/bigstore/category_aur.txt', 'a') as f:
                print(details.get_name(), file=f)
        if details.get_installed_version() is not None:
            print ('id="AppstreamP1">')
        else:
            print ('id="AppstreamP2">')

        print ('<div class="showapp">')

        if details.get_icon() is None:
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

        if details.get_installed_version() is None:
            with open(os.path.expanduser('/tmp/big-select.tmp')) as e:
                    checkedBoxItem = 'checked' if details.get_name() + ',' in e.read() else ''
                    
                    print ('<div id=appstream_not_installed>'+_('Instalar')+'</div></a></div>')
                    print ('<form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-' + details.get_name() + ' name=itemSelect class=checkboxitemSelect value=' + details.get_name() + ',install,native '+ checkedBoxItem +'><label for=itemSelect-' + details.get_name() + '></label></div></form>')
                    print ('</div>')
        else:
            with open('/tmp/bigstore/upgradeable.txt') as f:
                if '\n' + details.get_name() + '\n' in f.read():
                    with open(os.path.expanduser('/tmp/big-select.tmp')) as e:
                        checkedBoxItem = 'checked' if details.get_name() + ',' in e.read() else ''
                        
                        print ('<div id=appstream_upgradable>'+_('Atualizar')+'</div></a></div>')
                        print ('<form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-' + details.get_name() + ' name=itemSelect class=checkboxitemSelect value=' + details.get_name() + ',remove,native '+ checkedBoxItem +'><label for=itemSelect-' + details.get_name() + '></label></div></form>')
                        print ('</div>')
                else:
                    with open(os.path.expanduser('/tmp/big-select.tmp')) as e:
                        checkedBoxItem = 'checked' if details.get_name() + ',' in e.read() else ''
                        
                        print ('<div id=appstream_installed>'+_('Remover')+'</div></a></div>')
                        print ('<form id=formcheckbox><div id=checkboxItem><input type=checkbox id=itemSelect-' + details.get_name() + ' name=itemSelect class=checkboxitemSelect value=' + details.get_name() + ',remove,native '+ checkedBoxItem +'><label for=itemSelect-' + details.get_name() + '></label></div></form>')
                        print ('</div>')

if __name__ == "__main__":
    config = Pamac.Config(conf_path="/etc/pamac.conf")
    config.set_enable_aur(False)
    config.set_enable_flatpak(False)
    config.set_enable_snap(False)
    db = Pamac.Database(config=config)


    # To multi packages
    #db.enable_appstream()
    #pkgs = db.search_pkgs (pkgname)
    #for pkg in pkgs:
        #print_pkg_details (pkg)
        #break



    # To single package
    db.enable_appstream()
    for app_list in sys.argv[1].split():
        pkg = db.get_pkg(app_list)
        if pkg:
            print_pkg_details(pkg)
        else:
            with open('/tmp/bigstore/category_aur.txt', 'a') as f:
                print(app_list, file=f)


    # Simple Search
    #for pkg in pkgs:
        #print_pkg_details (pkg)
        #num += 1
        #if num == 50:
            #break
    #if num > 0:
        #print ('<script>$(document).ready(function () {$("#box_appstream").show();});</script>')
    #print ('<script>document.getElementById("appstream_number").innerHTML = "', num, '"</script>')
    #print ('<script>')
    #print ('// CHECKBOX LIST APPS')
    #print ('\$(function () {')
    #print ('\$(".checkboxitemSelect-aur").on("change",function(e){')
    #print ('e.preventDefault();')
    #print ('console.log(this);')
    #print ('var newquantidade = this.value;')
    #print ('\$.ajax({')
    #print ('type: "post",')
    #print ('url: "big-select.run",')
    #print ('data: newquantidade,')
    #print ('success: function () {')
    ##print ('alert("search_appstream_pacman_simple.py: " + newquantidade);')
    #print ('\$("#btnFull").show();')
    #print ('\$("#btnInstall").load("/tmp/big-install.tmp");')
    #print ('\$("#btnRemove").load("/tmp/big-remove.tmp");')
    #print ('}')
    #print ('});')
    #print ('});')
    #print ('});')
    #print ('// FIM CHECKBOX LIST APPS')
    #print ('</script>')    
    
    
