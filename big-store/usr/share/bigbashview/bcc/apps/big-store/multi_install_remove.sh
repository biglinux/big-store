#!/bin/bash

# PKG FILTER
PKG_NATIVE_INSTALL="$(grep 'install,native$' /tmp/big-select.tmp| cut -f1 -d,)"
PKG_NATIVE_REMOVE="$(grep 'remove,native$' /tmp/big-select.tmp| cut -f1 -d,)"

PKG_AUR_INSTALL="$(grep 'install,aur$' /tmp/big-select.tmp| cut -f1 -d,)"
PKG_AUR_REMOVE="$(grep 'remove,aur$' /tmp/big-select.tmp| cut -f1 -d,)"

PKG_FLATPAK_INSTALL="$(grep 'install,flatpak$' /tmp/big-select.tmp| cut -f1 -d,)"
PKG_FLATPAK_REMOVE="$(grep 'remove,flatpak$' /tmp/big-select.tmp| cut -f1 -d,)"

PKG_SNAP_INSTALL="$(grep 'install,snap$' /tmp/big-select.tmp| cut -f1 -d,)"
PKG_SNAP_REMOVE="$(grep 'remove,snap$' /tmp/big-select.tmp| cut -f1 -d,)"

# Install Native and AUR
if [ -n "${PKG_NATIVE_INSTALL}${PKG_AUR_INSTALL}" ]; then 
    yay --noconfirm -Su $PKG_NATIVE_INSTALL $PKG_AUR_INSTALL
fi

# Remove Native and AUR
if [ -n "${PKG_NATIVE_REMOVE}${PKG_AUR_REMOVE}" ]; then 
    yay --noconfirm -Rc $PKG_NATIVE_REMOVE $PKG_AUR_REMOVE
fi

# Install Flatpak
if [ -n "$PKG_FLATPAK_INSTALL" ]; then 
    flatpak install --or-update $PKG_FLATPAK_INSTALL -y
fi

# Remove Flatpak
if [ -n "$PKG_FLATPAK_REMOVE" ]; then 
    flatpak remove $PKG_FLATPAK_REMOVE -y
fi



