#!/bin/bash
#
# BigLinux Store 
# www.biglinux.com.br
# By Bruno Gonçalves
# 11/01/2020
# License: GPL v2 or greater

TMP_FOLDER="/tmp/bigstore"


rm -f ${TMP_FOLDER}/appstreambuild.html

echo "" > ${TMP_FOLDER}/upgradeable.txt
pacman -Qu | cut -f1 -d" " >> ${TMP_FOLDER}/upgradeable.txt

 ./search_appstream_pamac.py "${@}" >> ${TMP_FOLDER}/appstreambuild.html
 
 mv ${TMP_FOLDER}/appstreambuild.html ${TMP_FOLDER}/appstream.html
