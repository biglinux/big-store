#!/bin/bash
 
#snap set system refresh.retain=2
#snap set core snapshots.automatic.retention=no

if [ "$1" = "install" ]; then
    kdialog --msgbox "$2"
    #snap install $2
fi

if [ "$1" = "remove" ]; then
    snap remove $2
fi

if [ "$(snap get system refresh.retain)" != "2" ]; then
    snap set system refresh.retain=2
fi

OIFS=$IFS
IFS=$'\n'

for i  in $(snap list --all | awk '/disabled/{print "snap remove", $1, "--revision", $3}'); do
IFS=$OIFS
$i
IFS=$'\n'
done

IFS=$OIFS
