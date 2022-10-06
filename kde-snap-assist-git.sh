#!/bin/bash

##### Não Editar Start #####
#mesa-git
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
pkgname=kde-snap-assist
#versão online git
git clone https://github.com/emvaized/kde-snap-assist.git
cd kde-snap-assist
vergit=$(git tag | sort | tail -n1 | sed 's|\.||g' | sed 's|v||')

#versão do repositorio do biglinux
verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | cut -d "-" -f1 | sed 's|\.||1' | sed 's|\.||1' | sed 's/_/./' | cut -d "." -f1,5 | sed 's|\.||g')


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


