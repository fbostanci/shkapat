#!/bin/bash
# Copyright 2010-2012 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.7.0

### Değişkenler - Giriş {{{
AD="${0##*/}"
SURUM=1.7.0

ARAYUZ=0
YENIDEN_BASLAT=0
SIMDI_KAPAT=0
SIMDI_ASKIYA_AL=0
SAAT_ASKIYA_AL=0
DAKIKA_ASKIYA_AL=0
SAAT=0
DAKIKA=0
UNITY=0
HATA_VER=0
# }}}

# TODO: (2.0) KDE den başka masaüstleri için düzgün kapatma desteği araştır.

### Pid denetle {{{
function pid_denetle() {
  local pid ypid=$$ ileti yanit

  if [[ -f /tmp/.shkapat.pid && -n $(ps -p $( < /tmp/.shkapat.pid) -o comm=) ]]
  then
      HATA_VER=1
      pid=$( < /tmp/.shkapat.pid)
  else
      echo "$ypid" > /tmp/.shkapat.pid
  fi

  (( HATA_VER )) && {
    if (( ARAYUZ ))
    then
        ileti="$(printf '%s\n%s' \
                   "Başka bir zamanlanmış görev mevcut. pid=${pid}" \
                   'Şimdi iptal etmek ister misiniz?')"
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown --warningyesno "${ileti}"
            case $? in
              0)
                kill -9 ${pid} &>/dev/null && \
                kdialog --title="${AD^}" --icon=system-shutdown \
                  --msgbox "Görev iptal edildi."
                exit 0 ;;
              1)
                exit 1 ;;
            esac
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --window-icon=gnome-shutdown --sticky --center --fixed --on-top \
              --text "${ileti}"
            case $? in
              0)
                kill -9 ${pid} &>/dev/null && \
                yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
                  --text "Görev iptal edildi." --on-top
                exit 0 ;;
              1)
                exit 1 ;;
            esac
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --question --timeout=10 --window-icon=gnome-shutdown \
              --text "${ileti}"
            case $? in
              0)
                kill -9 ${pid} &>/dev/null && \
                zenity --title="${AD^}" --info --timeout=10 --window-icon=gnome-shutdown \
                  --text "Görev iptal edildi."
                exit 0 ;;
              1)
                exit 1 ;;
            esac
        fi
    else
        printf '%s: %s\n%s\n' "${AD^}" \
          "Başka bir zamanlanmış görev mevcut. pid=${pid}" \
          'Şimdi iptal etmek ister misiniz?'

       read -n 1 yanit
       case ${yanit} in
         [eEyY])
           kill -9 ${pid} &>/dev/null
           printf '%s: %s\n' "${AD^}" \
             'Görev iptal edildi.'
           exit 0 ;;
         [hHnN])
           exit 1 ;;
       esac
    fi
  }
} # }}}

### Bilgi fonksiyonu {{{
function bilgi() {
  local printf_bicim

  if [[ $1 = s ]]
  then
      printf '%s\n\n%s\n\n%s\n%s\n%s\n%s\n' \
        "${AD^} $SURUM" \
        'Copyright (c) 2010-2012 Fatih Bostancı'\
        'Bu uygulama bir özgür yazılımdır: yeniden dağıtabilirsiniz ve/veya'\
        'Özgür Yazılım Vakfı (FSF) tarafından yayımlanan (GPL)  Genel  kamu'\
        'lisansı sürüm 3  veya daha yeni bir sürümünde belirtilen  şartlara'\
        'uymak kaydıyla, üzerinde değişiklik yapabilirsiniz.'
  elif [[ $1 = y ]]
  then
      printf_bicim='\n\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s'
      printf_bicim+='\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s\n%s\n\n'
      printf_bicim+='%s\n%s\n\n%s\n%s\n\n'
      printf "${printf_bicim}" \
        "${AD} [seçenek]" \
        '-k,--kapat' \
        '    Bilgisayarı hemen kapatır.' \
        '-y, --ybaslat, ybaşlat' \
        '    Bilgisayarı hemen yeniden başlatır.' \
        '-a, --ask[ıi]ya-al' \
        '    Bilgisayarı hemen askıya alır.' \
        '-s, --saat <ss:dd>' \
        '    Girilen saatte bilgisayarı kapatır.' \
        '--as, --ask[ıi]ya-al-saat <ss:dd>' \
        '    Girilen saatte sistemi askıya alır.' \
        '-d, --dakika <dakika>' \
        '    Girilen dakika kadar sonra bilgisayarı kapatır.' \
        '--ad, --ask[ıiya]-al-dakika <dakika>' \
        '    Girilen dakika kadar sonra sistemi askıya alır.' \
        '--arayüz, --arayuz, --gui' \
        '    Arayüz uygulamasını başlatır.' \
        '--unity [saat|dakika|yba[sş]lat|kapat|ask[ıi]ya-al|ask[ıi]ya-al-saat|ask[ıi]ya-al-dakika]' \
        '    Unity seçkesi için özel kullanım kipi' \
        '-v, --sürüm, --surum, --version' \
        '    Sürüm bilgisini gösterir.' \
        '-h, --yardım, --yardim' \
        '    Bu yardım çıktısını görüntüler.'
  fi
} # }}}

