#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034,SC1135,SC2154
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/view_flatpak.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2022/02/28
#  Altered: 2024/07/31
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
_VERSION_="1.0.0-20230731"
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
[[ -f "${LIBRARY}/bcclib.sh"  ]] && source "${LIBRARY}/bcclib.sh"
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

function sh_view_flatpak_sh {
	local search="$*"
	local FLATPAK_INSTALLED_LIST=$(sh_flatpak_installed_list)

	sh_seek_flatpak_parallel_filter "$search"

	cat <<-EOF
		<div id="box_flatpak_install">
		<div id="title_flatpak_install">
		<div id="button_flatpak" class="tooltipped" data-position="left" data-tooltip="$ABOUT_FLATPAK">
		<svg role="img" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg" style="width:20px;margin-right:1px;margin-left:5px;">
		<path fill="var(--text-a-color)" d="m 200,5.9523902 c -8.98514,0 -17.97169,2.3280645 -26.03677,6.9844298 L 51.016633,83.920269 C 34.886486,93.233022 24.979868,110.38745 24.979868,129.01293 v 141.97046 c 0,18.62546 9.906618,35.77989 26.036765,45.09264 l 122.946597,70.98701 c 16.13013,9.31276 35.9434,9.31276 52.07354,0 l 122.94659,-70.98701 c 16.13016,-9.31275 26.03677,-26.46718 26.03677,-45.09264 V 129.01293 c 0,-18.62548 -9.90661,-35.779908 -26.03677,-45.092661 L 226.03677,12.93682 C 217.9717,8.2804547 208.98514,5.9523902 200,5.9523902 Z m 0,38.1331378 c 2.41371,0 4.82858,0.621233 6.97729,1.861803 l 122.94663,70.983449 c 2.14873,1.24057 3.89441,3.02162 5.10127,5.11195 L 200,199.99993 v 155.91086 c -2.41371,0 -4.82859,-0.62123 -6.97731,-1.86182 L 70.07608,283.06553 c -4.297468,-2.48115 -6.977319,-7.11987 -6.977319,-12.08214 V 129.01293 c 0,-2.48114 0.669184,-4.87986 1.876048,-6.9702 L 200,199.99993 Z"/>
		</svg>
		<div style="margin-right: 5px;">
		</div>
		$Programas_Flatpak
		</div>
		</div>
		<div id="content_flatpak_install">
		<div id="titleBar">
		<div id="title">
	EOF

	if [[ -z "${PKG_FLATPAK[PKG_ICON]}" || -n "$(LC_ALL=C grep -i -m1 -e 'type=' -e '<description>' <<<"${PKG_FLATPAK[PKG_ICON]}")" ]]; then
		cat <<-EOF
			<div class="avatar_flatpak">${PKG_FLATPAK[PKG_NAME]:0:3}</div>
		EOF
	else
		cat <<-EOF
			<img class="icon_view" src="${PKG_FLATPAK[PKG_ICON]}">
		EOF
	fi

	cat <<-EOF
		<div id="titleName">${PKG_FLATPAK[PKG_NAME]}</div></div></div>
		<div id="description">${PKG_FLATPAK[PKG_DESC]}</div></div>
		<div class="row center">
	EOF

	# Verify if package are installed
	if [[ "$(echo "$FLATPAK_INSTALLED_LIST" | LC_ALL=C grep -i -m1 "|${PKG_FLATPAK[PKG_ID]}|")" != "" ]]; then
		if [[ "$(echo "${PKG_FLATPAK[PKG_UPDATE]}" | tr -d '\n')" != "" ]]; then
			cat <<-EOF
				<button class="btn btnSpace waves-effect waves-light yellow darken-4" type="submit" name="action" onclick="disableBodyFlatpakInstall();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_install=y'">
				$Button_Atualizar
				</button>
				<button class="btn btnSpace waves-effect waves-light blue darken-3" type="submit" name="action" onclick="_run('flatpak run ${PKG_FLATPAK[PKG_ID]}')">
				$Button_Executar
				</button>
			EOF
		else
			cat <<-EOF
				<button class="btn btnSpace waves-effect waves-light red accent-4" type="submit" name="action" onclick="disableBodyFlatpakRemove();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_remove=y'">
				$Button_Remover
				</button>
				<button class="btn btnSpace waves-effect waves-light blue darken-3" type="submit" name="action" onclick="_run('flatpak run ${PKG_FLATPAK[PKG_ID]}')">
				$Button_Executar
				</button>
			EOF
		fi
	else
		cat <<-EOF
			<button class="btn btnSpace waves-effect waves-light green accent-4" type="submit" name="action" onclick="disableBodyFlatpakInstall();location.href='view_flatpak.sh.htm?pkg_name=$search&pkg_install=y'">
			$Button_Instalar
			</button>
		EOF
	fi

	cat <<-EOF
		<div class="grid-container">
			<div class="gridLeft">$Pacote</div>
			<div class="gridRight">$search</div>
		</div>

		<div class="grid-container">
			<div class="gridLeft">$Versao_disponivel</div>
			<div class="gridRight">${PKG_FLATPAK[PKG_VERSION]}</div>
		</div>

		<div class="grid-container">
			<div class="gridLeft">ID:</div>
			<div class="gridRight">${PKG_FLATPAK[PKG_ID]}</div>
		</div>

		<div class="grid-container">
			<div class="gridLeft">$Ramo:</div>
			<div class="gridRight">${PKG_FLATPAK[PKG_BRANCH]}</div>
		</div>

		<div class="grid-container">
			<div class="gridLeft">$Repositorio</div>
			<div class="gridRight">${PKG_FLATPAK[PKG_REMOTE]}</div>
		</div>
	EOF
}

#sh_debug
sh_view_flatpak_sh "$@"
