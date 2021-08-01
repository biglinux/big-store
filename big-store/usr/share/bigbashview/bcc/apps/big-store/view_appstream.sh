#!/bin/bash
#
# BigLinux Store 
# www.biglinux.com.br
# By Bruno Gonçalves
# 11/01/2020
# License: GPL v2 or greater

#Translation
export TEXTDOMAINDIR="/usr/share/locale"
export TEXTDOMAIN=big-store

HOME_FOLDER="$HOME/.bigstore"
TMP_FOLDER="/tmp/bigstore"
DUMP_CACHE_FILE="${TMP_FOLDER}/view_appstream_dumpcache.html"
APPSTREAM_DESCRIPTION_FILE="${TMP_FOLDER}/appstream_description_cache.html"
APPSTREAM_DESCRIPTION_FILE_SHOW="${TMP_FOLDER}/appstream_description_cache_show.html"
APT_SHOW_CACHE_FILE="${TMP_FOLDER}/apt_show_cache_file.txt"
APT_PKG_INFO_FILE="${TMP_FOLDER}/apt_pkg_info_file.txt"
APT_PKG_URI_FILE="${TMP_FOLDER}/apt_pkg_uri.txt"
MODAL_CONTENT_FILE="${TMP_FOLDER}/modal_content.html"
ADDITIONAL_PACKAGES_TO_INSTALL_SHOW="${TMP_FOLDER}/additional_packages_to_install_show.txt"
PACKAGES_TO_REMOVE_SHOW="${TMP_FOLDER}/packages_to_remove_show.txt"
PACKAGES_TO_UPGRADE_SHOW="${TMP_FOLDER}/packages_to_upgrade_show.txt"
IMPOSSIBLE_SHOW="${TMP_FOLDER}/impossible_show.txt"
APT_DOWNLOAD_SIZE_SHOW="${TMP_FOLDER}/apt_download_size_show.txt"
NUMBER_UPGRADE_PACKAGES_SHOW="${TMP_FOLDER}/number_upgrade_packages_show.txt"
NUMBER_NEW_PACKAGES_SHOW="${TMP_FOLDER}/number_new_packages_show.txt"
NUMBER_REMOVE_PACKAGES_SHOW="${TMP_FOLDER}/number_remove_packages_show.txt"
PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW="${TMP_FOLDER}/packages_to_install_remove_and_upgrade_show.html"
PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW_LINK="${TMP_FOLDER}/packages_to_install_remove_and_upgrade_show_link.html"


LANGUAGE_COMPLETE="$(echo $LANG | sed 's|\..*||g')"
LANGUAGE_SIMPLIFIED="$(echo $LANG | sed 's|\..*||g;s|_.*||g')"

pkg_name="$1"
id="$2"


langCategories=$"Categorias"
langVersionInstalled=$"Versão instalada"
langVersionAvailable=$"Versão disponível"
langVersion=$"Versão"
langRemove=$"Remover"
langInstall=$"Instalar"
langUpgrade=$"Atualizar"
langClose=$"Fechar"
langPackageDeb=$"Pacote .deb"
langDebRight=$"Esse programa está em formato .deb, que possui a melhor integração com o sistema."
langMoreInfo=$"Mais informações"
langGoLeft=$"Voltar"
langDownloadSize=$"Download"
langDepends=$"Dependências a instalar"
langSeeMore=$"Ver mais"


####### Description open
python3 appstream_description.py "${pkg_name}" "$id" > "$APPSTREAM_DESCRIPTION_FILE" &
apt show "$pkg_name" > "$APT_SHOW_CACHE_FILE" &
wait

# Verify language
if [ "$(sed -n "/<description>/,/<\/description>/p;/<\/description>/q" $DUMP_CACHE_FILE | grep "xml:lang=\"$LANGUAGE_SIMPLIFIED\"")" = "" ] && [ "$(grep "Description-$LANGUAGE_SIMPLIFIED" $APT_SHOW_CACHE_FILE)" != "" ]; then

		# Show translated description from apt if appstream dont have translation
		sed -n "/^Description-$LANGUAGE_SIMPLIFIED/,/^Description-md5/p;/^Description-md5/q" $APT_SHOW_CACHE_FILE | sed "s|^Description-md5.*||g;s|^Description-$LANGUAGE_SIMPLIFIED...:||g;s|^Description-$LANGUAGE_SIMPLIFIED:||g;s|^ .$|<br><br>|g" | sed '1 a <br>' > "$APPSTREAM_DESCRIPTION_FILE_SHOW"
	else
		cp -f "$APPSTREAM_DESCRIPTION_FILE" "$APPSTREAM_DESCRIPTION_FILE_SHOW"
fi
####### Description close

LC_ALL=C apt -s install $pkg_name > "$APT_PKG_INFO_FILE" & 
LC_ALL=C apt --print-uris install $pkg_name > "$APT_PKG_URI_FILE" &

wait


INSTALL_BUTTON="0"
MSG_DEPENDS_BROKEN=$"Pacotes com dependências não atendidas: "
MSG_DEPENDS=$"Depende de "
MSG_DEPENDS_NOT_INSTALL=$"mas não vai ser instalado."
MSG_NOT_INSTALLABLE=$"mas não está disponível"