### Kapat -bilg_kapat {{{
function bilg_kapat() {
  local istek="$1"

  if [[ -n $KDE_SESSION_UID ]]
  then
      if [[ $istek == @(1|2) ]]
      then
          qdbus org.kde.ksmserver /KSMServer logout 0 $istek 2
      elif [[ $istek == 3 ]]
      then
          qdbus --system org.freedesktop.UPower /org/freedesktop/UPower \
            org.freedesktop.UPower.Suspend 
     fi
  else
      if [[ $istek == @(1|2) ]]
      then
          [[ $istek == 2 ]] && istek=Stop || { [[ $istek == 1 ]] && istek=Restart; }
          dbus-send --system --print-reply --dest='org.freedesktop.ConsoleKit' \
            /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.${istek}
     elif [[ $istek == 3 ]]
     then
         dbus-send --system --print-reply --dest='org.freedesktop.UPower' \
           /org/freedesktop/UPower org.freedesktop.UPower.Suspend
     fi
  fi
} # }}}

### Kapat penceresi {{{
function kapat_penceresi() {
  local gor c d=20

  if test -x "$(which kdialog 2>/dev/null)"
  then
      set -e
      gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar "kapatılıyor..." 5)
      qdbus $gor Set org.kde.kdialog.ProgressDialog maximum 20
      for ((c=0; c<20; c++))
      {
        printf '\a'
        qdbus $gor Set org.kde.kdialog.ProgressDialog value $c
        qdbus $gor setLabelText "$d saniye sonra sistem kapatılacak."
        ((d--)); sleep 1
      }
      qdbus $gor close; bilg_kapat 2
  elif test -x "$(which yad 2>/dev/null)"
  then
      (
        for ((c=5; c<100; c+=5))
        {
           printf '%d\n' "$c"; sleep 1
        }
      ) | yad --progress --percentage=5 --title="${AD^}" \
            --text "20 saniye sonra bilgisayar kapatılacak." --auto-close \
            --window-icon=gnome-shutdown --sticky --center \
            --button='Şimdi kapat:0' --button='İptal:1'
          (( $? == 0 )) && bilg_kapat 2 || exit 1
  elif test -x "$(which zenity 2>/dev/null)"
  then
      (
        for ((c=5; c<100; c+=5))
        {
           printf '%d\n' "$c"; sleep 1
        }
      ) | zenity --progress --percentage=5 --title="${AD^}" \
            --text "20 saniye sonra bilgisayar kapatılacak." \
            --window-icon=gnome-shutdown --auto-close
          (( $? == 0 )) && bilg_kapat 2 || exit 1
  else
        for ((c=20; c>0; c--))
        {
           printf "\a%2d%s\r" "$c" \
             " saniye sonra bilgisayar kapatılacak."
           sleep 1
        }
        bilg_kapat 2
  fi
} # }}}

### Askıya_al penceresi {{{
function askiya_al_penceresi() {
  local gor c d=20

  if test -x "$(which kdialog 2>/dev/null)"
  then
      set -e
      gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar "askıya alınıyor..." 5)
      qdbus $gor Set org.kde.kdialog.ProgressDialog maximum 20
      for ((c=0; c<20; c++))
      {
        printf '\a'
        qdbus $gor Set org.kde.kdialog.ProgressDialog value $c
        qdbus $gor setLabelText "$d saniye sonra sistem askıya alınacak."
        ((d--)); sleep 1
      }
      qdbus $gor close; bilg_kapat 3
  elif test -x "$(which yad 2>/dev/null)"
  then
      (
        for ((c=5; c<100; c+=5))
        {
           printf '%d\n' "$c"; sleep 1
        }
      ) | yad --progress --percentage=5 --title="${AD^}" \
            --text "20 saniye sonra sistem askıya alınacak." --auto-close \
            --window-icon=gnome-shutdown --sticky --center \
            --button='Şimdi askıya al:0' --button='İptal:1'
          (( $? == 0 )) && bilg_kapat 3 || exit 1
  elif test -x "$(which zenity 2>/dev/null)"
  then
      (
        for ((c=5; c<100; c+=5))
        {
           printf '%d\n' "$c"; sleep 1
        }
      ) | zenity --progress --percentage=5 --title="${AD^}" \
            --text "20 saniye sonra sistem askıya alınacak." \
            --window-icon=gnome-shutdown --auto-close
          (( $? == 0 )) && bilg_kapat 3 || exit 1
  else
        for ((c=20; c>0; c--))
        {
           printf "\a%2d%s\r" "$c" \
             " saniye sonra sistem askıya alınacak."
           sleep 1
        }
        bilg_kapat 3
  fi
} # }}}

### Değişkenleri ayıkla {{{
uzun_secenekler='saat:,dakika:,ybaşlat,ybaslat,kapat,help,yardım,yardim,'
uzun_secenekler+='surum,sürüm,version,gui,arayuz,arayüz,unity:,askiya-al,'
uzun_secenekler+='askıya-al,askıya-al-saat:,askiya-al-saat:,askıya-al-dakika:,'
uzun_secenekler+='askiya-al-dakika:,as:,ad:'

DES=$(getopt -n "${AD}" -o 'as:d:ykhv' -l "${uzun_secenekler}" -- "$@")
(( $? == 1 )) && exit 1

eval set -- "$DES"

while true
do
  case $1 in
    -a|--ask[ıi]ya-al)
      SIMDI_ASKIYA_AL=1 ;;
    -s|--saat)
      SAAT=1
      shift; girilen_saat="$1" ;;
    --as|--ask[ıi]ya-al-saat)
      SAAT_ASKIYA_AL=1
      shift; aski_girilen_saat="$1" ;;
    -d|--dakika)
      DAKIKA=1
      shift; girilen_dakika="$1" ;;
    --ad|--ask[ıi]ya-al-dakika)
      DAKIKA_ASKIYA_AL=1
      shift; aski_girilen_dakika="$1" ;;
    -y|--yba[şs]lat)
      YENIDEN_BASLAT=1 ;;
    -k|--kapat)
      SIMDI_KAPAT=1 ;;
    --unity)
      UNITY=1
      shift; gorev="$1" ;;
    -v|--s[uü]r[uü]m)
      bilgi s
      exit 0 ;;
    -h|--yard[ıi]m)
      bilgi y
      exit 0 ;;
    --gui|--aray[uü]z)
      ARAYUZ=1 ;;
    --)
      shift
      break ;;
  esac
  shift
done # }}}

### ARAYUZ yonetimi {{{
(( ARAYUZ )) && {
  if test -x "$(which kdialog 2>/dev/null)"
  then
      arayuz=1
      donus=$(kdialog --icon=system-shutdown \
              --title "${AD^}" --radiolist 'İşlemi seçiniz:' \
              yb 'Şimdi yeniden başlat' on \
              kt 'Şimdi kapat' off \
              sp 'Şimdi askıya al' off \
              sa 'Girilecek saatte kapat' off \
              st 'Girilecek saatte askıya al' off \
              dk 'Girilecek dakika sonra kapat' off \
              sd 'Girilecek dakika sonra askıya al.' off)
      (( $? == 1 )) && exit 1

      if [[ $donus = yb ]]
      then
          YENIDEN_BASLAT=1
      elif [[ $donus = kt ]]
      then
          SIMDI_KAPAT=1
      elif [[ $donus = sp ]]
      then
          SIMDI_ASKIYA_AL=1
      elif [[ $donus = sa ]]
      then
          SAAT=1
          girilen_saat=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                         'Kapatılma saatini giriniz <ss:dd>' $(date -d '1 minute' +%H:%M))
          (( $? == 1 )) && exit 1
      elif [[ $donus = st ]]
      then
          SAAT_ASKIYA_AL=1
          aski_girilen_saat=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                              'Askıya alınma saatini giriniz <ss:dd>' $(date -d '1 minute' +%H:%M))
          (( $? == 1 )) && exit 1
      elif [[ $donus = dk ]]
      then
          DAKIKA=1
          girilen_dakika=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                           'dakikayı giriniz <d>' $(date +%-M))
          (( $? == 1 )) && exit 1
      elif [[ $donus = sd ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                                'dakikayı giriniz <d>' $(date +%-M))
          (( $? == 1 )) && exit 1
      fi
  elif test -x "$(which yad 2>/dev/null)"
  then
      arayuz=2
      donus=$(yad --title="${AD^}" --text='İşlemi seçiniz:' \
              --window-icon=gnome-shutdown \
              --sticky --center \
              --width=340 --height=300 \
              --list --hide-column=1 --print-column=1 \
              --column=' ' --column='Seçenekler' --separator='' \
              yb 'Şimdi yeniden başlat' \
              kt 'Şimdi kapat' \
              sp 'Şimdi askıya al' \
              sa 'Girilecek saatte kapat' \
              st 'Girilecek saatte askıya al' \
              dk 'Girilecek dakika kadar sonra kapat' \
              sd 'Girilecek dakika kadar sonra askıya al')
      (( $? == 1 )) && exit 1

      if [[ $donus = yb ]]
      then
          YENIDEN_BASLAT=1
      elif [[ $donus = kt ]]
      then
          SIMDI_KAPAT=1
      elif [[ $donus = sp ]]
      then
          SIMDI_ASKIYA_AL=1
      elif [[ $donus = sa ]]
      then
          SAAT=1
          girilen_saat=$(yad --title="${AD^}" --text 'Kapatılma saatini giriniz [ss:dd]' \
                         --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                         --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = st ]]
      then
          SAAT_ASKIYA_AL=1
          aski_girilen_saat=$(yad --title="${AD^}" --text 'Askıya alınma saatini giriniz [ss:dd]' \
                              --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                              --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = dk ]]
      then
          DAKIKA=1
          girilen_dakika=$(yad --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                           --entry --entry-text="$(date -d +%-M)" \
                           --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = sd ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(yad --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                                --entry --entry-text="$(date -d +%-M)" \
                                --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      fi
  elif test -x "$(which zenity 2>/dev/null)"
  then
      arayuz=3
      donus=$(zenity --title="${AD^}" --width 360 --height 300 --text='İşlemi seçiniz:' \
              --window-icon=gnome-shutdown --hide-column=1 --hide-header --print-column=1 \
              --column=' ' --column=' ' --list \
              yb 'Şimdi yeniden başlat' \
              kt 'Şimdi kapat' \
              sp 'Şimdi askıya al' \
              sa 'Girilecek saatte kapat' \
              st 'Girilecek saatte askıya al' \
              dk 'Girilecek dakika kadar sonra kapat' \
              sd 'Girilecek dakika kadar sonra askıya al')
      (( $? == 1 )) && exit 1

      if [[ $donus = yb ]]
      then
          YENIDEN_BASLAT=1
      elif [[ $donus = kt ]]
      then
          SIMDI_KAPAT=1
      elif [[ $donus = sp ]]
      then
          SIMDI_ASKIYA_AL=1
      elif [[ $donus = sa ]]
      then
          SAAT=1
          girilen_saat=$(zenity --title="${AD^}" --text 'Kapatılma saatini giriniz [ss:dd]' \
                         --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                         --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = st ]]
      then
          SAAT_ASKIYA_AL=1
          aski_girilen_saat=$(zenity --title="${AD^}" --text 'Askıya alınma saatini giriniz [ss:dd]' \
                              --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                              --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = dk ]]
      then
          DAKIKA=1
          girilen_dakika=$(zenity --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                           --entry --entry-text="$(date +%-M)" \
                           --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = sd ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(zenity --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                                --entry --entry-text="$(date +%-M)" \
                                --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      fi
  fi
} # }}}

### UNITY yönetimi {{{
(( UNITY )) && {
  ARAYUZ=1
  if test -x "$(which kdialog 2>/dev/null)"
  then
      arayuz=1
      if [[ $gorev = yba[sş]lat ]]
      then
          YENIDEN_BASLAT=1
      elif [[ $gorev = kapat ]]
      then
          SIMDI_KAPAT=1
      elif [[ $gorev = ask[ıi]ya-al ]]
      then
          SIMDI_ASKIYA_AL=1
      elif [[ $gorev = saat ]]
      then
          SAAT=1
          girilen_saat=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                         'Kapatılma saatini giriniz <ss:dd>' $(date -d '1 minute' +%H:%M))
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-saat ]]
      then
          SAAT_ASKIYA_AL=1
          aski_girilen_saat=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                              'Askıya alınma saatini giriniz <ss:dd>' $(date -d '1 minute' +%H:%M))
          (( $? == 1 )) && exit 1
      elif [[ $gorev = dakika ]]
      then
          DAKIKA=1
          girilen_dakika=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                           'dakikayı giriniz <d>' $(date +%-M))
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-dakika ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(kdialog --icon=system-shutdown --title "${AD^}" --inputbox \
                                'dakikayı giriniz <d>' $(date +%-M))
          (( $? == 1 )) && exit 1
      fi
  elif test -x "$(which yad 2>/dev/null)"
  then
      arayuz=2
      if [[ $gorev = yba[sş]lat ]]
      then
          YENIDEN_BASLAT=1
      elif [[ $gorev = kapat ]]
      then
          SIMDI_KAPAT=1
      elif [[ $gorev = ask[ıi]ya-al ]]
      then
          SIMDI_ASKIYA_AL=1
      elif [[ $gorev = saat ]]
      then
          SAAT=1
          girilen_saat=$(yad --title="${AD^}" --text 'Kapatılma saatini giriniz [ss:dd]' \
                         --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                         --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-saat ]]
      then
          SAAT_ASKIYA_AL=1
          aski_girilen_saat=$(yad --title="${AD^}" --text 'Askıya alınma saatini giriniz [ss:dd]' \
                              --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                              --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = dakika ]]
      then
          DAKIKA=1
          girilen_dakika=$(yad --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                           --entry --entry-text="$(date -d +%-M)" \
                           --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-dakika ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(yad --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                                --entry --entry-text="$(date -d +%-M)" \
                                --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      fi
  elif test -x "$(which zenity 2>/dev/null)"
  then
      arayuz=3
      if [[ $gorev = yba[sş]lat ]]
      then
          YENIDEN_BASLAT=1
      elif [[ $gorev = kapat ]]
      then
          SIMDI_KAPAT=1
      elif [[ $gorev = ask[ıi]ya-al ]]
      then
          SIMDI_ASKIYA_AL=1
      elif [[ $gorev = saat ]]
      then
          SAAT=1
          girilen_saat=$(zenity --title="${AD^}" --text 'Kapatılma saatini giriniz [ss:dd]' \
                         --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                         --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-saat ]]
      then
          SAAT_ASKIYA_AL=1
          aski_girilen_saat=$(zenity --title="${AD^}" --text 'Askıya alınma saatini giriniz [ss:dd]' \
                              --entry --entry-text="$(date -d '1 minute' +%H:%M)" \
                              --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = dakika ]]
      then
          DAKIKA=1
          girilen_dakika=$(zenity --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                           --entry --entry-text="$(date +%-M)" \
                           --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-dakika ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(zenity --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                                --entry --entry-text="$(date +%-M)" \
                                --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      fi
  fi
} # }}}

### YENIDEN_BASLAT yönetimi {{{
(( YENIDEN_BASLAT )) && {
  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          set -e; d=5
          gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar "yeniden başlatılıyor..." 20)
          qdbus $gor Set org.kde.kdialog.ProgressDialog maximum 5
          for ((c=0; c<5; c++))
          {
            printf '\a'
            qdbus $gor Set org.kde.kdialog.ProgressDialog value $c
            qdbus $gor setLabelText "$d saniye sonra sistem yeniden başlatılacak."
            ((d--)); sleep 1
          }
          qdbus $gor close
      elif (( arayuz == 2 ))
      then
          (
            for ((c=20; c<100; c+=20))
            {
              printf '%d\n' "$c"; sleep 1
            }
          ) | yad --progress --percentage=20 --title="${AD^}" \
                --text "5 saniye sonra bilgisayar yeniden başlatılacak." --auto-close \
                --window-icon=gnome-shutdown --sticky --center \
                --button='İptal:1'
              (( $? == 1 )) && exit 1
      elif (( arayuz == 3 ))
      then
          (
            for ((c=20; c<100; c+=20))
            {
              printf '%d\n' "$c"; sleep 1
            }
          ) | zenity --progress --percentage=20 --title="${AD^}" \
                --text "5 saniye sonra bilgisayar yeniden başlatılacak." \
                --window-icon=gnome-shutdown --auto-close
              (( $? == 1 )) && exit 1
      fi
  else
      for ((i=3; i>0; i--))
      {
        printf "%s\a\t" "$i"
        sleep 1
      }
      printf '\n\n%s\a\n' 'Yeniden başlatılıyor...'
  fi
  bilg_kapat 1
} # }}}

# SIMDI_ASKIYA_AL yönetimi {{{
(( SIMDI_ASKIYA_AL )) && {
  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          set -e; d=5
          gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar "askıya alınıyor..." 20)
          qdbus $gor Set org.kde.kdialog.ProgressDialog maximum 5
          for ((c=0; c<5; c++))
          {
            printf '\a'
            qdbus $gor Set org.kde.kdialog.ProgressDialog value $c
            qdbus $gor setLabelText "$d saniye sonra sistem askıya alınacak."
            ((d--)); sleep 1
          }
          qdbus $gor close
      elif (( arayuz == 2 ))
      then
          (
            for ((c=20; c<100; c+=20))
            {
              printf '%d\n' "$c"; sleep 1
            }
          ) | yad --progress --percentage=20 --title="${AD^}" \
                --text "5 saniye sonra sistem askıya alınacak." --auto-close \
                --window-icon=gnome-shutdown --sticky --center \
                --button='İptal:1'
              (( $? == 1 )) && exit 1
      elif (( arayuz == 3 ))
      then
          (
            for ((c=20; c<100; c+=20))
            {
              printf '%d\n' "$c"; sleep 1
            }
          ) | zenity --progress --percentage=20 --title="${AD^}" \
                --text "5 saniye sonra sistem askıya alınacak." \
                --window-icon=gnome-shutdown --auto-close
              (( $? == 1 )) && exit 1
      fi
  else
      for ((i=3; i>0; i--))
      {
        printf "%s\a\t" "$i"
        sleep 1
      }
      printf '\n\n%s\a\n' 'Askıya alınıyor...'
  fi
  bilg_kapat 3
} # }}}

# SIMDI_KAPAT yönetimi {{{
(( SIMDI_KAPAT )) && {
  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          set -e; d=5
          gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar "kapatılıyor..." 20)
          qdbus $gor Set org.kde.kdialog.ProgressDialog maximum 5
          for ((c=0; c<5; c++))
          {
            printf '\a'
            qdbus $gor Set org.kde.kdialog.ProgressDialog value $c
            qdbus $gor setLabelText "$d saniye sonra sistem kapatılacak."
            ((d--)); sleep 1
          }
          qdbus $gor close
      elif (( arayuz == 2 ))
      then
          (
            for ((c=20; c<100; c+=20))
            {
              printf '%d\n' "$c"; sleep 1
            }
          ) | yad --progress --percentage=20 --title="${AD^}" \
                --text "5 saniye sonra sistem kapatılacak" --auto-close \
                --window-icon=gnome-shutdown --sticky --center \
                --button='İptal:1'
              (( $? == 1 )) && exit 1
      elif (( arayuz == 3 ))
      then
          (
            for ((c=20; c<100; c+=20))
            {
              printf '%d\n' "$c"; sleep 1
            }
          ) | zenity --progress --percentage=20 --title="${AD^}" \
                --text "5 saniye sonra sistem kapatılacak" \
                --window-icon=gnome-shutdown --auto-close
              (( $? == 1 )) && exit 1
      fi
  else
      for ((i=3; i>0; i--))
      {
        printf "%s\a\t" "$i"
        sleep 1
      }
      printf '\n\n%s\a\n' 'Kapatılıyor...'
  fi
  bilg_kapat 2
} # }}}

