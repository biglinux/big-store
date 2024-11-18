#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/big-store-start.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2020/01/11
#  Altered: 2024/11/05 - 21:30
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
_VERSION_="1.0.0-20241105"
#
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
[[ -f "${LIBRARY}/bcclib.sh" ]] && source "${LIBRARY}/bcclib.sh"
[[ -f "${LIBRARY}/tinilib.sh" ]] && source "${LIBRARY}/tinilib.sh"
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

function sh_config() {
	#desabilitando variáveis proxy do dde, as mesmas não permitem atualizações do pamac
	unset auto_proxy ftp_proxy http_proxy https_proxy no_proxy all_proxy
	#Translation
	export TEXTDOMAINDIR="/usr/share/locale"
	export TEXTDOMAIN=big-store
	declare -g bigstorepath='/usr/share/bigbashview/bcc/apps/big-store'
	declare -g bigstore_icon_file='icons/big-store.svg'
	declare -g TITLE="Big-Store"
	declare -gA Amsg=(
		[error_open]=$(gettext $"Outra instância do Big-Store já está em execução.")
		[error_access_dir]=$(gettext $"Erro ao acessar o diretório:")
	)
}

function sh_big_store_check_dirs {
	[[ ! -d "$HOME_FOLDER" ]] && mkdir -p "$HOME_FOLDER"
	[[ ! -d "$TMP_FOLDER" ]] && mkdir -p "$TMP_FOLDER"
}
export -f sh_big_store_check_dirs

function sh_check_big_store_is_running() {
	local PID

	if PID=$(pgrep -f 'Big-Store') && [[ -n "$PID" ]]; then
		#		notify-send -u critical --icon=big-store --app-name "$0" "$TITLE" "${Amsg[error_open]}" --expire-time=2000
		#		kdialog --title "$TITLE" --icon warning --msgbox "${Amsg[error_open]}"
		yad --title "$TITLE" --image=big-store --text "${Amsg[error_open]}\nPID:$PID" --button="OK":0
		exit 1
	fi
}