# Show packages to install
ADDITIONAL_PACKAGES_TO_INSTALL=$(sed -n '/following additional packages will be installed:/,/^\S/p' "$APT_PKG_INFO_FILE" | grep "^  "| sed ':a;N;$!ba;s/\n/ /g;s|   | |g;s|  | |g;s|-|\&#8209;|g')

echo "$ADDITIONAL_PACKAGES_TO_INSTALL" > "$ADDITIONAL_PACKAGES_TO_INSTALL_SHOW"

VERIFY_INSTALLED="$(grep "is already the newest version" "$APT_PKG_INFO_FILE")"

# Show packages to remove
PACKAGES_TO_REMOVE=$(sed -n '/following packages will be REMOVED:/,/^\S/p' "$APT_PKG_INFO_FILE" | grep "^  "| sed ':a;N;$!ba;s/\n/ /g;s|   | |g;s|  | |g;s|-|\&#8209;|g')
echo "$PACKAGES_TO_REMOVE" > "$PACKAGES_TO_REMOVE_SHOW"

# Show packages to upgrade
PACKAGES_TO_UPGRADE=$(sed -n '/following packages will be upgraded:/,/^\S/p' "$APT_PKG_INFO_FILE" | grep "^  "| sed ':a;N;$!ba;s/\n/ /g;s|   | |g;s|  | |g;s|-|\&#8209;|g')

echo "$PACKAGES_TO_UPGRADE" > "$PACKAGES_TO_UPGRADE_SHOW"

IMPOSSIBLE="$(grep "requested an impossible situation" "$APT_PKG_INFO_FILE")"

# Show download  size needed
DOWNLOAD_SIZE="$(grep "Need to get" "$APT_PKG_URI_FILE" | sed 's|Need to get ||g;s| of.*||g;s|/.*||g')"
NUMBER_UPGRADE_PACKAGES="$(grep -i "newly installed" "$APT_PKG_URI_FILE" | cut -f1 -d" ")"
NUMBER_NEW_PACKAGES="$(grep -i "newly installed" "$APT_PKG_URI_FILE" | cut -f3 -d" ")"
NUMBER_REMOVE_PACKAGES="$(grep -i "newly installed" "$APT_PKG_URI_FILE" | cut -f6 -d" ")"

echo "$DOWNLOAD_SIZE" > "$APT_DOWNLOAD_SIZE_SHOW"
echo "$NUMBER_UPGRADE_PACKAGES" > "$NUMBER_UPGRADE_PACKAGES_SHOW"
#echo "$NUMBER_NEW_PACKAGES" > "$NUMBER_NEW_PACKAGES_SHOW"
echo "$(($NUMBER_UPGRADE_PACKAGES + $NUMBER_NEW_PACKAGES))" > "$NUMBER_NEW_PACKAGES_SHOW"


echo "$NUMBER_REMOVE_PACKAGES" > "$NUMBER_REMOVE_PACKAGES_SHOW"

echo "<pre><code>" > "$MODAL_CONTENT_FILE"
sed -e "s/^[A-Z].*$/&\n/" "$APT_SHOW_CACHE_FILE" >> "$MODAL_CONTENT_FILE"
echo "</code></pre>" >> "$MODAL_CONTENT_FILE"

# if [ "$IMPOSSIBLE" != "" ]; then
#     echo $"Não é possível prosseguir com a instalação." "<br><br>" > "$IMPOSSIBLE_SHOW"
#     grep -A 200 "following information may help to resolve the situation" "$APT_PKG_INFO_FILE" | grep -v "following information may help to resolve the situation" | sed "s|The following packages have unmet dependencies:|$MSG_DEPENDS_BROKEN<br>|g;s|Depends|$MSG_DEPENDS|g;s|but it is not going to be installed|$MSG_DEPENDS_NOT_INSTALL<br>|g;s|but it is not installable|$MSG_NOT_INSTALLABLE<br>|"  >> "$IMPOSSIBLE_SHOW"
# fi
# 
# 
# if [ "$ADDITIONAL_PACKAGES_TO_INSTALL" != "" ]; then
#     echo "<pre><code>" $"Dependencias a serem instaladas:" "<br><div id=additional_packages_to_install> $ADDITIONAL_PACKAGES_TO_INSTALL</div><br></code></pre>" > $PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW
# 	echo "<a class=\"modal-trigger\" href=\"#modal2\">$langSeeMore</a>" > "$PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW_LINK"
# fi
# 
# if [ "$PACKAGES_TO_REMOVE" != "" ]; then
#     echo "<pre><code>" $"Pacotes a remover:" "<br><div id=packages_to_remove> $PACKAGES_TO_REMOVE</div><br></code></pre>" >> $PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW
# 	echo "$langSeeMore" > "$PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW_LINK"
# fi
# 
# if [ "$PACKAGES_TO_UPGRADE" != "" ]; then
#     echo "<pre><code>" $"Pacotes para atualizar:" "<br><div id=packages_to_upgrade> $PACKAGES_TO_UPGRADE</div><br></code></pre>" >> $PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW
# 	echo "$langSeeMore" > "$PACKAGES_TO_INSTALL_REMOVE_AND_UPGRADE_SHOW_LINK"
# fi

