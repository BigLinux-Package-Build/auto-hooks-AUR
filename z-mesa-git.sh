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

sleep 2

# #mesa-tkg-git
# echo '
# curl -X POST \
# -H "Accept: application/json" \
# -H "Authorization: token '$CHAVE'" \
# --data '"'{"'"event_type"'": "'"'TKG/$AUR'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://github.com/Frogging-Family/'$AUR'"'", "'"version"'": "'"1.2.3"'"}}'"' \
# 'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh
# 
# bash -x run-webhooks-aur.sh
# rm run-webhooks-aur.sh


#lib32-mesa-git, esperar o mesa-git buildar e upar pro repo
while true :; do
    sudo pacman -Sy
    verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | cut -d "-" -f1 | sed 's|\.||1' | sed 's|\.||1' | sed 's/_/./' | cut -d "." -f1,5 | sed 's|\.||g')
    if [ "$vergit" = "$verrepo" ]; then
        break
    else
        echo "Esperando mesa-git compilar"
        sleep 60
    fi
done

echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/lib32-mesa-git'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://aur.archlinux.org/'lib32-mesa-git'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh

}
##### NÃO Editar End #####

#nome do programa como está no pacman
pkgname=mesa-git
#versão online no site da AUR
# pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$pkgname | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | sed 's|_||g')
# pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$pkgname | sed 's/<[^>]*>//g' | grep pkgrel= | cut -d "=" -f2 | sed 's|\.||g' | sed 's|-||g' | sed 's|_||g')
# versite=$pkgver$pkgrel

#clona, verifica a versão do patch e declara o vergit
# git clone https://gitlab.freedesktop.org/mesa/mesa.git
# pkgver() {
#     cd mesa
#     local _ver
#     read -r _ver <VERSION
# 
#     local _patchver
#     local _patchfile
#     for _patchfile in "${source[@]}"; do
#         _patchfile="${_patchfile%%::*}"
#         _patchfile="${_patchfile##*/}"
#         [[ $_patchfile = *.patch ]] || continue
#         _patchver="${_patchver}$(md5sum ${srcdir}/${_patchfile} | cut -c1-32)"
#     done
#     _patchver="$(echo -n $_patchver | md5sum | cut -c1-32)"
# 
# #     echo ${_ver/-/_}.$(git rev-list --count HEAD).$(git rev-parse --short HEAD).${_patchver}
#     vergit=$(echo ${_ver} | sed 's|\.||g' | sed 's|-||g' | sed 's/devel//' )${_patchver}
#     echo $vergit
# }
# pkgver

git clone https://aur.archlinux.org/mesa-git.git
cd mesa-git
sudo -u builduser bash -c 'makepkg -so --noconfirm --skippgpcheck --needed'
sleep 5
source PKGBUILD
vergit=$(echo $pkgver | sed 's|\.||1' | sed 's|\.||1' | sed 's/_/./' | cut -d "." -f1,5 | sed 's|\.||g')

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


