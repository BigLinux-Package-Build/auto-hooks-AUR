#!/bin/bash

##### Não Editar Start #####
AUR=
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/balena-etcher'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'testing'"'", "'"url"'": "'"https://aur.archlinux.org/'$AUR'"'", "'"command"'": "'"'$command'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}
##### NÃO Editar End #####

#comando expecial para esse pacote
command="wget https://github.com/BigLinux-Package-Build/auto-hooks-AUR/blob/main/balena-etcher.pkgbuild && bash balena-etcher.pkgbuild"


#nome do programa como está no pacman
#pkgname=


pkgname=etcher-bin
newpkgname=balena-etcher

#limpa todos os $
veraur=
pkgver=
pkgrel=
#versão do AUR
git clone https://aur.archlinux.org/${pkgname}.git
cd $pkgname
source PKGBUILD
veraur=$pkgver-$pkgrel
cd ..
if [ "$pkgname" != "etcher-bin" ]; then
    pkgname=etcher-bin
fi

#versão do repositorio do biglinux
repo=biglinux-stable

verrepo=
verrepo=$(pacman -Ss $newpkgname | grep $repo | grep -v "$newpkgname-" | grep -v "\-$newpkgname" | grep "$newpkgname" | cut -d " " -f2 | cut -d ":" -f2)

#se versão do AUR foi maior que a versão do repo local
if [ "$veraur" != "$verrepo" ]; then
    echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
    echo " AUR ""$pkgname"="$veraur"
    echo "Repo ""$pkgname"="$verrepo"
    AUR=$pkgname
    webhooks
else
    echo "Versão do $pkgname é igual !"
fi

