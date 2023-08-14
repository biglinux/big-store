#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  /usr/share/bigbashview/bcc/apps/big-store/search_snap.sh
#  Description: Control Center to help usage of BigLinux
#
#  Created: 2022/02/28
#  Altered: 2023/08/14
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
_VERSION_="1.0.0-20230814"
export BOOTLOG="/tmp/bigstore-$USER-$(date +"%d%m%Y").log"
export LOGGER='/dev/tty8'
export HOME_FOLDER="$HOME/.bigstore"
export TMP_FOLDER="/tmp/bigstore-$USER"
LIBRARY=${LIBRARY:-'/usr/share/bigbashview/bcc/shell'}
[[ -f "${LIBRARY}/bcclib.sh"  ]] && source "${LIBRARY}/bcclib.sh"
[[ -f "${LIBRARY}/bstrlib.sh" ]] && source "${LIBRARY}/bstrlib.sh"

#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store

# Read installed packages
## portuguese
# Le os pacotes instalados em snap
SNAP_INSTALLED_LIST="|$(snap list | cut -f1 -d" " | tail -n +2 | tr '\n' '|')"

VERSION="Versão: "
PACKAGE="Pacote: "

#folders
export HOME_FOLDER="$HOME/.bigstore"
export TMP_FOLDER="/tmp/bigstore-$USER"

# Uncomment to debug in terminal
## portuguese
# Remova o comentário para fazer testes no terminal
#search="office"

# Change delimiter
## portuguese
# Muda o delimitador para somente quebra de linha
OIFS=$IFS
IFS=$'\n'

# Start function to turn possible uses assincronous mode
## portuguese
# Inicia uma função para possibilitar o uso em modo assíncrono
parallel_filter() {
	readarray -t -d"|" myarray <<<"$1"
	PKG_NAME="${myarray[0]}"
	PKG_ID="${myarray[1]}"
	PKG_ICON="${myarray[2]}"
	PKG_DESC="${myarray[3]}"
	PKG_VERSION="${myarray[4]}"
	PKG_CMD="${myarray[5]}"

	# Improve order of packages
	##
	# Melhora a ordem de exibição dos pacotes, funciona em conjunto com o css que irá reordenar de acordo com o id da div, que aqui é representado pela variavel $PKG_ORDER
	PKG_NAME_CLEAN="$(echo "$search" | cut -f1 -d" ")"

	# Verify if package are installed
	## portuguese
	# Verifica se o pacote está instalado
	if [ "$(echo "$SNAP_INSTALLED_LIST" | grep -i -m1 "|$PKG_CMD|")" != "" ]; then
		PKG_INSTALLED=$"Remover"
		DIV_SNAP_INSTALLED="appstream_installed"
		PKG_ORDER="SnapP1"
	else
		PKG_INSTALLED=$"Instalar"
		DIV_SNAP_INSTALLED="appstream_not_installed"

		if [ "$(echo "$PKG_NAME $PKG_CMD" | grep -i -m1 "$PKG_NAME_CLEAN")" != "" ]; then
			PKG_ORDER="SnapP2"
		else
			PKG_ORDER="SnapP3"
		fi
	fi

	# Make html code
	## portuguese
	# Cria o codigo html que sera exibido para o usuario

	# If not found use generic icon
	## portuguese
	# Se nao detectar ícone, utiliza um generico
	if [ "$PKG_ICON" = "" ]; then
		cat >>${TMP_FOLDER}/snapbuild.html <<EOF
        <!--$PKG_NAME--><a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=snap_icon><div class=icon_middle><div class=avatar_snap>${PKG_NAME:0:3}</div></div><div id=snap_name>$PKG_NAME<div id=version>$PKG_VERSION</div></div></div><div id=box_snap_desc><div id=snap_desc>$PKG_DESC</div></div><div id=$DIV_SNAP_INSTALLED>$PKG_INSTALLED</div></a></div></div>
EOF
	else
		cat >>${TMP_FOLDER}/snapbuild.html <<EOF
        <!--$PKG_NAME--><a onclick="disableBody();" href="view_snap.sh.htm?pkg_id=$PKG_ID"><div class="col s12 m6 l3" id="$PKG_ORDER"><div class="showapp"><div id=snap_icon><div class=icon_middle><img class="icon" loading="lazy" src="$PKG_ICON"></div><div id=snap_name>$PKG_NAME<div id=version>$PKG_VERSION</div></div></div><div id=box_snap_desc><div id=snap_desc>$PKG_DESC</div></div><div id=$DIV_SNAP_INSTALLED>$PKG_INSTALLED</div></a></div></div>
EOF
	fi

	# Close function
	## portuguese
	# Finaliza a função
}

# Start loop
## portuguese
# Inicia o loop, filtrando o conteudo do arquivo ${HOME_FOLDER}/snap.cache

rm -f ${TMP_FOLDER}/snapbuild.html

if [ "$resultFilter_checkbox" = "" ]; then
	cacheFile="${HOME_FOLDER}/snap.cache"
else
	cacheFile="${HOME_FOLDER}/snap_filtered.cache"
fi

COUNT=0
case "$(echo "$search" | wc -w)" in

1)
	for i in $(grep -i -m 60 -e "$(echo "$search" | cut -f1 -d" ")" $cacheFile); do
		let COUNT=COUNT+1
		parallel_filter "$i" &
		if [ "$COUNT" = "60" ]; then
			break
		fi
	done
	;;

2)
	for i in $(grep -i -e "$(echo "$search" | cut -f1 -d" ")" $cacheFile | grep -i -m 60 -e "$(echo "$search" | cut -f2 -d" ")"); do
		let COUNT=COUNT+1
		parallel_filter "$i" &
		if [ "$COUNT" = "60" ]; then
			break
		fi
	done
	;;

*)
	for i in $(grep -i -e "$(echo "$search" | cut -f1 -d" ")" $cacheFile | grep -i -e "$(echo "$search" | cut -f2 -d" ")" | grep -i -m 60 -e "$(echo "$search" | cut -f3 -d" ")"); do
		let COUNT=COUNT+1
		parallel_filter "$i" &
		if [ "$COUNT" = "60" ]; then
			break
		fi
	done
	;;

esac

# Wait to all results before show to the user
## portuguese
# Aguarda todos os resultados antes de exibir para o usuário

wait

# If have result use javascript to show in screen
## portuguese
# Se houver resultados utiliza o javascript para exibir na tela

if [ "$COUNT" -gt "0" ]; then
	echo '<script>
runAvatarSnap();
$(document).ready(function () {
$("#box_snap").show();});
</script>' >>${TMP_FOLDER}/snapbuild.html
fi
echo "$COUNT" >"${TMP_FOLDER}/snap_number.html"
mv -f ${TMP_FOLDER}/snapbuild.html ${TMP_FOLDER}/snap.html

IFS=$OIFS
