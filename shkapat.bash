#!/bin/bash
# Copyright 2010-2013 Fatih Bostancı <faopera@gmail.com>
# GPLv3
# v1.8.2

### Değişkenler - Giriş {{{
AD="${0##*/}"
SURUM=1.8.2

ARAYUZ=0
YENIDEN_BASLAT=0
SIMDI_KAPAT=0
SIMDI_ASKIYA_AL=0
SAAT_ASKIYA_AL=0
DAKIKA_ASKIYA_AL=0
OTURUM_KAPAT=0
SAAT=0
DAKIKA=0
UCBIRIM=0
DIALOG=0
UNITY=0
HATA_VER=0
# }}}

# TODO: (2.0) KDE den başka masaüstleri için düzgün kapatma desteği araştır.
# TODO: (2.0) systemd desteği.
# TODO: (1.9) KDE için oturum kapatma desteği ekle. (Diğer masaüstleri için destek varsa 2.0'da ekle.)
# TODO: (1.9) kapat_penceresi() ve askiya_al_penceresi() fonk.larını birleştir. ##TAMAM##
# TODO: (1.9) kod yinelemelerine bak ve kodu durulaştır.

### Pid denetle {{{
function pid_denetle() {
  local ypid=$$
  local pid ileti yanit

  if [[ -f /tmp/.shkapat.pid && -n $(ps -p $( < /tmp/.shkapat.pid) -o comm=) ]]
  then
      HATA_VER=1
      pid=$( < /tmp/.shkapat.pid)
  else
      printf "$ypid" > /tmp/.shkapat.pid
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
                kill -9 ${pid} &>/dev/null &&
                kdialog --title="${AD^}" --icon=system-shutdown \
                  --msgbox 'Görev iptal edildi.'
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
                kill -9 ${pid} &>/dev/null &&
                yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
                  --text 'Görev iptal edildi.' --on-top
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
                kill -9 ${pid} &>/dev/null &&
                zenity --title="${AD^}" --info --timeout=10 --window-icon=gnome-shutdown \
                  --text 'Görev iptal edildi.'
                exit 0 ;;
              1)
                exit 1 ;;
            esac
        fi
    else
        printf '%s: %s\n%s\n' "${AD^}" \
          "Başka bir zamanlanmış görev mevcut. pid=${pid}" \
          'Şimdi iptal etmek ister misiniz [E/h]?'

        read -n1 yanit -t 15 || exit $?
        case ${yanit} in
          [eEyY])
            kill -9 ${pid} &>/dev/null &&
            printf '\n%s: %s\n' "${AD^}" \
              'Görev iptal edildi.'
            exit 0 ;;
          *)
            exit 1 ;;
        esac
    fi
  }
} # }}}