function sh_big_store_start_sh_main {
	local default_size='1060x755'
	#
	local height
	local widht
	local half_height
	local half_widht
	local processamento_em_paralelo=1
	local ident_keys=1

	sh_big_store_check_dirs
	cd "$bigstorepath" || {
		notify-send --icon=big-store --app-name "$0" "$TITLE" "${Amsg[error_access_dir]}\n$bigstorepath" --expire-time=2000
		return 1
	}

	# reformat pretry .ini
	#	[[ -e "$INI_FILE_BIG_STORE" ]] && big-tini-pretty -q "$INI_FILE_BIG_STORE"
	[[ -e "$INI_FILE_BIG_STORE" ]] && TIni.Sanitize "$INI_FILE_BIG_STORE"

	if TIni.Exist "$INI_FILE_BIG_STORE" "snap" "snap_active" '1' && [[ -e "/usr/lib/libpamac-snap.so" ]]; then
		[[ ! -e "$snap_cache_file" ]] || [[ "$(find "$snap_cache_file" -mtime +1 -print)" ]] && sh_update_cache_snap "$processamento_em_paralelo" &
	fi

	if TIni.Exist "$INI_FILE_BIG_STORE" "flatpak" "flatpak_active" '1' && [[ -e "/usr/lib/libpamac-flatpak.so" ]]; then
		[[ ! -e "$flatpak_cache_file" ]] || [[ "$(find "$flatpak_cache_file" -mtime +1 -print)" ]] && sh_update_cache_flatpak "$processamento_em_paralelo" &
	fi

	if [[ -z "$(TIni.Get "$INI_FILE_BIG_STORE" "PAMAC" "SimpleInstall")" ]]; then
		TIni.Set "$INI_FILE_BIG_STORE" "PAMAC" "SimpleInstall" '1'
	fi

	if [[ ! -e $FILE_SUMMARY_JSON_CUSTOM ]]; then
		if [[ -e $FILE_SUMMARY_JSON ]]; then
			echo "${cyan}config - $(gettext "Copiando arquivo") ${FILE_SUMMARY_JSON} para ${HOME_FOLDER}${reset}"
			if cp -f ${FILE_SUMMARY_JSON} ${FILE_SUMMARY_JSON_CUSTOM}; then
				echo "${cyan}config - $(gettext "Feito!")${reset}"
			else
				echo "${cyan}config - $(gettext "Erro na copia de ") ${FILE_SUMMARY_JSON}!${reset}"
			fi
		fi
	fi

	if [[ ! -e $FILE_PACKAGE_JSON_CUSTOM ]]; then
		if [[ -e $FILE_PACKAGE_JSON ]]; then
			echo "${cyan}config - $(gettext "Copiando arquivo") ${FILE_PACKAGE_JSON} para ${HOME_FOLDER}${reset}"
			if cp -f ${FILE_PACKAGE_JSON} ${FILE_PACKAGE_JSON_CUSTOM}; then
				echo "${cyan}config - $(gettext "Feito!")${reset}"
			else
				echo "${cyan}config - $(gettext "Erro na copia de ") ${FILE_PACKAGE_JSON}!${reset}"
			fi
		fi
	fi

	#	# Obtém a largura da tela primária usando xrandr
	#	if width=$(xrandr | grep -oP 'primary \K[0-9]+(?=x)') && [[ -n "$width" ]]; then
	#		# Se a largura foi obtida, tenta obter a altura da tela primária
	#		if height=$(xrandr | grep -oP 'primary \K[0-9]+x\K[0-9]+') && [[ -n "$height" ]]; then
	#			# Calcula metade da largura e altura
	#			half_width=$((width / 2))
	#			half_height=$((height / 2 * 3 / 2))
	#			# Atualiza o tamanho padrão com metade da largura e altura da tela
	#			default_size="${half_width}x${half_height}"
	#		fi
	#	fi

	# Save dynamic screenshot resolution
	echo "$half_height" >"${TMP_FOLDER}/screenshot-resolution.txt"

	_session="$(sh_get_desktop_session)"
	case "${_session^^}" in
	X11)
		COMMON_OPTIONS="QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview -n \"$TITLE\" -s ${default_size}"
		;;
	WAYLAND)
		COMMON_OPTIONS="MOZ_ENABLE_WAYLAND=1 bigbashview -n \"$TITLE\" -s ${default_size}"
		:
		;;
	*) # $_session vazia?, vai de X11
		COMMON_OPTIONS="QT_QPA_PLATFORM=xcb SDL_VIDEODRIVER=x11 WINIT_UNIX_BACKEND=x11 GDK_BACKEND=x11 bigbashview -n \"$TITLE\" -s ${default_size}"
		;;
	esac

	if [[ -n "$1" ]]; then
		case "${1^^}" in
		"CATEGORY") eval "$COMMON_OPTIONS index.sh.htm?category=\"$2\"          -i $bigstore_icon_file" ;;
		"APPSTREAM") eval "$COMMON_OPTIONS view_appstream.sh.htm?pkg_name=\"$2\" -i $bigstore_icon_file" ;;
		"AUR") eval "$COMMON_OPTIONS view_aur.sh.htm?pkg_name=\"$2\"       -i $bigstore_icon_file" ;;
		"FLATPAK") eval "$COMMON_OPTIONS view_flatpak.sh.htm?pkg_name=\"$2\"   -i $bigstore_icon_file" ;;
		"SNAP") eval "$COMMON_OPTIONS view_snap.sh.htm?pkg_id=\"$2\"        -i $bigstore_icon_file" ;;
		*) eval "$COMMON_OPTIONS index.sh.htm?search=\"$1\"            -i $bigstore_icon_file" ;;
		esac
	else
		eval "$COMMON_OPTIONS index.sh.htm -i $bigstore_icon_file"
	fi
}

#sh_debug
sh_config
sh_check_big_store_is_running
sh_big_store_start_sh_main "$@"
