#!/usr/bin/env bash
#shellcheck disable=SC2155,SC2034
#shellcheck source=/dev/null

#  bstrlib.sh
#  Description: Big Store installing programs for BigLinux
#
#  Created: 2023/08/11
#  Altered: 2023/08/11
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

function sh_update_cache_snap {
	# Seleciona e cria a pasta para salvar os arquivos para cache da busca
	FOLDER_TO_SAVE_FILES="$HOME/.bigstore/snap_list_files/snap_list"
	FILE_TO_SAVE_CACHE="$HOME/.bigstore/snap.cache"
	FILE_TO_SAVE_CACHE_FILTERED="$HOME/.bigstore/snap_filtered.cache"

	rm -R ~/.bigstore/snap_list_files/
	mkdir -p ~/.bigstore/snap_list_files/

	# Anotação com as opções possíveis para utilizar na API
	#https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=anon_download_url,architecture,channel,download_sha3_384,summary,description,binary_filesize,download_url,last_updated,package_name,prices,publisher,ratings_average,revision,snap_id,license,base,media,support_url,contact,title,content,version,origin,developer_id,developer_name,developer_validation,private,confinement,common_ids&q=office&scope=wide:

	# Anotação com a busca por wps-2019-snap em cache
	# jq -r '._embedded."clickindex:package"[]| select( .package_name == "wps-2019-snap" )' $FOLDER_TO_SAVE_FILES*

	# Faz o download da página inicial
	curl "https://api.snapcraft.io/api/v1/snaps/search?confinement=strict&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media,&scope=wide:" >${FOLDER_TO_SAVE_FILES}

	# Lê na pagina inicial quantas paginas devem ser baixadas e salva o valor na variavel $NUMBER_OF_PAGES
	NUMBER_OF_PAGES="$(jq -r '._links.last' ${FOLDER_TO_SAVE_FILES} | sed 's|.*page=||g;s|"||g' | grep [0-9])"

	# Inicia o download em paralelo de todas as paginas
	PAGE=2
	while [ "$PAGE" -lt "$NUMBER_OF_PAGES" ]; do
		echo "Downloading $PAGE of $NUMBER_OF_PAGES"
		curl "https://api.snapcraft.io/api/v1/snaps/search?confinement=strict,classic&fields=architecture,summary,description,package_name,snap_id,title,content,version,common_ids,binary_filesize,license,developer_name,media,&scope=wide:&page=$PAGE" >>${FOLDER_TO_SAVE_FILES}$PAGE &
		let PAGE=PAGE+1
	done

	# Aguarda o download de todos os arquivos
	wait

	# Filtra o resultado dos arquivos e cria um arquivo de cache que será utilizado nas buscas
	jq -r '._embedded."clickindex:package"[]| .title + "|" + .snap_id + "|" + .media[0].url + "|" + .summary + "|" + .version + "|" + .package_name + "|"' ${FOLDER_TO_SAVE_FILES}* | sort -u >$FILE_TO_SAVE_CACHE
	grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/snap_list.txt "$FILE_TO_SAVE_CACHE" >"$FILE_TO_SAVE_CACHE_FILTERED"
}
export -f sh_update_cache_snap

function sh_update_cache_flatpak {
	rm -f "$HOME/.bigstore/flatpak.cache"
	flatpak search --arch x86_64 "" | sed '/\t/s//|/; /\t/s//|/; /\t/s//|/; /\t/s//|/; /\t/s//|/; /$/s//|/'  | grep '|stable|' | rev | uniq --skip-fields=2 | rev > "$HOME/.bigstore/flatpak.cache"

	for i  in  $(LANG=C flatpak update | grep "^ [1-9]" | awk '{print $2}'); do
		sed -i "s/|${i}.*/&update|/" ~/.bigstore/flatpak.cache 
	done
	grep -Fwf /usr/share/bigbashview/bcc/apps/big-store/list/flatpak_list.txt ~/.bigstore/flatpak.cache > ~/.bigstore/flatpak_filtered.cache
}
export -f sh_update_cache_flatpak

function sh_run_pacman_mirror {
	pacman-mirrors --geoip
	pacman -Syy
}
export -f sh_run_pacman_mirror


function sh_main {
	local execute_app="$1"
	eval "$execute_app"
	return
}

#sh_debug
sh_main "$@"