### Bilgi fonksiyonu {{{
function bilgi() {
  local printf_bicim B=$(tput bold) R=$(tput sgr0)

  if [[ $1 = s ]]
  then
      printf '%b\n\n%s\n\n%s\n%s\n%s\n%s\n' \
        "${B}${AD^} $SURUM${R}" \
        'Copyright (c) 2010-2013 Fatih Bostancı'\
        'Bu uygulama bir özgür yazılımdır: yeniden dağıtabilirsiniz ve/veya'\
        'Özgür Yazılım Vakfı (FSF) tarafından yayımlanan (GPL)  Genel  kamu'\
        'lisansı sürüm 3  veya daha yeni bir sürümünde belirtilen  şartlara'\
        'uymak kaydıyla, üzerinde değişiklik yapabilirsiniz.'
  elif [[ $1 = y ]]
  then
      printf_bicim='\n\n%b\n\n%b\n%s\n\n%b\n%s\n\n%b\n%s\n\n%b\n%s\n\n%b'
      printf_bicim+='\n%s\n\n%b\n%s\n\n%b\n%s\n\n%b\n%s\n\n%b\n%s\n\n%b\n'
      printf_bicim+='%s\n\n%b\n%s\n\n%b\n%s\n\n%b\n%s\n\n%b\n\n'
      printf "${printf_bicim}" \
        "${B}${AD} [seçenek]${R}" \
        "${B}-k,--kapat${R}" \
        '    Sistemi hemen kapatır.' \
        "${B}-y, --yba[sş]lat${R}" \
        '    Sistemi hemen yeniden başlatır.' \
        "${B}-a, --ask[ıi]ya-al${R}" \
        '    Sistemi hemen askıya alır.' \
        "${B}-s, --saat <ss:dd>${R}" \
        '    Girilen saatte sistemi kapatır.' \
        "${B}--as, --ask[ıi]ya-al-saat <ss:dd>${R}" \
        '    Girilen saatte sistemi askıya alır.' \
        "${B}-d, --dakika <dakika>${R}"\
        '    Girilen dakika kadar sonra sistemi kapatır.' \
        "${B}--ad, --ask[ıiya]-al-dakika <dakika>${R}" \
        '    Girilen dakika kadar sonra sistemi askıya alır.' \
        "${B}--aray[uü]z, --gui${R}" \
        '    Arayüz uygulamasını başlatır.' \
        "${B}--cli, --u[cç]birim, --terminal${R}" \
        '    Uçbirimden seçke yardımı ile kullanımı başlatır.' \
        "${B}--dialog${R}" \
        '    Uçbirimden dialog uygulaması ile pencereli kullanımı başlatır.' \
        "${B}--unity [saat|dakika|yba[sş]lat|kapat|ask[ıi]ya-al|ask[ıi]ya-al-saat|ask[ıi]ya-al-dakika]${R}" \
        '    Unity seçkesi için özel kullanım kipi' \
        "${B}-v, --sürüm, --surum, --version${R}" \
        '    Sürüm bilgisini gösterir.' \
        "${B}-h, --yardım, --yardim${R}" \
        '    Bu yardım çıktısını görüntüler.' \
        "${B}Çıkmak için q tuşuna basınız.${R}" | less -R
  fi
} # }}}

### Kapat -bilg_kapat {{{
function bilg_kapat() {
  local istek="$1"

  if [[ -n $KDE_SESSION_UID ]]
  then
      if [[ $istek == @(0|1|2) ]]
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
  local grv="$1"
  local gor c ilt_1 ilt_2 ilt_3 islem_sin
  local d=20

  (( grv )) && {
    ilt_1='kapatılıyor...'
    ilt_2='kapatılacak.'
    ilt_3='Şimdi kapat'
    islem_sin=2
  } || {
    ilt_1='askıya alınıyor...'
    ilt_2='askıya alınacak.'
    ilt_3='Şimdi askıya al'
    islem_sin=3
  }

  if test -x "$(which kdialog 2>/dev/null)"
  then
      gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar "${ilt_1}" 5)
      qdbus $gor Set org.kde.kdialog.ProgressDialog maximum 20
      set -e
      for ((c=0; c<20; c++))
      {
        printf '\a'
        qdbus $gor Set org.kde.kdialog.ProgressDialog value $c
        qdbus $gor setLabelText "$d saniye sonra sistem ${ilt_2}"
        ((d--)); sleep 1
      }
      qdbus $gor close; bilg_kapat $islem_sin
  elif test -x "$(which yad 2>/dev/null)"
  then
      (
        for ((c=5; c<100; c+=5))
        {
           printf '%d\n' "$c"; sleep 1
        }
      ) | yad --progress --percentage=5 --title="${AD^}" \
            --text "20 saniye sonra sistem ${ilt_2}" --auto-close \
            --window-icon=gnome-shutdown --sticky --center --on-top \
            --button="${ilt_3}:0" --button='İptal:1'
          (( $? == 0 )) && bilg_kapat $islem_sin || exit $?
  elif test -x "$(which zenity 2>/dev/null)"
  then
      (
        for ((c=5; c<100; c+=5))
        {
           printf '%d\n' "$c"; sleep 1
        }
      ) | zenity --progress --percentage=5 --title="${AD^}" \
            --text "20 saniye sonra sistem ${ilt_2}" \
            --window-icon=gnome-shutdown --auto-close
          (( $? == 0 )) && bilg_kapat $islem_sin || exit $?
  else
        for ((c=20; c>0; c--))
        {
           printf '\a%2d%s\r' "$c" \
             " saniye sonra sistem ${ilt_2}"
           sleep 1
        }
        bilg_kapat $islem_sin
  fi
} # }}}

