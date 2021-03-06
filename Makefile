#
#
#	Shkapat 2.0.0 Makefile
#
#

SHELL    = /bin/bash
DESTDIR  =
surum    = $(shell cat VERSION)
duzenleme  = $(shell git log -1 --pretty=format:'%ad' --abbrev-commit --date=short 2>/dev/null | tr -d -- '-')

ifeq "$(duzenleme)" ""
	duzenleme = bilinmeyen
endif

all:
	@echo "Nothing to make, use 'make install' to perform an installation."

install:
	install -vDm755 shkapat.bash $(DESTDIR)/usr/bin/shkapat
	install -vd $(DESTDIR)/usr/share/icons/hicolor/{16x16,22x22,32x32,48x48,64x64,128x128}/apps
	install -vDm755 shkapat.desktop $(DESTDIR)/usr/share/applications/shkapat.desktop
	install -vm644 icons/16/shkapat.png $(DESTDIR)/usr/share/icons/hicolor/16x16/apps/shkapat.png
	install -vm644 icons/22/shkapat.png $(DESTDIR)/usr/share/icons/hicolor/22x22/apps/shkapat.png
	install -vm644 icons/32/shkapat.png $(DESTDIR)/usr/share/icons/hicolor/32x32/apps/shkapat.png
	install -vm644 icons/48/shkapat.png $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/shkapat.png
	install -vm644 icons/64/shkapat.png $(DESTDIR)/usr/share/icons/hicolor/64x64/apps/shkapat.png
	install -vm644 icons/128/shkapat.png $(DESTDIR)/usr/share/icons/hicolor/128x128/apps/shkapat.png

uninstall:
	@rm -f $(DESTDIR)/usr/bin/shkapat
	@rm -f $(DESTDIR)/usr/share/applications/shkapat.desktop
	@rm -f $(DESTDIR)/usr/share/icons/hicolor/16x16/apps/shkapat.png
	@rm -f $(DESTDIR)/usr/share/icons/hicolor/22x22/apps/shkapat.png
	@rm -f $(DESTDIR)/usr/share/icons/hicolor/32x32/apps/shkapat.png
	@rm -f $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/shkapat.png
	@rm -f $(DESTDIR)/usr/share/icons/hicolor/64x64/apps/shkapat.png
	@rm -f $(DESTDIR)/usr/share/icons/hicolor/128x128/apps/shkapat.png
	@echo Shkapat sisteminizden kaldırıldı.

dist:
	@echo "Kaynak kod paketi oluşturuluyor. Lütfen bekleyiniz..."
	@git archive master | xz > shkapat-$(surum).$(duzenleme).tar.xz
	@echo "İşlem tamamlandı. ----------> shkapat-$(surum).$(duzenleme).tar.xz"


.PHONY: all dist install uninstall
