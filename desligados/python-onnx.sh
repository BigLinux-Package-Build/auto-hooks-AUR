#!/bin/bash

##### Não Editar Start #####
AUR=
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/$AUR'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://aur.archlinux.org/'$AUR'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}
##### NÃO Editar End #####


#nome do programa como está no pacman
#pkgname=


pkgname=python-onnx

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

#versão do repositorio do biglinux
if [ "$REPO" = "testing" ]; then
    repo=biglinux-testing
elif [ "$REPO" = "stable" ]; then
    repo=biglinux-stable
fi
verrepo=
verrepo=$(pacman -Ss $pkgname | grep $repo | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | grep -v python-onnxruntime | cut -d " " -f2 | cut -d ":" -f2)
if [ "$veraur" != "$verrepo" ]; then
    verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | grep -v python-onnxruntime | cut -d " " -f2 | cut -d ":" -f2)
fi

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