### Değişkenleri ayıkla {{{
uzun_secenekler='saat:,dakika:,ybaşlat,ybaslat,kapat,help,yardım,yardim,'
uzun_secenekler+='surum,sürüm,version,gui,arayuz,arayüz,unity:,askiya-al,'
uzun_secenekler+='askıya-al,askıya-al-saat:,askiya-al-saat:,askıya-al-dakika:,'
uzun_secenekler+='askiya-al-dakika:,as:,ad:,cli,ucbirim,uçbirim,terminal,dialog'
uzun_secenekler+='oturum-kapat,logout'

DES=$(getopt -n "${AD}" -o 'as:d:ykhvo' -l "${uzun_secenekler}" -- "$@")
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
    -o|--oturum-kapat|--logout)
      OTURUM_KAPAT=1 ;;
    --unity)
      UNITY=1
      shift; gorev="$1" ;;
    -v|--s[uü]r[uü]m)
      bilgi s
      exit 0 ;;
    -h|--yard[ıi]m)
      bilgi y
      exit 0 ;;
    --cli|--u[cç]birim|--terminal)
      UCBIRIM=1 ;;
    --dialog)
      [[ -x "$(which dialog 2>/dev/null)" ]] &&
        DIALOG=1 || { printf 'dialog uygulaması kurulu değil.\n'; exit 1; } ;;
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
              sd 'Girilecek dakika sonra askıya al' off)
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
              --width=340 --height=300 --no-headers \
              --list --hide-column=1 --print-column=1 \
              --column=' ' --column=' ' --separator='' \
              yb 'Şimdi yeniden başlat' \
              kt 'Şimdi kapat' \
              sp 'Şimdi askıya al' \
              sa 'Girilecek saatte kapat' \
              st 'Girilecek saatte askıya al' \
              dk 'Girilecek dakika sonra kapat' \
              sd 'Girilecek dakika sonra askıya al')
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
                           --entry --entry-text="$(date +%-M)" \
                           --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $donus = sd ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(yad --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                                --entry --entry-text="$(date +%-M)" \
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
              dk 'Girilecek dakika sonra kapat' \
              sd 'Girilecek dakika sonra askıya al')
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

### UCBIRIM yönetimi {{{
(( UCBIRIM )) && {
  PS3='İşlem numarasını giriniz: '
  islem_dizisi=( 'Şimdi yeniden başlat'
                 'Şimdi kapat'
                 'Şimdi askıya al'
                 'Girilecek saatte kapat'
                 'Girilecek saatte askıya al'
                 'Girilecek dakika sonra kapat'
                 'Girilecek dakika sonra askıya al'
                 'Seçkeden çık'
               )

  select islem in "${islem_dizisi[@]}"
  do
    if [[ ${islem} = ${islem_dizisi[0]} ]]
    then
        YENIDEN_BASLAT=1
        break
    elif [[ ${islem} = ${islem_dizisi[1]} ]]
    then
        SIMDI_KAPAT=1
        break
    elif [[ ${islem} = ${islem_dizisi[2]} ]]
    then
        SIMDI_ASKIYA_AL=1
        break
    elif [[ ${islem} = ${islem_dizisi[3]} ]]
    then
        read -p 'Kapatılma saatini giriniz <ss:dd> : ' -t 15 girilen_saat || exit $?
        SAAT=1
        break
    elif [[ ${islem} = ${islem_dizisi[4]} ]]
    then
        read -p 'Askıya alınma saatini giriniz <ss:dd> : ' -t 15 aski_girilen_saat || exit $?
        SAAT_ASKIYA_AL=1
        break
    elif [[ ${islem} = ${islem_dizisi[5]} ]]
    then
        read -p 'Kapatılma için dakika giriniz <dakika> : ' -t 15 girilen_dakika || exit $?
        DAKIKA=1
        break
    elif [[ ${islem} = ${islem_dizisi[6]} ]]
    then
        read -p 'Askıya alınma için dakika giriniz <dakika> : ' -t 15 aski_girilen_dakika || exit $?
        DAKIKA_ASKIYA_AL=1
        break
    elif [[ ${islem} = ${islem_dizisi[7]} ]]
    then
        exit 0
    else
        printf 'Geçersiz işlem numarası\n'
    fi
  done
} # }}}

