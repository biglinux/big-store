#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/category_aur.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2020/01/11
#  Altered: 2024/07/28
#
#  Copyright (c) 2023-2024, Vilmar Catafesta <vcatafesta@gmail.com>
#                2022-2023, Bruno Gonçalves <www.biglinux.com.br>
#                2022-2023, Rafael Ruscher <rruscher@gmail.com>
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

APP="${0##*/}"
_VERSION_="1.0.0-20240728"
#
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

rm -f ${TMP_FOLDER}/aur_build.html
#PKG="$@"

LANGUAGE=C yay -a -Si $@ |
	gawk -v tmpfolder=${TMP_FOLDER} -v instalar=$"Instalar" -v remover=$"Remover" -- '
### Begin of gawk script

BEGIN {
    OFS = "\n"
}

# Following block runs when blank line found, i.e., on the transition between packages
!$0 {
    title = version = description = not_installed = idaur = button = skipping = ""
}

# Skips lines between packages
skipping {
    next
}

/^Name/ {
    title = gensub(/^Name +: /,"",1)
    not_installed = system("pacman -Q " title " 2> /dev/null 1> /dev/null")
    if ( not_installed ) {
        idaur = "AurP2"
        button = "<div id=aur_not_installed>" instalar "</div></a></div></div>"
    } else {
        idaur = "AurP1"
        button = "<div id=aur_installed>" remover "</div></a></div></div>"
    }
}

/^Version/ {
    version = gensub(/^Version +: /,"",1)
}

/^Description/ {
    description = gensub(/^Description +: /,"",1)
}

# When all variables are set
title && version && description && idaur && button {
    if ( system("[ ! -e icons/" title ".png ]") ) {
        icon = "<img class=\"icon\" src=\"icons/" title ".png\">"
    } else {
        icon = "<div class=avatar_aur>" substr(title,1,3) "</div>"
    }

# Checking custom localized description
    shortlang = gensub(/\..+/,"",1,ENVIRON["LANG"])
    summaryfile = "description/" title "/" shortlang "/summary"
# Double negative because system() returns exit status of shell command inside ()
    if ( !system("[ -e " summaryfile " ]") ) {
        RS_BAK = RS
        RS = "^$"
        getline description < summaryfile
        close(summaryfile)
        RS = RS_BAK
    }

# Writes html of current package on aur_build.html
# Do not worry, file redirector ">" works different in awk: only the first interaction deletes file content
    print(\
"<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=" title "\">",
"<div class=\"col s12 m6 l3\" id=" idaur ">",
"<div class=\"showapp\">",
"<div id=aur_icon><div class=icon_middle>" icon "</div>",
"<div id=aur_name><div id=limit_title_name>" title "</div>",
"<div id=version>" version "</div></div></div>",
"<div id=box_aur_desc><div id=aur_desc>" description "</div></div>",
button) > tmpfolder "/aur_build.html"

    count++
    skipping++
# Getting ready for next package
    title = version = description = not_installed = idaur = icon = button = ""
}

END{
    if (count) {
        print(\
"<script>$(document).ready(function() {$(\"#box_aur\").show();});</script>",
"<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\";</script>",
"<script>runAvatarAur();</script>") > tmpfolder "/aur_build.html"
    } else {
        print(\
"<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\";</script>",
"<script>runAvatarAur();</script>") > tmpfolder "/aur_build.html"
    }
}


'
# End of gawk script

mv ${TMP_FOLDER}/aur_build.html ${TMP_FOLDER}/aur.html
