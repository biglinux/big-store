#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  bstrlib.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2023/08/11
#  Altered: 2023/08/13
#
#  Copyright (c) 2023-2023, Vilmar Catafesta <vcatafesta@gmail.com>
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

export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store
export HOME_FOLDER="$HOME/.bigstore"
export TMP_FOLDER="/tmp/bigstore-$USER"

function sh_update_cache_snap {
	# Seleciona e cria a pasta para salvar os arquivos para cache da busca
	folder_to_save_files="$HOME_FOLDER/snap_list_files/snap_list"
	file_to_save_cache="$HOME_FOLDER/snap.cache"
	file_to_save_cache_filtered="$HOME_FOLDER/snap_filtered.cache"
	path_snap_list_files="$HOME_FOLDER/snap_list_files/"

	[[ -d "$path_snap_list_files" ]] && rm -R "$path_snap_list_files"
	mkdir -p "$path_snap_list_files"

	# Anotação com as opções possíveis para utilizar na API
	#https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=anon_download_url,architecture,channel,download_sha3_384,summary,description,binary_filesize,download_url,last_updated,package_name,prices,publisher,ratings_average,revision,snap_id,license,base,media,support_url,contact,title,content,version,origin,developer_id,developer_name,developer_validation,private,confinement,common_ids&q=office&scope=wide:

	# Anotação com a busca por wps-2019-snap em cache
	# jq -r '._embedded."clickindex:package"[]| select( .package_name == "wps-2019-snap" )' $folder_to_save_files*

	# Faz o download da página inicial
	curl --silent "https://api.snapcraft.io/api/v1/snaps/search?confinement=strict&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media,&scope=wide:" >${folder_to_save_files}

	# Lê na pagina inicial quantas paginas devem ser baixadas e salva o valor na variavel $numbe_of_pages
	number_of_pages="$(jq -r '._links.last' ${folder_to_save_files} | sed 's|.*page=||g;s|"||g' | grep [0-9])"

	# Inicia o download em paralelo de todas as paginas
	page=2
	while [[ "$page" -lt "$number_of_pages" ]]; do
		echo "Downloading $page of $number_of_pages"
		curl --silent "https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media,&scope=wide:&page=$page" >>${folder_to_save_files}$page &
		((page++))
	done

	# Aguarda o download de todos os arquivos
	wait

	# Filtra o resultado dos arquivos e cria um arquivo de cache que será utilizado nas buscas
	jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' ${folder_to_save_files}* |
		sort -u >$file_to_save_cache
	grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/snap_list.txt "$file_to_save_cache" >"$file_to_save_cache_filtered"
}
export -f sh_update_cache_snap

function sh_update_cache_flatpak {
	# Defina os caminhos dos arquivos
	local LIST_FILE="/usr/share/bigbashview/bcc/apps/big-store/list/flatpak_list.txt"
	local CACHE_FILE="$HOME_FOLDER/flatpak.cache"
	local FILTERED_CACHE_FILE="$HOME_FOLDER/flatpak_filtered.cache"

	[[ -e "$CACHE_FILE" ]] && rm -f "$CACHE_FILE"

	# Realiza a busca de pacotes Flatpak, filtra e armazena no arquivo de cache
	flatpak search --arch x86_64 "" | awk -F'\t' '{ print $1"|"$2"|"$3"|"$4"|"$5"|"$6"|"}' | grep '|stable|' | sort -u > "$CACHE_FILE"

	for i in $(LANG=C flatpak update | grep "^ [1-9]" | awk '{print $2}'); do
		sed -i "s/|${i}.*/&update|/" "$CACHE_FILE"
	done

	#Realize a busca e filtragem de pacotes Flatpak
	grep -Fwf "$LIST_FILE" "$CACHE_FILE" > "$FILTERED_CACHE_FILE"
}
export -f sh_update_cache_flatpak

function sh_update_cache_complete {
	[[ ! -d "$HOME_FOLDER" ]] && mkdir -p "$HOME_FOLDER"
	[[ -e "/usr/lib/libpamac-flatpak.so" ]] && sh_update_cache_flatpak
	[[ -e "/usr/lib/libpamac-snap.so" ]] && sh_update_cache_snap
}
export -f sh_update_cache_complete

function sh_run_pacman_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pacman_mirror

function sh_reinstall_allpkg {
	pacman -Qnq | pacman -Sy --noconfirm -
}
export -f sh_reinstall_allpkg