### DIALOG yönetimi {{{
(( DIALOG )) && {
  dialog --backtitle "${AD^} $SURUM" \
    --ok-label 'Onayla' --cancel-label 'Çık' \
    --title "İşlemi seçiniz:" "$@" \
    --radiolist 'Uygulamak istediğiniz işlemi boşluk(space) tuşuyla\nseçip onaylayınız.' 20 61 7 \
    'Şimdi yeniden başlat' '' on \
    'Şimdi kapat' '' off \
    'Şimdi askıya al' '' off \
    'Girilecek saatte kapat' '' off \
    'Girilecek saatte askıya al' '' off \
    'Girilecek dakika sonra kapat' '' off \
    'Girilecek dakika sonra askıya al' '' off 2>/tmp/${AD}-dialog-islem
  (( $? == 0 )) && islem="$( < /tmp/${AD}-dialog-islem)" || exit $?
  rm -f /tmp/${AD}-dialog-islem &>/dev/null

  if [[ ${islem} = 'Şimdi yeniden başlat' ]]
  then
      YENIDEN_BASLAT=1
  elif [[ ${islem} = 'Şimdi kapat' ]]
  then
      SIMDI_KAPAT=1
  elif [[ ${islem} = 'Şimdi askıya al' ]]
  then
      SIMDI_ASKIYA_AL=1
  elif [[ ${islem} = 'Girilecek saatte kapat' ]]
  then
      dialog --backtitle "${AD^} $SURUM" \
        --ok-label 'Onayla' --cancel-label 'Çık' \
        --title "İşlemi seçiniz:" \
        --inputbox "$@" \
        "Kapatılma saatini giriniz <ss:dd> :" 0 0 2>/tmp/${AD}-dialog-islem
      (( $? == 0 )) && girilen_saat="$( < /tmp/${AD}-dialog-islem)" || exit $?
      rm -f /tmp/${AD}-dialog-islem &>/dev/null
      SAAT=1
  elif [[ ${islem} = 'Girilecek saatte askıya al' ]]
  then
      dialog --backtitle "${AD^} $SURUM" \
        --ok-label 'Onayla' --cancel-label 'Çık' \
        --title "İşlemi seçiniz:" \
        --inputbox "$@" \
        "Askıya alınma saatini giriniz <ss:dd> :" 0 0 2>/tmp/${AD}-dialog-islem
      (( $? == 0 )) && aski_girilen_saat="$( < /tmp/${AD}-dialog-islem)" || exit $?
      rm -f /tmp/${AD}-dialog-islem &>/dev/null
      SAAT_ASKIYA_AL=1
  elif [[ ${islem} = 'Girilecek dakika sonra kapat' ]]
  then
      dialog --backtitle "${AD^} $SURUM" \
        --ok-label 'Onayla' --cancel-label 'Çık' \
        --title "İşlemi seçiniz:" \
        --inputbox "$@" \
        "Kapatılma için dakika giriniz <dakika> :" 0 0 2>/tmp/${AD}-dialog-islem
      (( $? == 0 )) && girilen_dakika="$( < /tmp/${AD}-dialog-islem)" || exit $?
      rm -f /tmp/${AD}-dialog-islem &>/dev/null
      DAKIKA=1
  elif [[ ${islem} = 'Girilecek dakika sonra askıya al' ]]
  then
      dialog --backtitle "${AD^} $SURUM" \
        --ok-label 'Onayla' --cancel-label 'Çık' \
        --title "İşlemi seçiniz:" \
        --inputbox "$@" \
        "Askıya alınma için dakika giriniz <dakika> :" 0 0 2>/tmp/${AD}-dialog-islem
      (( $? == 0 )) && aski_girilen_dakika="$( < /tmp/${AD}-dialog-islem)" || exit $?
      rm -f /tmp/${AD}-dialog-islem &>/dev/null
      DAKIKA_ASKIYA_AL=1
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
                           --entry --entry-text="$(date +%-M)" \
                           --sticky --center --fixed --window-icon=gnome-shutdown)
          (( $? == 1 )) && exit 1
      elif [[ $gorev = ask[ıi]ya-al-dakika ]]
      then
          DAKIKA_ASKIYA_AL=1
          aski_girilen_dakika=$(yad --title="${AD^}" --text 'Dakikayı giriniz [d]' \
                                --entry --entry-text="$(date +%-M)" \
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
          gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar 'yeniden başlatılıyor...' 20)
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
                --text '5 saniye sonra sistem yeniden başlatılacak.' --auto-close \
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
                --text '5 saniye sonra sistem yeniden başlatılacak.' \
                --window-icon=gnome-shutdown --auto-close
              (( $? == 1 )) && exit 1
      fi
  else
      for ((i=5; i>0; i--))
      {
        printf '\a%d%s\r' "$i" \
          ' saniye sonra sistem yeniden başlatılacak.'
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
          gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar 'askıya alınıyor...' 20)
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
                --text '5 saniye sonra sistem askıya alınacak.' --auto-close \
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
                --text '5 saniye sonra sistem askıya alınacak.' \
                --window-icon=gnome-shutdown --auto-close
              (( $? == 1 )) && exit 1
      fi
  else
      for ((i=5; i>0; i--))
      {
        printf '\a%d%s\r' "$i" \
          ' saniye sonra sistem askıya alınacak.'
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
          gor=$(kdialog --icon=system-shutdown --title "${AD^}" --progressbar 'kapatılıyor...' 20)
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
                --text '5 saniye sonra sistem kapatılacak' --auto-close \
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
                --text '5 saniye sonra sistem kapatılacak' \
                --window-icon=gnome-shutdown --auto-close
              (( $? == 1 )) && exit 1
      fi
  else
      for ((i=5; i>0; i--))
      {
        printf '\a%d%s\r' "$i" \
          ' saniye sonra sistem kapatılacak.'
        sleep 1
      }
      printf '\n\n%s\a\n' 'Kapatılıyor...'
  fi
  bilg_kapat 2
} # }}}

### DAKIKA yönetimi {{{
(( DAKIKA )) && {
  pid_denetle
  [[ -n $(tr -d 0-9 <<<$girilen_dakika) || -z $girilen_dakika ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Hatalı dakika: \`%s'\n" "${girilen_dakika:-null}")"
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --window-icon=gnome-shutdown \
              --text "$(printf "Hatalı dakika: \`%s'" "${girilen_dakika:-null}")" \
              --timeout=10 --sticky --center --fixed
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Hatalı dakika: \`%s'" "${girilen_dakika:-null}")" \
              --window-icon=gnome-shutdown --timeout=10
        fi
    else
        printf "%s: Hatalı dakika: \`%s'\n" "$AD" "${girilen_dakika:-null}"
    fi
    exit 1
  }
  girilen_dakika=$(sed 's:^[0]*::' <<<$girilen_dakika)
  [[ -z $girilen_dakika ]] && girilen_dakika=0
  (( ! girilen_dakika )) && bekle=0 || bekle=$((girilen_dakika * 60 - 20))

  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf 'Sisteminiz %d dakika sonra kapatılacak.' "$girilen_dakika")" &
      elif (( arayuz == 2 ))
      then
          yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf 'Sisteminiz %d dakika sonra kapatılacak.' "$girilen_dakika")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info \
            --text "$(printf 'Sisteminiz %d dakika sonra kapatılacak.' "$girilen_dakika")" \
            --window-icon=gnome-shutdown --timeout=10 &
      fi
  else
      printf '%s: sisteminiz %d dakika sonra kapatılacak.\a\n' "${AD}" "$girilen_dakika"
  fi
  sleep $bekle && kapat_penceresi 1 || exit $?
} # }}}

### DAKIKA_ASKIYA_AL yönetimi {{{
(( DAKIKA_ASKIYA_AL )) && {
  pid_denetle
  [[ -n $(tr -d 0-9 <<<$aski_girilen_dakika) || -z $aski_girilen_dakika ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Hatalı dakika: \`%s'\n" "${aski_girilen_dakika:-null}")"
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --window-icon=gnome-shutdown \
              --text "$(printf "Hatalı dakika: \`%s'" "${aski_girilen_dakika:-null}")" \
              --timeout=10 --sticky --center --fixed
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Hatalı dakika: \`%s'" "${aski_girilen_dakika:-null}")" \
              --window-icon=gnome-shutdown --timeout=10
        fi
    else
        printf "%s: Hatalı dakika: \`%s'\n" "$AD" "${aski_girilen_dakika:-null}"
    fi
    exit 1
  }
  aski_girilen_dakika=$(sed 's:^[0]*::' <<<$aski_girilen_dakika)
  [[ -z $aski_girilen_dakika ]] && aski_girilen_dakika=0
  (( ! aski_girilen_dakika )) && bekle=0 || bekle=$((aski_girilen_dakika * 60 - 20))

  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf 'Sisteminiz %d dakika sonra askıya alınacak.' "$aski_girilen_dakika")" &
      elif (( arayuz == 2 ))
      then
          yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf 'Sisteminiz %d dakika sonra askıya alınacak.' "$aski_girilen_dakika")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info \
            --text "$(printf 'Sisteminiz %d dakika sonra askıya alınacak.' "$aski_girilen_dakika")" \
            --window-icon=gnome-shutdown --timeout=10 &
      fi
  else
      printf '%s: Sisteminiz %d dakika sonra askıya alınacak.\a\n' "${AD}" "$aski_girilen_dakika"
  fi
  sleep $bekle && kapat_penceresi 0 || exit $?
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
              'Saati ss:dd biçiminde giriniz.')"
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$girilen_saat'" \
              'Saati ss:dd biçiminde giriniz.')" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$girilen_saat'" \
              'Saati ss:dd biçiminde giriniz.')" \
              --window-icon=gnome-shutdown --timeout=10
        fi
        exit 1
    else
        printf '%s: %s\n%s\n' "$AD" \
          'girilen saat ya da saat biçimi hatalı.' \
          'Saati ss:dd biçiminde giriniz.'
        exit 1
    fi
  }
  export $(awk -F':' '{printf "saat=%s\ndakika=%s", $1,$2;}' <<<$girilen_saat)
  sonuc=$(printf "$saat$dakika $(date +%H%M)" | awk '{if($1 > $2) print(1); else if($1 < $2) print(2); else print(0);}')

  [[ $(printf "$saat 23" | awk '{if($1 > $2) print(1); else if($1 < $2) print(2); else print(0);}') == 1  ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")"
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --window-icon=gnome-shutdown --timeout=10
        fi
        exit 1
    else
        printf "%s: girilen saat 23'ten büyük olamaz.\n" "$AD" >&2
        exit 1
    fi
  }

  (( sonuc == 1 )) && { bekle=$(($(date -d "$girilen_saat" +%s) - $(date +%s))); gun=''; } ||
    { bekle=$((86400 - $(date +%s) + $(date -d "$girilen_saat" +%s))); gun='(Yarın)'; }

  (( (bekle-20) > 0 )) && bekle=$((bekle-20)) || kapat_penceresi 1
  if (( ARAYUZ ))
  then
      if (( arayuz == 1 ))
      then
          kdialog --title="${AD^}" --icon=system-shutdown \
            --msgbox "$(printf 'Sisteminizin kapatılacağı saat: %s %s' "$girilen_saat" "${gun}")" &
      elif (( arayuz == 2 ))
      then
          yad --title="${AD^}" --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed \
            --text "$(printf 'Sisteminizin kapatılacağı saat: %s %s' "$girilen_saat" "${gun}")" &
      elif (( arayuz == 3 ))
      then
          zenity --title="${AD^}" --info --timeout=10 --window-icon=gnome-shutdown \
            --text "$(printf 'Sisteminizin kapatılacağı saat: %s %s' "$girilen_saat" "${gun}")" &
      fi
  else
      printf '%s: sisteminizin kapatılacağı saat: %s %s\a\n' "${AD}" "$girilen_saat" "${gun}"
  fi
  sleep $bekle && kapat_penceresi 1 || exit $?
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
              'Saati ss:dd biçiminde giriniz.')"
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$aski_girilen_saat'" \
              'Saati ss:dd biçiminde giriniz.')" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning --text "$(printf '%s\n%s\n' \
              "Girilen saat ya da saat biçimi hatalı: \`$aski_girilen_saat'" \
              'Saati ss:dd biçiminde giriniz.')" \
              --window-icon=gnome-shutdown --timeout=10
        fi
        exit 1
    else
        printf '%s: %s\n%s\n' "$AD" \
          'girilen saat ya da saat biçimi hatalı.' \
          'Saati ss:dd biçiminde giriniz.'
        exit 1
    fi
  }
  export $(awk -F':' '{printf "saat=%s\ndakika=%s", $1,$2;}' <<<$aski_girilen_saat)
  sonuc=$(printf "$saat$dakika $(date +%H%M)" | awk '{if($1 > $2) print(1); else if($1 < $2) print(2); else print(0);}')

  [[ $(printf "$saat 23" | awk '{if($1 > $2) print(1); else if($1 < $2) print(2); else print(0);}') == 1  ]] && {
    if (( ARAYUZ ))
    then
        if (( arayuz == 1 ))
        then
            kdialog --title="${AD^}" --icon=system-shutdown \
              --error "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")"
        elif (( arayuz == 2 ))
        then
            yad --title="${AD^}" --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --timeout=10 --window-icon=gnome-shutdown --sticky --center --fixed
        elif (( arayuz == 3 ))
        then
            zenity --title="${AD^}" --warning \
              --text "$(printf "Girilen saat 23'ten büyük olamaz: \`%s'" "$girilen_saat")" \
              --window-icon=gnome-shutdown --timeout=10
        fi
        exit 1
    else
        printf "%s: girilen saat 23'ten büyük olamaz.\n" "$AD" >&2
        exit 1
    fi
  }

  (( sonuc == 1 )) && { bekle=$(($(date -d "$aski_girilen_saat" +%s) - $(date +%s))); gun=''; } ||
    { bekle=$((86400 - $(date +%s) + $(date -d "$aski_girilen_saat" +%s))); gun='(Yarın)'; }

  (( (bekle-20) > 0 )) && bekle=$((bekle-20)) || kapat_penceresi 0
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
  sleep $bekle && kapat_penceresi 0 || exit $?
} # }}}

# vim:set ts=2 sw=2 et: