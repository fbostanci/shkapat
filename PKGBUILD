# Maintainer: Fatih Bostancı <faopera@gmail.com>

pkgname=shkapat
pkgver=1.8.1
pkgrel=1
pkgdesc="Süre ayarlı bilgisayar kapatıcı"
license=('GPL3')
arch=('any')
depends=()
url="https://gitorious.org/shkapat"
install=${pkgname}.install
source=("https://launchpad.net/~fbostanci/+archive/distroguide/+files/shkapat_${pkgver}-${pkgrel}%7Edistroguide%7Eprecise.tar.gz")
sha256sums=('25017532881ff1f0b6d34135f06fc1c3c8a5c42bebc3416e7f6eeb62361fa4bd')

package() {
  cd "${srcdir}"/${pkgname}

  #${EDITOR:-${vim:-vi}} Makefile
  msg "make başlatılıyor..."
  make DESTDIR="${pkgdir}" install
}

# vim:set ts=2 sw=2 et:
