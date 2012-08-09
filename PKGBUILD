# Maintainer: Fatih Bostancı <faopera@gmail.com>

pkgname=shkapat
pkgver=1.7.1
pkgrel=1
pkgdesc="Süre ayarlı bilgisayar kapatıcı"
license=('GPL3')
arch=('any')
depends=()
url="https://gitorious.org/shkapat"
makedepends=('git')
install=${pkgname}.install
source=("https://launchpad.net/~fbostanci/+archive/distroguide/+files/shkapat_${pkgver}-${pkgrel}%7Edistroguide%7Eprecise.tar.gz")
sha256sums=('2068ff0b23973effc903e3b19cb421c4ebfb18570ec5d05619832a5545d38f2f')

build() {
  cd "${srcdir}"/${pkgname}

  #${EDITOR:-${vim:-vi}} Makefile
  msg "make başlatılıyor..."
  make DESTDIR="${pkgdir}" install
}

# vim:set ts=2 sw=2 et:
