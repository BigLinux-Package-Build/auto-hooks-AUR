#!/bin/bash

webhooks() {
curl -X POST -H "Accept: application/json" -H "Authorization: token ${{ secrets.WEBHOOK_TOKEN }}" --data '{"event_type": "AUR/linux-xanmod", "client_payload": { "pkgbuild": "", "branch": stable, "url": "https://aur.archlinux.org/$xanmod", "version": "1.2.3"}}' https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches
}


## STABLE ##
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
versite=$major$pkgver$pkgrel

verrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|rt|tt|edge" | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

if [ "$versite" -gt "$verrepo" ]; then
    echo "Envia xanmod stable"
    xanmod=linux-xanmod
    webhooks
fi

## EDGE ##
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-edge | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-edge | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-edge | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
edgeversite=$major$pkgver$pkgrel

edgeverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|rt|tt" | grep edge | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

if [ "$edgeversite" -gt "$edgeverrepo" ]; then
    echo "Envia edge"
    xanmod=linux-xanmod-edge
    webhooks
fi

## LTS ##
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-lts | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-lts | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-lts | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
ltsversite=$major$pkgver$pkgrel

ltsverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "edge|rt|tt" | grep lts | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

if [ "$ltsversite" -gt "$ltsverrepo" ]; then
    echo "Envia lts"
    xanmod=linux-xanmod-lts
    webhooks
fi

## RT ##
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-rt | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-rt | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-rt | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
rtversite=$major$pkgver$pkgrel

rtverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|edge|tt" | grep rt | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

if [ "$rtversite" -gt "$rtverrepo" ]; then
    echo "Envia rt"
    xanmod=linux-xanmod-rt
    webhooks
fi

## RT ##
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-tt | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-tt | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-tt | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
ttversite=$major$pkgver$pkgrel

ttverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|edge|rt" | grep tt | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

if [ "$ttversite" -gt "$ttverrepo" ]; then
    echo "Envia tt"
    xanmod=linux-xanmod-tt
    webhooks
fi


