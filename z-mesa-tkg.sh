#!/bin/bash

##### Não Editar Start #####
#mesa-git
AUR=
# webhooks() {
# #mesa-tkg-git
# echo '
# curl -X POST \
# -H "Accept: application/json" \
# -H "Authorization: token '$CHAVE'" \
# --data '"'{"'"event_type"'": "'"'TKG/$AUR'"'", "'"client_payload"'": { "'"pkgbuild"'": "'""'", "'"branch"'": "'"'stable'"'", "'"url"'": "'"https://github.com/Frogging-Family/mesa-git"'", "'"version"'": "'"1.2.3"'"}}'"' \
# 'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh
#
# bash -x run-webhooks-aur.sh
# rm run-webhooks-aur.sh
# }
# ##### NÃO Editar End #####

#send hooks to BigLinuxAur
webhooks() {
curl -X POST -H "Accept: application/json" -H "Authorization: token $CHAVE" --data '{"event_type": "clone", "client_payload": { "branch": "'$branch'", "pkgver": "'$verAurOrg'"}}' https://api.github.com/repos/BigLinuxAur/$package/dispatches
}

#nome do programa como está no pacman
pkgname=mesa-tkg-git

#só rodar terça e sexta feira
if [ "$(date +%u)" = "1" -o "$(date +%u)" = "4" ];then
    #clona, verifica a versão do patch e declara o vergit
    git clone https://gitlab.freedesktop.org/mesa/mesa.git
    pkgver() {
        cd mesa
        local _ver
        read -r _ver <VERSION

        local _patchver
        local _patchfile
        for _patchfile in "${source[@]}"; do
            _patchfile="${_patchfile%%::*}"
            _patchfile="${_patchfile##*/}"
            [[ $_patchfile = *.patch ]] || continue
            _patchver="${_patchver}$(md5sum ${srcdir}/${_patchfile} | cut -c1-32)"
        done
        _patchver="$(echo -n $_patchver | md5sum | cut -c1-32)"

    #     echo ${_ver/-/_}.$(git rev-list --count HEAD).$(git rev-parse --short HEAD)
        vergit=$(echo ${_ver/-/_}.$(git rev-list --count HEAD).$(git rev-parse --short HEAD))
    #     vergit=$(echo ${_ver} | sed 's|\.||g' | sed 's|-||g' | sed 's/devel//' )${_patchver}
        echo $vergit
    }
    pkgver

    #versão do repositorio do biglinux
    verrepo=$(pacman -Ss $pkgname | grep biglinux-stable | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d " " -f2 | cut -d "-" -f1 )


    #se versão do site foi maior que a versão do repo local
    if [ "$vergit" != "$verrepo" ]; then
        echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
        echo "AUR ""$pkgname"="$vergit"
        echo "Repo ""$pkgname"="$verrepo"
        package=$pkgname
        webhooks
    else
        echo "Versão do $pkgname é igual !"
    fi
fi

