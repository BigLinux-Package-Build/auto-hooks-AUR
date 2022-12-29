#!/bin/bash

##### Não Editar Start #####
webhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/$AUR'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'$repo'"'", "'"url"'": "'"https://aur.archlinux.org/'$AUR'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}
##### NÃO Editar End #####


#nome do programa como está no pacman
#pkgname=
AUR=
repo=testing

for i in $(cat dde.list); do pkgname=$i
    if [ -z "$(echo $i)" -o -z "$(echo $i | grep \#)" ];then
        
        #versão do repositorio BigLinux
        verrepo=
        verrepo=$(pacman -Ss $pkgname | grep biglinux-${repo} | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | cut -d ":" -f2)
        
        sleep 1
        
        #versão do AUR
        #limpa todos os $
        veraur=
        pkgver=
        pkgrel=
        #versão do AUR
        git clone https://aur.archlinux.org/${i}.git
        chmod 777 -R $i
        cd $i 
        source PKGBUILD
        veraur=$pkgver-$pkgrel
        
        sleep 1
        
        if [ "$veraur" != "$verrepo" -a -n "$verrepo" ]; then
            veraur=
            pkgver=
            pkgrel=
            sudo -u builduser bash -c 'makepkg -so --noconfirm --skippgpcheck --needed'
            sleep 5
            source PKGBUILD
            veraur=$pkgver-$pkgrel
        fi
        cd ..
        if [ "$pkgname" != "$i" ]; then
            pkgname=$i
        fi
        
        sleep 1
        
        #verficação de redundancia no repo stable
        if [ "$veraur" != "$verrepo" ]; then
            verrepostable=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | cut -d ":" -f2)
            if [ -n "$verrepostable" ];then
                verrepo=$verrepostable
            fi
        fi
        
        sleep 1
        
        #se versão do AUR foidiferente a versão do repo local
        if [ "$veraur" != "$verrepo" ]; then
            echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
            echo " AUR ""$pkgname"="$veraur"
            echo "Repo ""$pkgname"="$verrepo"
            AUR=$pkgname
            sleep 10
            webhooks
        else
            echo "Versão do $pkgname é igual !"
            sleep 1
        fi
    fi
done 
