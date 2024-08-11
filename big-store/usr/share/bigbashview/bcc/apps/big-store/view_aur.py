#!/usr/bin/env python3
# coding=UTF-8

import json
import subprocess
import requests
import os
import locale
import sys

# Import gettext module
import gettext

lang_translations = gettext.translation(
    "big-store", localedir="/usr/share/locale", fallback=True
)
lang_translations.install()
# define _ shortcut for translations
_ = lang_translations.gettext
#
TMP_FOLDER = os.environ["TMP_FOLDER"]
LIBRARY = "/usr/share/bigbashview/bcc/shell"
script_name = LIBRARY + "/bstrlib.sh"
#

response = requests.get(
    "https://aur.archlinux.org/rpc/",
    params={"v": "5", "type": "info", "arg": sys.argv[1]},
)
data = json.loads(response.text)
pkg_summary = sys.argv[2]
for p in data["results"]:
    print("<div id=content_aur_bg>")
    print("<div id=titleBar>")
    print("<div id=title>")
    if os.path.exists("icons/" + sys.argv[1] + ".png"):
        print(
            "<div class=icon_middle>"
            + '<img class="icon_view" src="icons/'
            + sys.argv[1]
            + '.png">'
            + "</div>"
        )
    else:
        print(
            "<div class=icon_middle><div class=avatar_aur>"
            + sys.argv[1][0:3]
            + "</div></div>"
        )
    print("<div id=titleName>", p["Name"], "</div></div></div>")

    #    if os.path.exists(
    #        "description/" + sys.argv[1] + "/" + locale.getlocale()[0] + "/summary"
    #    ):
    #        print("<div id=description>")
    #        print(
    #            open(
    #                "description/" + sys.argv[1] + "/" + locale.getlocale()[0] + "/summary",
    #                "r",
    #            ).read()
    #        )
    #        print("</div></div>")
    #    else:
    #        print("<div id=description>", p["Description"], "</div></div>")

    print("<div id=description>", pkg_summary)
    print('<div class="row center">')
    pkg_installed = subprocess.run(
        ["pacman", "-Q", sys.argv[1]], stdout=subprocess.PIPE, text=True
    )

    function_name = "sh_pkg_pacman_version"
    package_name = sys.argv[1]
    command = f'source {script_name} && {function_name} "{package_name}"'
    pkg_installed_version = subprocess.run(
        command, shell=True, stdout=subprocess.PIPE, text=True
    )
    if pkg_installed.stdout:
        print(
            '<button class="btn btnSpace waves-effect waves-light red accent-4" type="submit" name="action" onclick="disableBody();location.href='
            + "'view_aur.sh.htm?pkg_name="
            + sys.argv[1]
            + "&pkg_remove=y'"
            + '">',
            "Remover",
            "</button>",
        )
        if pkg_installed_version.stdout.strip() != p["Version"].strip():
            print(
                '<button class="btn btnSpace waves-effect waves-light yellow darken-4" type="submit" name="action" onclick="disableBody();location.href='
                + "'view_aur.sh.htm?pkg_name="
                + sys.argv[1]
                + "&pkg_install=y'"
                + '">',
                _("Atualizar"),
                "</button>",
            )
        else:
            if "Version" in p:
                print(
                    '<button class="btn btnSpace waves-effect waves-light green darken-3" type="submit" name="action" onclick="disableBody();location.href='
                    + "'view_aur.sh.htm?pkg_name="
                    + sys.argv[1]
                    + "&pkg_install=y'"
                    + '">',
                    _("Reinstalar"),
                    "</button>",
                )
    else:
        print(
            '<button class="btn btnSpace waves-effect waves-light green accent-4" type="submit" name="action" onclick="disableBody();location.href='
            + "'view_aur.sh.htm?pkg_name="
            + sys.argv[1]
            + "&pkg_install=y'"
            + '">',
            _("Instalar"),
            "</button>",
        )

    screenshot_store = "description/" + sys.argv[1] + "/screenshot"
    description_file_store = os.path.exists(
        "description/" + sys.argv[1] + "/" + locale.getlocale()[0] + "/desc"
    )
    if os.path.exists(screenshot_store):
        screenshot_resolution = open(TMP_FOLDER + "/screenshot-resolution.txt", "r")
        print("<div id=descriptionbox>")
        if os.path.exists(screenshot_store):
            screenshot_list = open(screenshot_store, "r")
            print('<div id=screenshotPkg><div class="slider"><ul class="slides">')
            for screenshot in screenshot_list.readlines():
                print(
                    '<li><img class=screenshot src="',
                    screenshot.replace("\n", ""),
                    '"></li>',
                )
            print(
                '<script>jQuery(document).ready(function(){jQuery(".slider").slider({width:',
                screenshot_resolution.read(),
                "});});</script>",
            )
            print("</ul></div>")
        else:
            if details.get_screenshots():
                print('<div id=screenshotPkg><div class="slider"><ul class="slides">')
                for screenshot in details.get_screenshots():
                    print('<li><img class=screenshot src="', screenshot, '"></li>')
                print(
                    '<script>jQuery(document).ready(function(){jQuery(".slider").slider({width:',
                    screenshot_resolution.read(),
                    "});});</script>",
                )
                print("</ul></div>")

    if description_file_store:
        print("<div id=pkgDescriptionBox><div id=pkgDescription>")
        print(
            open(
                "description/" + sys.argv[1] + "/" + locale.getlocale()[0] + "/desc",
                "r",
            ).read()
        )
        print("</div></div></div></div>")

    print("<br>")

    print('<div class="grid-container">')
    print("<div class=gridLeft>", _("Pacote:"), "</div>")
    print("<div class=gridRight>", sys.argv[1], "</div></div>")

    if pkg_installed_version.stdout:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Versão instalada:"), "</div>")
        print(
            "<div class=gridRight>",
            pkg_installed_version.stdout.strip(),
            "</div></div>",
        )
    if pkg_installed_version.stdout != p["Version"]:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Versão disponivel:"), "</div>")
        print("<div class=gridRight>", p["Version"], "</div></div>")

    if "NumVotes" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Número de votos:"), "</div>")
        print("<div class=gridRight>", p["NumVotes"], "</div></div>")
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Página no AUR:"), "</div>")
        print(
            '<div class="gridRight clickpointer" onclick="_run(',
            "'" + "xdg-open",
            "https://aur.archlinux.org/packages/" + p["Name"] + "'",
            ')">',
            "https://aur.archlinux.org/packages/" + p["Name"],
            "</div></div>",
        )
        print('<div class="grid-container">')
        print("<div class=gridLeft>", "PKGBUILD:", "</div>")
        print(
            '<div class="gridRight clickpointer" onclick="_run(',
            "'" + "xdg-open",
            "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD%3Fh="
            + p["Name"]
            + "'",
            ')">',
            "https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=" + p["Name"],
            "</div></div>",
        )

    if "URL" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Site:"), "</div>")
        print(
            '<div class="gridRight clickpointer" onclick="_run(',
            "'" + "xdg-open",
            p["URL"] + "'",
            ')">',
            p["URL"],
            "</div></div>",
        )

    if "License" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Licença:"), "</div>")
        print('<div class="gridRight">', p["License"][0], "</div></div>")

    print('<div class="grid-container">')
    print("<div class=gridLeft>", _("Repositório:"), "</div>")
    print('<div class="gridRight">', "AUR", "</div></div>")

    if "Maintainer" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Empacotador:"), "</div>")
        print('<div class="gridRight">', p["Maintainer"], "</div></div>")

    function_name = "sh_pkg_pacman_build_date"
    package_name = sys.argv[1]
    command = f'source {script_name} && {function_name} "{package_name}"'
    pkg_build_date = subprocess.run(
        command, shell=True, stdout=subprocess.PIPE, text=True
    )
    if pkg_build_date.stdout != "":
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Data do empacotamento:"), "</div>")
        print('<div class="gridRight">', pkg_build_date.stdout, "</div></div>")

    function_name = "sh_pkg_pacman_install_date"
    package_name = sys.argv[1]
    command = f'source {script_name} && {function_name} "{package_name}"'
    pkg_install_date = subprocess.run(
        command, shell=True, stdout=subprocess.PIPE, text=True
    )
    if pkg_install_date.stdout != "":
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Data de instalação:"), "</div>")
        print('<div class="gridRight">', pkg_install_date.stdout, "</div></div>")

    function_name = "sh_pkg_pacman_install_reason"
    package_name = sys.argv[1]
    command = f'source {script_name} && {function_name} "{package_name}"'
    pkg_install_reason = subprocess.run(
        command, shell=True, stdout=subprocess.PIPE, text=True
    )
    if pkg_install_reason.stdout != "":
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Motivo da instalação:"), "</div>")
        print('<div class="gridRight">', pkg_install_reason.stdout, "</div></div>")

    if "Groups" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Grupos:"), "</div>")
        print('<div class="gridRight">', p["Groups"], "</div></div>")

    if "OptDepends" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Complementos:"), "</div>")
        print('<div class="gridRight">')
        print('<div class="optdepends_box">')
        for optdepends in p["OptDepends"]:
            optdepends_name = optdepends.split(":")[0]
            installed_dep = subprocess.run(
                ["pacman", "-Qq", optdepends_name], stdout=subprocess.PIPE, text=True
            )
            print("<div id=optdepends_breakline>")
            if installed_dep.stdout == "":
                print(
                    '<div id=optdepends_install><a onclick="disableBody();" href="view_aur.sh.htm?pkg_name='
                    + optdepends_name
                    + '">'
                )
                print(
                    "<div id=optdepends_install_button>" + _("Instalar"),
                    optdepends_name,
                    "</div></a>",
                )
            else:
                print(
                    '<div id=optdepends_remove><a onclick="disableBody();" href="view_aur.sh.htm?pkg_name='
                    + optdepends_name
                    + '">'
                )
                print(
                    "<div id=optdepends_remove_button>" + _("Remover"),
                    optdepends_name,
                    "</div></a>",
                )
            print("</div></div>")
        print("</div></div></div>")

    if "Depends" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Dependências:"), "</div>")
        print('<div class="gridRight">')
        for depends in p["Depends"]:
            print(depends)
            print("<br>")
        print("</div></div>")

    if "MakeDepends" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Dependências de instalação:"), "</div>")
        print('<div class="gridRight">')
        for makedepends in p["MakeDepends"]:
            print(makedepends)
            print("<br>")
        print("</div></div>")

    if "Conflicts" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Remove:"), "</div>")
        print('<div class="gridRight">')
        for conflicts in p["Conflicts"]:
            print(conflicts)
            print("<br>")
        print("</div></div>")

    if "Replaces" in p:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Substitui:"), "</div>")
        print('<div class="gridRight">')
        for replaces in p["replaces"]:
            print(replaces)
            print("<br>")
        print("</div></div>")

    if pkg_installed.stdout:
        print('<div class="grid-container">')
        print("<div class=gridLeft>", _("Arquivos do pacote:"), "</div>")
        print('<div class="gridRight">')
        print(
            '<a class="modal-trigger" href="#modal1" id="listPgkFiles">',
            "Clique aqui para ver os arquivos",
            "</a><script>",
        )
        print(
            "$('#listPgkFiles').click(function(e){$.get('./load.sh','pkg_installed "
            + sys.argv[1]
            + "',function(data){$('#files_in_package').html(data);})})"
        )
        print("</script>")
        print("</div></div>")
