#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/load.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2022/02/28
#  Altered: 2023/08/28
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
_VERSION_="1.0.0-20230828"
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
[[ -f "${LIBRARY}/bcclib.sh"  ]] && source "${LIBRARY}/bcclib.sh"
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

function sh_load_config {
	#Translation
	export TEXTDOMAINDIR="/usr/share/locale"
	export TEXTDOMAIN=big-store
	declare -g msgDownload=$"Baixando pacotes novos da base de dados do servidor"
	declare -g msgNenhumParam=$"Nenhum pacote passado como parâmetro"
}

function sh_load_refresh_db {
	echo "$msgDownload"
	pacman -Fy >/dev/null 2>&-
}

function sh_load_main {
	local pacote="$2"
	local paths

	sh_load_config
	sh_load_refresh_db
	if [[ -n "$pacote" ]]; then
		case $1 in
		pkg_not_installed)
#			pacman -Flq "$2" | sed 's|^|/|'
#			pacman -Flq "$2" | while IFS= read -r line; do echo "/$line"; done
#			while IFS= read -r line; do echo "/$line"; done < <(pacman -Flq "$2")
			pacman -Flq "$2" | while IFS= read -r line; do printf "/%s\n" "$line"; done  #mais rápido
		    ;;
		pkg_installed)
			pacman -Qk "$pacote"
			pacman -Qlq "$pacote"
			;;
		pkg_installed_flatpak)
			echo "Folder base: $(flatpak info --show-location "$pacote")"
			find "$(flatpak info --show-location "$pacote")" | sed "s|$(flatpak info --show-location "$pacote")||g"
			;;
		esac
	else
		echo "$msgNenhumParam"
	fi
}

#sh_debug
sh_load_main "$@"
