#!/bin/bash

##### Não Editar Start #####
xanmod=
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/$xanmod'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://aur.archlinux.org/'$xanmod'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}
##### NÃO Editar End #####



## STABLE ##
#versão online no site da AUR
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
versite=$major$pkgver$pkgrel

#versão do repositorio do biglinux
verrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|rt|tt|edge" | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

#se versão do site foi maior que a versão do repo local
if [ "$versite" -gt "$verrepo" ]; then
    echo "Envia xanmod stable"
    echo "AUR =$versite"
    echo "Repo =$verrepo"
    xanmod=linux-xanmod
    webhooks
else
echo "Versão do xanmod stable é igual"
fi

## EDGE ##
#versão online no site da AUR
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-edge | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-edge | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-edge | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
edgeversite=$major$pkgver$pkgrel

#versão do repositorio do biglinux
edgeverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|rt|tt" | grep edge | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

#se versão do site foi maior que a versão do repo local
if [ "$edgeversite" -gt "$edgeverrepo" ]; then
    echo "Envia edge"
    echo "AUR =$edgeversite"
    echo "Repo =$edgeverrepo"
    xanmod=linux-xanmod-edge
    webhooks
else
echo "Versão do xanmod edge é igual"
fi

## LTS ##
#versão online no site da AUR
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-lts | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-lts | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-lts | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
ltsversite=$major$pkgver$pkgrel

#versão do repositorio do biglinux
ltsverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "edge|rt|tt" | grep lts | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

#se versão do site foi maior que a versão do repo local
if [ "$ltsversite" -gt "$ltsverrepo" ]; then
    echo "Envia lts"
    echo "AUR =$ltsversite"
    echo "Repo =$ltsverrepo"
    xanmod=linux-xanmod-lts
    webhooks
else
echo "Versão do xanmod lts é igual"
fi

## RT ##
#versão online no site da AUR
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-rt | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-rt | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-rt | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
rtversite=$major$pkgver$pkgrel

#versão do repositorio do biglinux
rtverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|edge|tt" | grep rt | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

#se versão do site foi maior que a versão do repo local
if [ "$rtversite" -gt "$rtverrepo" ]; then
    echo "Envia rt"
    echo "AUR =$rtversite"
    echo "Repo =$rtverrepo"
    xanmod=linux-xanmod-rt
    webhooks
else
echo "Versão do xanmod rt é igual"
fi

## RT ##
#versão online no site da AUR
major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-tt | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-tt | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2)
pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=linux-xanmod-tt | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
ttversite=$major$pkgver$pkgrel

#versão do repositorio do biglinux
ttverrepo=$(pacman -Ss xanmod | grep biglinux-stable | grep -v headers | egrep -v "lts|edge|rt" | grep tt | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//')

#se versão do site foi maior que a versão do repo local
if [ "$ttversite" -gt "$ttverrepo" ]; then
    echo "Envia tt"
    echo "AUR =$ttversite"
    echo "Repo =$ttverrepo"
    xanmod=linux-xanmod-tt
    webhooks
else
echo "Versão do xanmod tt é igual"
fi

