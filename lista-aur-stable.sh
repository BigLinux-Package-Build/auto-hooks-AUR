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


for i in $(cat lista-auto-hooks-stable); do pkgname=$i
    if [ "$i" = "" ];then
        exit
    fi
    #versão online no site da AUR
    pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$pkgname | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|\_||g'| sed 's|-||g' | cut -d "}" -f2  | sed 's/&quot;//g' | sed 's|_||g')
    pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$pkgname | sed 's/<[^>]*>//g' | grep pkgrel= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
    versite=$pkgver$pkgrel
     
    #versão do repositorio do biglinux
    if [ "$REPO" = "testing" ]; then
        repo=biglinux-testing
    elif [ "$REPO" = "stable" ]; then
        repo=biglinux-stable
    fi
    verrepo=$(pacman -Ss $pkgname | grep $repo | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//' | sed 's|_||g')
    if [ "$versite" != "$verrepo" ]; then
        verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2  | sed 's/\.//g' | sed 's/\-//' | sed 's|_||g')
    fi
    
    #se versão do site foi maior que a versão do repo local
    if [ "$versite" != "$verrepo" ]; then
        echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
        echo " AUR ""$pkgname"="$versite"
        echo "Repo ""$pkgname"="$verrepo"
        AUR=$pkgname
        webhooks
    else
        echo "Versão do $pkgname é igual !"
    fi
done