### DAKIKA yönetimi {{{
(( DAKIKA )) && {
  pid_denetle
  [[ -n $(tr -d 0-9 <<<$girilen_dakika) ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Hatalı dakika: \`%s'\n" "$girilen_dakika")"
            exit 1
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --window-icon=gnome-shutdown \
              --text "$(printf "Hatalı dakika: \`%s'" "$girilen_dakika")" \
              --timeout=10 --sticky --center --fixed
            exit 1
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Hatalı dakika: \`%s'" "$girilen_dakika")" \
              --window-icon=gnome-shutdown --timeout=10
            exit 1
        fi
    else
        printf "%s: Hatalı dakika: \`%s'\n" "$AD" "$girilen_dakika"
        exit 1
    fi
  }

  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf "Sisteminiz %d dakika sonra kapatılacak." "$girilen_dakika")" &
      elif (( arayuz == 2 ))
      then
          yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf "Sisteminiz %d dakika sonra kapatılacak." "$girilen_dakika")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info \
            --text "$(printf "Sisteminiz %d dakika sonra kapatılacak." "$girilen_dakika")" \
            --window-icon=gnome-shutdown --timeout=10 &
      fi
  else
      printf "%s: sisteminiz %d dakika sonra kapatılacak.\a\n" "${AD}" "$girilen_dakika"
  fi

  bekle=$((girilen_dakika * 60 - 20))
  sleep $bekle; kapat_penceresi
} # }}}

### DAKIKA_ASKIYA_AL yönetimi {{{
(( DAKIKA_ASKIYA_AL )) && {
  pid_denetle
  [[ -n $(tr -d 0-9 <<<$aski_girilen_dakika) ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Hatalı dakika: \`%s'\n" "$aski_girilen_dakika")"
            exit 1
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --window-icon=gnome-shutdown \
              --text "$(printf "Hatalı dakika: \`%s'" "$aski_girilen_dakika")" \
              --timeout=10 --sticky --center --fixed
            exit 1
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Hatalı dakika: \`%s'" "$aski_girilen_dakika")" \
              --window-icon=gnome-shutdown --timeout=10
            exit 1
        fi
    else
        printf "%s: Hatalı dakika: \`%s'\n" "$AD" "$aski_girilen_dakika"
        exit 1
    fi
  }

  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf "Sisteminiz %d dakika sonra askıya alınacak." "$aski_girilen_dakika")" &
      elif (( arayuz == 2 ))
      then
          yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf "Sisteminiz %d dakika sonra askıya alınacak." "$aski_girilen_dakika")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info \
            --text "$(printf "Sisteminiz %d dakika sonra askıya alınacak." "$aski_girilen_dakika")" \
            --window-icon=gnome-shutdown --timeout=10 &
      fi
  else
      printf "%s: Sisteminiz %d dakika sonra askıya alınacak.\a\n" "${AD}" "$aski_girilen_dakika"
  fi

  bekle=$((aski_girilen_dakika * 60 - 20))
  sleep $bekle; askiya_al_penceresi
} # }}}

# SAAT yönetimi {{{
(( SAAT )) && {
  pid_denetle
  [[ $girilen_saat != @([0-2][0-9]:[0-5][0-9]) ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown --error "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$girilen_saat'" \
              "Saati ss:dd biçiminde giriniz.")"
            exit 1
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$girilen_saat'" \
              "Saati ss:dd biçiminde giriniz.")" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
            exit 1
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$girilen_saat'" \
              "Saati ss:dd biçiminde giriniz.")" \
              --window-icon=gnome-shutdown --timeout=10
            exit 1
        fi
    else
        printf '%s: %s\n%s\n' "$AD" \
          "girilen saat ya da saat biçimi hatalı." \
          "Saati ss:dd biçiminde giriniz"
        exit 1
    fi
  }
  saat=$(cut -d':' -f1 <<<$girilen_saat | sed 's:^[0]*::')
  dakika=$(cut -d':' -f2 <<<$girilen_saat | sed 's:^[0]*::')

  [[ -z $dakika ]] && dakika=0
  [[ -z $saat   ]] && saat=0

  [[ $saat -gt 23 ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")"
            exit 1
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
            exit 1
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --window-icon=gnome-shutdown --timeout=10
            exit 1
        fi
    else
        printf "%s: girilen saat 23'ten büyük olamaz.\n" "$AD" >&2
        exit 1
    fi
  }

  [[ $saat$dakika -gt $(date +%-H%-M) ]] && { bekle=$(($(date -d "$girilen_saat" +%s) - $(date +%s))); gun=''; } || \
    { bekle=$((86400 - $(date +%s) + $(date -d "$girilen_saat" +%s))); gun='(Yarın)'; }

  (( (bekle-20) > 0 )) && bekle=$((bekle-20))
  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf 'Bilgisayarınızın kapatılacağı saat: %s %s' "$girilen_saat" "${gun}")" &
      elif (( arayuz == 2 ))
      then
            yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf 'Bilgisayarınızın kapatılacağı saat: %s %s' "$girilen_saat" "${gun}")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info --timeout=10 --window-icon=gnome-shutdown \
            --text "$(printf 'Bilgisayarınızın kapatılacağı saat: %s %s' "$girilen_saat" "${gun}")" &
      fi
  else
      printf '%s: bilgisayarınızın kapatılacağı saat: %s %s\a\n' "${AD}" "$girilen_saat" "${gun}"
  fi
  sleep $bekle; kapat_penceresi
} # }}}

# SAAT_ASKIYA_AL yönetimi {{{
(( SAAT_ASKIYA_AL )) && {
  pid_denetle
  [[ $aski_girilen_saat != @([0-2][0-9]:[0-5][0-9]) ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown --error "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$aski_girilen_saat'" \
              "Saati ss:dd biçiminde giriniz.")"
            exit 1
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$aski_girilen_saat'" \
              "Saati ss:dd biçiminde giriniz.")" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
            exit 1
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$aski_girilen_saat'" \
              "Saati ss:dd biçiminde giriniz.")" \
              --window-icon=gnome-shutdown --timeout=10
            exit 1
        fi
    else
        printf '%s: %s\n%s\n' "$AD" \
          "girilen saat ya da saat biçimi hatalı." \
          "Saati ss:dd biçiminde giriniz"
        exit 1
    fi
  }
  saat=$(cut -d':' -f1 <<<$aski_girilen_saat | sed 's:^[0]*::')
  dakika=$(cut -d':' -f2 <<<$aski_girilen_saat | sed 's:^[0]*::')

  [[ -z $dakika ]] && dakika=0
  [[ -z $saat   ]] && saat=0

  [[ $saat -gt 23 ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")"
            exit 1
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
            exit 1
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --window-icon=gnome-shutdown --timeout=10
            exit 1
        fi
    else
        printf "%s: girilen saat 23'ten büyük olamaz.\n" "$AD" >&2
        exit 1
    fi
  }

  [[ $saat$dakika -gt $(date +%-H%-M) ]] && { bekle=$(($(date -d "$aski_girilen_saat" +%s) - $(date +%s))); gun=''; } || \
    { bekle=$((86400 - $(date +%s) + $(date -d "$aski_girilen_saat" +%s))); gun='(Yarın)'; }

  (( (bekle-20) > 0 )) && bekle=$((bekle-20))
  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf 'Sisteminizin askıya alınacağı saat: %s %s' "$aski_girilen_saat" "${gun}")" &
      elif (( arayuz == 2 ))
      then
            yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf 'Sisteminizin askıya alınacağı saat: %s %s' "$aski_girilen_saat" "${gun}")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info --timeout=10 --window-icon=gnome-shutdown \
            --text "$(printf 'Sisteminizin askıya alınacağı saat: %s %s' "$aski_girilen_saat" "${gun}")" &
      fi
  else
      printf '%s: sisteminizin askıya alınacağı saat: %s %s\a\n' "${AD}" "$aski_girilen_saat" "${gun}"
  fi
  sleep $bekle; askiya_al_penceresi
} # }}}

# vim:set ts=2 sw=2 et: