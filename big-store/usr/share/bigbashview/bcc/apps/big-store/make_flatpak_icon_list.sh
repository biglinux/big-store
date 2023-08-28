#!/bin/bash
##################################
#  Author Create: Bruno Gonçalves (www.biglinux.com.br)
#  Create Date:    2023/08/28
#  
#  Description: Big Store installing programs for BigLinux
#  
#  Licensed by GPL V2 or greater
##################################

# Create a temporary directory to store the files
TMP_DIR="/tmp/bigstore_icons"
mkdir -p $TMP_DIR

# Extract the appstream.xml file which contains the icon names
# of the flatpak packages
xmlstarlet sel -t -m "//component[icon/@type='cached']" -v "concat(name,'|',icon)" -n /var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml | tr ' ' '-' > $TMP_DIR/flatpak_icons.txt

# Extract only the names of the flatpak packages from the flatpak_icons.txt file
cut -f1 -d'|' $TMP_DIR/flatpak_icons.txt | tr '[:upper:]' '[:lower:]' > $TMP_DIR/flatpak_icons_only_names.txt

# Extract the names of all the packages in the AUR pamac cache
zgrep -oE '"Name":"([[:alnum:]#!%$‘&+*-/=?_`{|}~.]*)' /var/tmp/pamac/packages-meta-ext-v1.json.gz | cut -f4 -d'"' > $TMP_DIR/pamac_aur_cache_name_packages.txt

# Extract the names of all the packages in the pacman cache
pacman -Ssq > $TMP_DIR/pacman_name_packages.txt

# Extract the names of the packages in the pamac cache that have icons in flatpak
grep -Fxf $TMP_DIR/pamac_aur_cache_name_packages.txt $TMP_DIR/flatpak_icons_only_names.txt > $TMP_DIR/aur_package_names_having_icons_in_flatpak.txt

# Finally, loop through each package name and extract the icon name and package name
# from the flatpak_icons.txt file and store them in the flatpak_icon.txt file in the
# respective package directory
for pkg in $(<$TMP_DIR/aur_package_names_having_icons_in_flatpak.txt); do

    icon=$(grep -i -m1 "^$pkg|" $TMP_DIR/flatpak_icons.txt)
    pkgname=${icon%%|*}
    pkgname=${pkgname,,}
    icon=${icon##*|}
    echo "icone $pkgname $icon"

    mkdir -p /usr/share/bigbashview/bcc/apps/big-store/description/$pkgname/
    echo "/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/$icon" > /usr/share/bigbashview/bcc/apps/big-store/description/$pkgname/flatpak_icon.txt
done

grep -Fxf $TMP_DIR/pacman_name_packages.txt $TMP_DIR/flatpak_icons_only_names.txt > $TMP_DIR/pacman_names_having_icons_in_flatpak.txt

for pkg in $(<$TMP_DIR/pacman_names_having_icons_in_flatpak.txt); do

    icon=$(grep -i -m1 "^$pkg|" $TMP_DIR/flatpak_icons.txt)
    pkgname=${icon%%|*}
    pkgname=${pkgname,,}
    icon=${icon##*|}

    mkdir -p /usr/share/bigbashview/bcc/apps/big-store/description/$pkgname/
    echo "/var/lib/flatpak/appstream/flathub/x86_64/active/icons/64x64/$icon" > /usr/share/bigbashview/bcc/apps/big-store/description/$pkgname/flatpak_icon.txt
done


echo "See in: $TMP_DIR"
