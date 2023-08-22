#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/search_aur.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2022/02/28
#  Altered: 2023/08/18
#
#  Copyright (c) 2023-2023, Vilmar Catafesta <vcatafesta@gmail.com>
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
_VERSION_="1.0.0-20230818"
export BOOTLOG="/tmp/bigcontrolcenter-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
export HOME_FOLDER="$HOME/.bigstore"
export TMP_FOLDER="/tmp/bigstore-$USER"
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
[[ -f "${LIBRARY}/bcclib.sh" ]] && source "${LIBRARY}/bcclib.sh"
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

function sh_config {
	#Translation
	export TEXTDOMAINDIR="/usr/share/locale"
	export TEXTDOMAIN=big-store
}

function sh_main {
	[[ -e ${TMP_FOLDER}/aurbuild.html ]] && rm -f ${TMP_FOLDER}/aurbuild.html
	#  ./search_aur.py $@ >> ${TMP_FOLDER}/aurbuild.html
	# mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html

	# Unused:
	# Try enable icons
	# PKG_ICON="$(find icons/ /usr/share/app-info/icons/archlinux-arch-community/64x64/ /usr/share/app-info/icons/archlinux-arch-extra/64x64/ /var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/ -type f -iname "*${TITLE_SIMPLE}*" -print -quit)"
	# echo '<div id=appstream_icon><img class="icon" loading="lazy" src="' "$PKG_ICON" '">' >> ${TMP_FOLDER}/aurbuild.html

	LC_ALL=C yay --sortby popularity -Ssa --singlelineresults --topdown $(echo $@ | sed "s| |\n|g") |
		gawk -v tmpfolder="${TMP_FOLDER}" \
			-v searchterms="$@" \
			-v resultfilter="$resultFilter_checkbox" \
			-v instalar=$"Instalar" \
			-v remover=$"Remover" -- '

				### Begin of gawk script
				BEGIN {
					# This OFS allows readable code during printing
					OFS="\n"
				}

				# The following block runs once per line given by yay to gawk
				{
					# Resetting variables
					title = title_simple = idaur = icon = title = version = description = button = ""
					title = gensub(/.*\//,"",1,$1)
					RS_BAK = RS
					RS = "^$"
					getline aurlist < "/usr/share/bigbashview/bcc/apps/big-store/list/aur_list.txt"
					close("/usr/share/bigbashview/bcc/apps/big-store/list/aur_list.txt")
					RS = RS_BAK

					# If resultfilter is not set, or package is in aur_list.txt
					if ( ( !resultfilter ) || ( aurlist ~ "\\<" title "\\>" ) ) {
						# title_simple = gensub(/-.*/,"",1,title)
						description = gensub(/.+\t/,"",1)
						installed = /Installed/ ? 1 : 0
						version = $2

						if ( !installed ) {
							button = "<div id=aur_not_installed>" instalar "</div></a></div></div>"
							if ( searchterms ~ "\\<" title "\\>" ) {
								idaur = "AurP2"
							} else {
								idaur = "AurP3"
							}
						} else {
							button = "<div id=aur_installed>" remover "</div></a></div></div>"
							idaur = "AurP1"
						}

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

						# Checks if package is orphaned
						# TODO: bash localization for "Orphaned"
						description = description ( /Orphaned/ ? " (Orphaned)" : "")

						# Writes html of current package on aurbuild.html
						# Do not worry, file redirector ">" works different in awk: only the first interaction deletes file content

						print(\
							"<a onclick=\"disableBody();\" href=\"view_aur.sh.htm?pkg_name=" title "\">",
							"<div class=\"col s12 m6 l3\" id=" idaur ">",
							"<div class=\"showapp\">",
							"<div id=aur_icon><div class=icon_middle>" icon "</div>",
							"<div id=aur_name><div id=limit_title_name>" title "</div>",
							"<div id=version>" version "</div></div></div>",
							"<div id=box_aur_desc><div id=aur_desc>" description "</div></div>",
							button) > tmpfolder "/aurbuild.html"
					}
				}

				# Stops right after the 60th package
				NR == 60 { exit }

				END {
					if (NR > 0) {
						print("<script>$(document).ready(function() {$(\"#box_aur\").show();});</script>",
								"<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\"; runAvatarAur();</script>") > tmpfolder "/aurbuild.html"
					} else {
						print("<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\"; runAvatarAur();</script>") > tmpfolder "/aurbuild.html"
					}

					# Writes on aur_number.html the number of packages read
					print NR > tmpfolder "/aur_number.html"
				}
		'
		### End of gawk script

	mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html
}

#sh_debug
sh_config
sh_main "$@"
