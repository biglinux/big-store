#!/bin/bash
##################################
#  Author Create: Bruno Gonçalves (www.biglinux.com.br) 
#  Author Modify: Rafael Ruscher (rruscher@gmail.com)
#  Create Date:    2020/01/11
#  Modify Date:    2022/05/09 
#  
#  Description: Big Store installing programs for BigLinux
#  
#  Licensed by GPL V2 or greater
##################################

TMP_FOLDER="/tmp/bigstore"


rm -f ${TMP_FOLDER}/appstreambuild.html

echo "" > ${TMP_FOLDER}/upgradeable.txt
pacman -Qu | cut -f1 -d" " >> ${TMP_FOLDER}/upgradeable.txt

 ./search_appstream_pamac.py "${@}" >> ${TMP_FOLDER}/appstreambuild.html
 
 mv ${TMP_FOLDER}/appstreambuild.html ${TMP_FOLDER}/appstream.html
