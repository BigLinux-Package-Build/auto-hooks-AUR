#!/bin/bash

##### Não Editar Start #####
#AUR=
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'TKG/linux'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://github.com/Frogging-Family/linux-tkg"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh

}
##### NÃO Editar End #####


#nome do programa como está no pacman
pkgname=linux-tkg

#versão do AUR
git clone https://github.com/Frogging-Family/linux-tkg.git
cd linux-tkg
veraur=$(git tag | sort | tail -n1 | sed 's/\.//g' | sed 's/v//')
cd ..

#versão do repositorio do biglinux
verrepo=$(pacman -Ss linux tkg | grep biglinux-stable | cut -d " " -f2 | cut -d "-" -f1 | sed 's/\.//g' | tail -n1)

#se versão do aur foi maior que a versão do repo local
if [ "$veraur" != "$verrepo" ]; then
    echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
    echo "AUR ""$pkgname"="$veraur"
    echo "Repo ""$pkgname"="$verrepo"
    #AUR=$pkgname
    webhooks
else
    echo "Versão do $pkgname é igual !"
fi


