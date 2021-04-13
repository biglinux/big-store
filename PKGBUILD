# Maintainer: Bruno Goncalves <bigbruno@gmail.com>

pkgname=big-store
pkgver=1.0.0
pkgrel=0
arch=('any')
license=('GPL')
url="https://github.com/biglinux/big-store"
pkgdesc="A friendly interface using bigbashview and that uses a large part of pamac resources to offer users a practical and simple interface"
depends=('pamac-gtk' 'jq' 'gawk' 'sed' 'yay' 'rxvt-unicode' 'xorg-xwininfo')
optdepends=('pamac-snap-plugin' 'pamac-flatpak-plugin')
source=("git+https://github.com/biglinux/big-store.git")
md5sums=(SKIP)


package() {
    cp -r "${srcdir}/usr/" "${pkgdir}/"
    mv "${pkgdir}/usr/lib/python3/dist-packages/bbv/" "${pkgdir}/usr/lib/python3.9/bbv/"
    ln -s /usr/share/bigbashview/bcc/apps/big-store/big-store-start.sh /usr/bin/big-store
}


