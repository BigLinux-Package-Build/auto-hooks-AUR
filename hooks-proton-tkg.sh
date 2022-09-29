#!/bin/bash

##### Não Editar Start #####
webhooks() {
AUR=proton-tkg
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'TKG/proton'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://github.com/Frogging-Family/'$AUR'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh

}
##### NÃO Editar End #####

pkgname=proton-tkg

#nome do programa como está no pacman
pkgnameaur=wine-staging
pkgver=$(pacman -Ss $pkgnameaur | grep -v "$pkgnameaur-" | grep -v "\-$pkgnameaur" | grep "$pkgnameaur" | cut -d " " -f2 | awk -F"_devel" '{print $1}' | sed 's/\.//g' | sed 's/\-//')
versite=$pkgver

pkgnamerepo=proton-tkg
#versão do repositorio do biglinux
verrepo=$(pacman -Ss $pkgnamerepo | grep biglinux-stable | grep -v "$pkgnamerepo-" | grep -v "\-$pkgnamerepo" | grep "$pkgnamerepo" | cut -d " " -f2 | awk -F"_devel" '{print $1}' | sed 's/\.//g' | sed 's/\-//')

#se versão do site foi maior que a versão do repo local
if [ "$versite" != "$verrepo" ]; then
    echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
    echo "AUR ""$pkgname"="$versite"
    echo "Repo ""$pkgname"="$verrepo"
    webhooks
else
    echo "Versão do $pkgname é igual !"
fi