function sh_snap_enable {
	systemctl start snapd
	systemctl enable snapd
	systemctl start apparmor
	systemctl enable apparmor
}
export -f sh_snap_enable

function sh_run_pamac_installer {
	LangFilter="${LANG%%.*}"
	LangFilterLowercase="${LangFilter,,}"
	LangClean="${LangFilterLowercase%%_*}"
	LangCountry="${LangFilterLowercase#*_}"
	AutoAddLangPkg="$(pacman -Ssq $1.*$LangClean.* | grep -m1 [_-]$LangCountry)"

	pamac-installer $@ $AutoAddLangPkg &

	PID="$!"

	if [ "$PID" = "" ]; then
		exit
	fi

	CONTADOR=0
	while [ $CONTADOR -lt 100 ]; do
		if [ "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" != "" ]; then
			xsetprop -id=$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ") --atom WM_TRANSIENT_FOR --value $(wmctrl -p -l -x | grep Big-Store$ | cut -f1 -d" ") -f 32x
			wmctrl -i -r $(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ") -b add,skip_pager,skip_taskbar
			wmctrl -i -r $(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ") -b toggle,modal
			break
		fi

		sleep 0.1
		let CONTADOR=CONTADOR+1
	done
	wait
}
export -f sh_run_pamac_installer

function sh_run_pamac_remove {
	PKGS=""
	for i in $(echo n | LC_ALL=C pacman -Rc $@ 2>/dev/null | grep ^Packages | cut -f3- -d" "); do
		PKGS="$PKGS $(echo "$i" | sed 's|-[0-9].*||g')"
	done

	pamac-installer --remove $@ $(LC_ALL=C timeout 10s pamac remove -odc $PKGS | grep "^  " | cut -f3 -d" ") &

	PID="$!"

	if [ "$PID" = "" ]; then
		exit
	fi

	CONTADOR=0
	while [ $CONTADOR -lt 100 ]; do
		if [ "$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ")" != "" ]; then
			xsetprop -id=$(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ") --atom WM_TRANSIENT_FOR --value $(wmctrl -p -l -x | grep Big-Store$ | cut -f1 -d" ") -f 32x
			wmctrl -i -r $(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ") -b add,skip_pager,skip_taskbar
			wmctrl -i -r $(wmctrl -p -l | grep -m1 " $PID " | cut -f1 -d" ") -b toggle,modal
			break
		fi

		sleep 0.1
		let CONTADOR=CONTADOR+1
	done
	wait
}
export -f sh_run_pamac_remove

function sh_run_pamac_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pamac_mirror

function sh_category_aur {
	[[ -e ${TMP_FOLDER}/aurbuild.html ]] && rm -f ${TMP_FOLDER}/aurbuild.html
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
	"<script>runAvatarAur();</script>") > tmpfolder "/aurbuild.html"
	    } else {
	        print(\
	"<script>document.getElementById(\"aur_icon_loading\").innerHTML = \"\";</script>",
	"<script>runAvatarAur();</script>") > tmpfolder "/aurbuild.html"
	    }
	}


	'
	# End of gawk script

	mv ${TMP_FOLDER}/aurbuild.html ${TMP_FOLDER}/aur.html
}
export -f sh_category_aur

function sh_category_flatpak {
	# Read installed packages
	## portuguese
	# Le os pacotes instalados em flatpak
	FLATPAK_INSTALLED_LIST="|$(flatpak list | cut -f2 -d$'\t' | tr '\n' '|')"

	VERSION=$"Versão: "
	PACKAGE=$"Pacote: "
	NOT_VERSION=$"Não informada"

	# Le o parametro passado via terminal e cria a variavel $search
	search="$*"

	# Muda o delimitador para somente quebra de linha
	OIFS=$IFS
	IFS=$'\n'

	# Inicia uma função para possibilitar o uso em modo assíncrono
	parallel_filter() {
		readarray -t -d"|" myarray <<<"$1"
		PKG_NAME="${myarray[0]}"
		PKG_DESC="${myarray[1]}"
		PKG_ID="${myarray[2]}"
		PKG_VERSION="${myarray[3]}"
		PKG_STABLE="${myarray[4]}"
		PKG_REMOTE="${myarray[5]}"
		PKG_UPDATE="${myarray[6]}"

		# Seleciona o arquivo xml para filtrar os dados
		PKG_XML_APPSTREAM="/var/lib/flatpak/appstream/$PKG_REMOTE/x86_64/active/appstream.xml"

		PKG_VERSION_ORIG="$PKG_VERSION"
		if [ "$PKG_VERSION" = "" ]; then
			PKG_VERSION="$NOT_VERSION"
		fi

		# ICON
		# Example to run
		# awk /\<id\>com.eduke32.EDuke32\<\\/id\>/,/\<\\/component\>/ /var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml | grep -m1 -e icon -e cached | sed 's|.*">||g;s|</icon>||g'
		PKG_ICON=""

		# Search icon
		PKG_ICON="$(find /var/lib/flatpak/appstream/ -type f -iname "$PKG_ID.png" -print -quit)"

		# If not found try another way
		if [ "$PKG_ICON" = "" ]; then

			# If cached icon not found, try online
			PKG_ICON="$(awk /\<id\>$PKG_ID\<\\/id\>/,/\<\\/component\>/ $PKG_XML_APPSTREAM | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g')"

			# If online icon not found, try another way
			if [ "$PKG_ICON" = "" ]; then
				PKG_ICON="$(awk /\<id\>$PKG_ID.desktop\<\\/id\>/,/\<\\/component\>/ $PKG_XML_APPSTREAM | LC_ALL=C grep -i -m1 -e icon -e remote | sed 's|</icon>||g;s|.*http|http|g')"
			fi

		fi

		# Improve order of packages
		PKG_NAME_CLEAN="${search% *}"

		# Verify if package are installed
		if [ "$(echo "$FLATPAK_INSTALLED_LIST" | LC_ALL=C grep -i -m1 "|$PKG_ID|")" != "" ]; then
			if [ "$(echo "$PKG_UPDATE" | tr -d '\n')" != "" ]; then
				PKG_INSTALLED=$"Atualizar"
				DIV_FLATPAK_INSTALLED="flatpak_upgradable"
				PKG_ORDER="FlatpakP1"
			else
				PKG_INSTALLED=$"Remover"
				DIV_FLATPAK_INSTALLED="flatpak_installed"
				PKG_ORDER="FlatpakP1"
			fi
		else
			PKG_INSTALLED=$"Instalar"
			DIV_FLATPAK_INSTALLED="flatpak_not_installed"

			if [ "$(echo "$PKG_NAME $PKG_ID" | grep -i -m1 "$PKG_NAME_CLEAN")" != "" ]; then
				PKG_ORDER="FlatpakP2"

			elif [ "$(echo "$ID" | grep -i -m1 "$PKG_NAME_CLEAN")" != "" ]; then
				PKG_ORDER="FlatpakP3"
			else
				PKG_ORDER="FlatpakP4"
			fi
		fi

		# If all fail, use generic icon
		if [ "$PKG_ICON" = "" ] || [ "$(echo "$PKG_ICON" | LC_ALL=C grep -i -m1 'type=')" != "" ] || [ "$(echo "$PKG_ICON" | LC_ALL=C grep -i -m1 '<description>')" != "" ]; then
			cat >>${TMP_FOLDER}/flatpakbuild.html <<-EOF
				<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><div class=icon_middle><div class=avatar_flatpak>${PKG_NAME:0:3}</div></div></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div></div>
			EOF
		else
			cat >>${TMP_FOLDER}/flatpakbuild.html <<-EOF
				<a onclick="disableBody();" href="view_flatpak.sh.htm?pkg_name=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=flatpak_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=flatpak_name>$PKG_NAME<div id=version>$PKG_VERSION_ORIG</div></div></div><div id=box_flatpak_desc><div id=flatpak_desc>$PKG_DESC</div></div><div id=$DIV_FLATPAK_INSTALLED>$PKG_INSTALLED</div></a></div></div>
			EOF
		fi
	}

	if [ "$resultFilter_checkbox" = "" ]; then
		cacheFile="${HOME_FOLDER}/flatpak.cache"
	else
		cacheFile="${HOME_FOLDER}/flatpak_filtered.cache"
	fi
	COUNT=0
	case "$(echo "$search" | wc -w)" in

	1)
		for i in $(grep -i -m 60 -e "$(echo "$search" | cut -f1 -d" " | sed 's|"||g')" $cacheFile); do
			let COUNT=COUNT+1
			parallel_filter "$i" &
			if [ "$COUNT" = "60" ]; then
				break
			fi
		done
		;;

	2)
		for i in $(grep -i -e "$(echo "$search" | cut -f1 -d" " | sed 's|"||g')" $cacheFile | grep -i -m 60 -e "$(echo "$search" | cut -f2 -d" ")"); do
			let COUNT=COUNT+1
			parallel_filter "$i" &
			if [ "$COUNT" = "60" ]; then
				break
			fi
		done
		;;

	*)
		for i in $(grep -i -e "$(echo "$search" | cut -f1 -d" " | sed 's|"||g')" $cacheFile | grep -i -e "$(echo "$search" | cut -f2 -d" ")" | grep -i -m 60 -e "$(echo "$search" | cut -f3 -d" ")"); do
			let COUNT=COUNT+1
			parallel_filter "$i" &
			if [ "$COUNT" = "60" ]; then
				break
			fi
		done
		;;

	esac

	wait

	if [ "$COUNT" -gt "0" ]; then
		echo '<script>
	runAvatarFlatpak();
	$(document).ready(function () {
	$("#box_flatpak").show();});
	</script>' >>${TMP_FOLDER}/flatpakbuild.html
	fi

	echo "$COUNT" >"${TMP_FOLDER}/flatpak_number.html"

	# mv -f ${TMP_FOLDER}/flatpakbuild.html ${TMP_FOLDER}/flatpak.html
	# cat "${TMP_FOLDER}/flatpakbuild.html" >> ${TMP_FOLDER}/flatpak.html

	IFS=$OIFS
}
export -f sh_category_flatpak

function sh_count_snap_list {
	local snap_count=$(snap list | wc -l)
	((snap_count -= 1))
	echo "$snap_count"
}
export -f sh_count_snap_list

function sh_count_snap_cache_lines {
	wc -l < "$HOME_FOLDER/snap.cache"
}
export -f sh_count_snap_cache_lines

function sh_SO_installation_date {
#	ls -lct /etc | tail -1 | awk '{print $6, $7, $8}')
	expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | head -n 1
}
export -f sh_SO_installation_date

function sh_install_terminal {
	[[ -z "$ACTION"    ]] && ACTION="$1"
	[[ -z "$WINDOW_ID" ]] && WINDOW_ID="$2"

	if [[ -n "$ACTION" ]]; then
		SNAP_CLEAN_SCRIPT="./snap_clean.sh"
		MARGIN_TOP_MOVE="-90" WINDOW_HEIGHT=12 PID_BIG_DEB_INSTALLER="$$"	WINDOW_ID="$WINDOW_ID" ./install_terminal_resize.sh &

		case "$ACTION" in
		"reinstall_pamac") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac reinstall $PACKAGE_NAME --no-confirm ;;
		"install_flatpak")
			flatpak install --or-update $REPOSITORY $PACKAGE_ID -y
			if [ ! -e "$HOME_FOLDER/disable_flatpak_unused_remove" ]; then
				flatpak uninstall --unused -y
			fi
			sh_update_cache_flatpak
			;;
		"remove_flatpak")
			flatpak remove $PACKAGE_ID -y
			if [ ! -e "$HOME_FOLDER/disable_flatpak_unused_remove" ]; then
				flatpak uninstall --unused -y
			fi
			sh_update_cache_flatpak
			;;
		"install_snap")
			if [ ! -e "$HOME_FOLDER/disable_snap_unused_remove" ]; then
				pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $SNAP_CLEAN_SCRIPT install $PACKAGE_NAME
			else
				snap install $PACKAGE_NAME
			fi
			;;
		"remove_snap")
			if [ ! -e "$HOME_FOLDER/disable_snap_unused_remove" ]; then
				pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY $SNAP_CLEAN_SCRIPT remove $PACKAGE_NAME
			else
				snap remove $PACKAGE_NAME
			fi
			;;
		"update_pacman")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pacman -Syy --noconfirm ;;
		"update_mirror")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY sh_run_pacman_mirror ;;
		"update_keys")         pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --fix-keys ;;
		"force_upgrade")       pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY force-upgrade --upgrade-now ;;
		"reinstall_allpkg")    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY sh_reinstall_allpkg ;;
		"system_upgrade")      pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY pamac update --no-confirm ;;
		"system_upgradetotal") pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bigsudo pacman -Syyu --noconfirm ;;
		esac
	fi

	if [ "$(xwininfo -id $WINDOW_ID 2>&1 | grep -i "No such window")" != "" ]; then
		kill -9 $PID_BIG_DEB_INSTALLER
		exit 0
	fi
}
export -f sh_install_terminal

function sh_main {
	local execute_app="$1"
	eval "$execute_app"
	return
}

#sh_debug
sh_main "$@"
