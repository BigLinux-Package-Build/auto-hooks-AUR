#!/bin/bash

##### Não Editar Start #####
AUR=
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/$AUR'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'$REPO'"'", "'"url"'": "'"https://aur.archlinux.org/'$AUR'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh

}
##### NÃO Editar End #####

for i in libglibutil libgbinder python-gbinder waydroid; do
    #verifica versão do pacote
    verificaver() {
    #atualizar lista pacman
    sudo pacman -Sy
    #nome do programa como está no pacman
    pkgname=$i
    #versão online no site da AUR
    pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$pkgname | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | cut -d "}" -f2  | sed 's/&quot;//g')
    pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$pkgname | sed 's/<[^>]*>//g' | grep pkgrel= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g')
    versite=$pkgver$pkgrel

    #versão do repositorio do biglinux
    verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | sed 's/\.//g' | sed 's/\-//')
    }
    
    verificaver

    #se versão do site foi maior que a versão do repo local
    while [ "$versite" != "$verrepo" ]; do
        echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
        echo "AUR ""$pkgname"="$versite"
        echo "Repo ""$pkgname"="$verrepo"
        AUR=$pkgname
        cont=$[$cont + 1]
        if [ "$cont" = "1" ]; then
            webhooks
            sleep 600
            verificaver
        elif [ "$cont" -gt "1" -a "$cont" -lt "10" ];then 
            sleep 60
            verificaver
        elif [ "$cont" -gt "10" ];then
            exit 1
        fi
    done

done

