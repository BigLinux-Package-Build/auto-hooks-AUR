#!/usr/bin/env bash

AUR=
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'URL/$AUR'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://github.com/sched-ext/scx-packaging-arch"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh

pkgname=linux-sched-ext

git clone https://github.com/sched-ext/scx-packaging-arch.git
cd scx-packaging-arch
source PKGBUILD
vergit=$pkgver
verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | cut -d "-" -f1 )

#se versão do site foi maior que a versão do repo local
if [ "$vergit" != "$verrepo" ]; then
    echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
    echo "AUR ""$pkgname"="$vergit"
    echo "Repo ""$pkgname"="$verrepo"
    AUR=$pkgname
    webhooks
else
    echo "Versão do $pkgname é igual !"
fi




