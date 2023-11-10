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

# Imported from https://gitlab.manjaro.org/applications/pamac/-/blob/master/examples/python/appstream.py

import gi
import subprocess
import sys
import os
import locale

gi.require_version("Pamac", "11")
from gi.repository import Pamac

# biblioteca apresenta erro de segmentação ao ser destruido quando o app é finalizado: destroy gettext
import gettext

lang_translations = gettext.translation(
    "big-store", localedir="/usr/share/locale", fallback=True
)
lang_translations.install()
# define _ shortcut for translations
_ = lang_translations.gettext
TMP_FOLDER = os.environ["TMP_FOLDER"]


def print_pkg_details(details):
    print(
        '<a onclick="disableBody();" href="view_appstream.sh.htm?pkg_name='
        + details.get_name()
        + '">'
    )
    print('<div class="col s12 m6 l3"')
    if details.get_installed_version() is not None:
        print('id="AppstreamP1">')
    else:
        if (
            details.get_id().find(sys.argv[1].split()[0]) != -1
            or details.get_desc().find(sys.argv[1].split()[0]) != -1
        ):
            print('id="AppstreamP2">')
        else:
            print('id="AppstreamP3">')

    print('<div class="showapp">')

    if details.get_icon() is None:
        find_icon = subprocess.run(
            [
                "find",
                "icons/",
                "/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/",
                "/usr/share/app-info/icons/archlinux-arch-community/64x64/",
                "/usr/share/app-info/icons/archlinux-arch-extra/64x64/",
                "-type",
                "f",
                "-iname",
                "*" + details.get_name().split("-")[0] + "*",
                "-print",
                "-quit",
            ],
            stdout=subprocess.PIPE,
            text=True,
        )
        if find_icon.stdout == "":
            print(
                "<div id=appstream_icon><div class=icon_middle><div class=avatar_appstream>"
                + details.get_name()[0:3]
                + "</div></div>"
            )
        else:
            print(
                '<div id=appstream_icon><div class=icon_middle><img class="icon" loading="lazy" src="',
                find_icon.stdout,
                '"></div>',
            )
    else:
        print(
            '<div id=appstream_icon><div class=icon_middle><img class="icon" loading="lazy" src="',
            details.get_icon(),
            '"></div>',
        )
    print(
        "<div id=appstream_name><div id=limit_title_name>", details.get_id(), "</div>"
    )
    print("<div id=version>", details.get_version(), "</div></div></div>")
    #   if os.path.exists('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/summary'):
    if os.path.exists(
        "description/" + details.get_name() + "/" + locale.getlocale()[0] + "/summary"
    ):
        print("<div id=box_appstream_desc><div id=appstream_desc>")
        #       print(open('description/' + details.get_name() + '/' + locale.getdefaultlocale()[0] + '/summary', "r").read())
        print(
            open(
                "description/"
                + details.get_name()
                + "/"
                + locale.getlocale()[0]
                + "/summary",
                "r",
            ).read()
        )
        print("</div></div>")
    else:
        print(
            "<div id=box_appstream_desc><div id=appstream_desc>",
            details.get_desc(),
            "</div></div>",
        )

    if details.get_installed_version() is None:
        print(
            "<div id=appstream_not_installed>"
            + _("Instalar")
            + "</div></a></div></div>"
        )
    else:
        with open(TMP_FOLDER + "/upgradeable.txt") as f:
            if "\n" + details.get_name() + "\n" in f.read():
                print(
                    "<div id=appstream_upgradable>"
                    + _("Atualizar")
                    + "</div></a></div></div>"
                )
            else:
                print(
                    "<div id=appstream_installed>"
                    + _("Remover")
                    + "</div></a></div></div>"
                )


if __name__ == "__main__":
    config = Pamac.Config(conf_path="/etc/pamac.conf")
    config.set_enable_aur(False)
    config.set_enable_flatpak(False)
    config.set_enable_snap(False)
    db = Pamac.Database(config=config)
    pkgname = sys.argv[1]

    # print ("Without appstream support:")
    # pkgs = db.search_pkgs (pkgname)
    # for pkg in pkgs:
    # print_pkg_details (pkg)

    #   db.enable_appstream()
    pkgs = db.search_pkgs(pkgname)
    num = 0
    pkg_filter = " " + sys.argv[1].split()[0].lower() + " "
    without_duplicates = []

    # Filtered Search
    for pkg in pkgs:
        # filter by title and desc
        if pkg.get_desc():
            desc_filter = " " + pkg.get_desc().lower() + " "
            if (
                desc_filter.find(pkg_filter) != -1
                or pkg.get_id().find(sys.argv[1].split()[0]) != -1
            ):
                # Remove from list
                blocklist = open("list/blocklist.txt", "r")
                if pkg.get_id() + "\n" not in blocklist.read():
                    # Remove duplicate
                    if pkg not in without_duplicates:
                        without_duplicates.append(pkg.get_name())
                        print_pkg_details(pkg)
                        num += 1
                        if num == 60:
                            break
    if num > 0:
        print(
            '<script>runAvatarAppstream(); $(document).ready(function () {$("#box_appstream").show();});</script>'
        )
        with open(TMP_FOLDER + "/appstream_number.html", "w") as f:
            f.write(str(num))

        print(
            '<script>document.getElementById("appstream_number").innerHTML = "',
            num,
            '";</script>',
        )
