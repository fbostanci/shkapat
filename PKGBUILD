# Maintainer: Fatih Bostancı <faopera@gmail.com>

pkgname=shkapat
pkgver=2.0.0
pkgrel=1
pkgdesc="Süre ayarlı bilgisayar kapatıcı"
license=('GPL3')
arch=('any')
depends=()
url="https://gitlab.com/fbostanci/shkapat"
source=('git+https://gitlab.com/fbostanci/shkapat.git')
md5sums=('SKIP')

pkgver() {
  cd "$pkgname"
  cat VERSION
}

package() {
  cd "${srcdir}"/${pkgname}

  #${EDITOR:-nano} Makefile
  make DESTDIR="${pkgdir}" install
}

# vim:set ts=2 sw=2 et:
