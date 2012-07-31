# Maintainer: Fatih Bostancı <faopera@gmail.com>

pkgname=shkapat
pkgver=1.6.0
pkgrel=1
pkgdesc="Ayarlanabilir bilgisayar kapatıcı"
license=('GPL3')
arch=('any')
depends=()
url="https://gitorious.org/shkapat"
makedepends=('git')
install=${pkgname}.install
_gitroot='git://gitorious.org/shkapat/shkapat.git'
_gitname='shkapat'

build() {
  msg "Gitorious GIT sunucusuna bağlanılıyor..."

  if [ -d "${srcdir}/${_gitname}" ]
  then
       cd ${_gitname} && git pull origin
  else
       git clone "${_gitroot}" && cd ${_gitname}
  fi

 #${EDITOR:-${vim:-vi}} Makefile
  msg "make başlatılıyor..."
  make DESTDIR="${pkgdir}" install
}

# vim:set ts=2 sw=2 et:
