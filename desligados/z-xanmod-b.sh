#!/bin/bash

export LC_ALL=C

# #hooks to Kernel
# xanwebhooks() {
# echo '
# curl -X POST \
# -H "Accept: application/json" \
# -H "Authorization: token '$CHAVE'" \
# --data '"'{"'"event_type"'": "'"'AUR/$xanmod'"'", "'"client_payload"'": { "'"branch"'": "'"'$repo'"'", "'"url"'": "'"https://aur.archlinux.org/'$xanmod'"'", "'"version"'": "'"1.2.3"'"}}'"' \
# 'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh
# bash -x run-webhooks-aur.sh
# rm run-webhooks-aur.sh
# }

#hooks to ExtraModules
exwebhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'${xanmod}/${mod}'"'", "'"client_payload"'": { "'"xanmod"'": "'"'${xanmod}'"'", "'"kver"'": "'"'${major}${pkgver}'"'", "'"xanver"'": "'"'${xanver}'"'", "'"branch"'": "'"'$repo'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/biglinux/${mod}/dispatches'' > run-webhooks-aur.sh
bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}

https://github.com/biglinux/linux-xanmod-nvidia

xanmod=(
linux-xanmod
linux-xanmod-lts
)

extramodules=(
broadcom-wl
nvidia
nvidia-390xx
nvidia-470xx
virtualbox-modules
zfs
)

repo=stable

funxanverrepo () {
sudo pacman -Sy
xanverrepo=$(pacman -Ss $xanmod | grep biglinux-${repo} | grep -v headers | sed 's/\.//g' | sed 's/\-//g' | grep -w $(echo $xanmod | sed 's/\.//g' | sed 's/\-//g') | cut -d " " -f2)
xanheadersverrepo=$(pacman -Ss ${xanmod}-headers | grep biglinux-${repo} | grep -w headers | sed 's/\.//g' | sed 's/\-//g' | grep -w $(echo ${xanmod}-headers | sed 's/\.//g' | sed 's/\-//g') | cut -d " " -f2)
}

#xanmod version
for xanmod in ${xanmod[@]}; do
    
    #versão online no site da AUR
    major=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$xanmod | sed 's/<[^>]*>//g' | grep _major= | cut -d "=" -f2)
    pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$xanmod | sed 's/<[^>]*>//g' | grep pkgver= | cut -d "=" -f2 | cut -d "}" -f2)
    pkgrel=$(curl -s https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=$xanmod | sed 's/<[^>]*>//g' | grep xanmod= | cut -d "=" -f2)
    xanveraur=$(echo ${major}${pkgver}${pkgrel} | sed 's|\.||g' | sed 's|-||g')

    #versão do repositorio do biglinux
    funxanverrepo
    
#     #se versão do AUR foi maior que a versão do repo local
#     if [ -z "$xanverrepo" ]; then
#         echo "Sem Pacote $xanmod no Repo, enviando....."
#         xanwebhooks
#     elif [ "$xanveraur" -gt "$xanverrepo" ]; then
#         echo "Envia $xanmod"
#         echo "AUR =$xanveraur"
#         echo "Repo=$xanverrepo"
#         xanwebhooks
#     else
#         echo "Versão do $xanmod é igual"
#         echo "AUR =$xanveraur"
#         echo "Repo=$xanverrepo"
#     fi

    #verifica se a versão header do kernel e do repo são iguais
    while [ "$xanveraur" != "$xanverrepo" -o "$xanheadersverrepo" != "$xanverrepo"  ]; do
        #se for diferente espera chegar a versão nova para enviar o extramodules
        echo "versão diferente ainda, esperando"
        echo "AUR =$xanveraur"
        echo "Repo=$xanverrepo"
        echo "Head=$xanheadersverrepo"
        sleep 60
        sudo pacman -Sy
        funxanverrepo
    done
    
    #extramodules
    for mod in ${extramodules[@]}; do
        #se a versão do xanmod for igual no git e no repo AND não for RT, enviar webhooks dos extramodules
        if [ "$xanveraur" -eq "$xanverrepo" ]; then
            #versão curta do xanmod
            kmajor=$(echo $major | sed 's|\.||g')
            
            
            ##pegar versão do moduloextra do git
            #modvergit=$(curl -s https://gitlab.manjaro.org/packages/extra/linux${kmajor}-extramodules/${mod}/-/raw/master/PKGBUILD | grep pkgver= | grep -v _pkgver | cut -d "=" -f2 | sed 's/\.//g' | sed 's/\-//g')
                ##troca nome do virtualbox-modules na busca do repo
                #if [ "${mod}" = "virtualbox-modules" ];then mod=virtualbox-host-modules; fi
            
            if [ "$mod" = "broadcom-wl" ];then
                mkdepends=broadcom-wl-dkms
            elif [ "$mod" = "nvidia" ];then
                mkdepends=nvidia-utils
            elif [ "$mod" = "nvidia-390xx" ];then
                mkdepends=nvidia-390xx-utils
            elif [ "$mod" = "nvidia-470xx" ];then
                mkdepends=nvidia-470xx-utils
            elif [ "$mod" = "virtualbox-modules" ];then
                mkdepends=virtualbox-host-dkms
            elif [ "$mod" = "zfs" ];then
                mkdepends=zfs-utils
            fi
            modvergit=$(pacman -Ss ${mkdepends} | sed 's/\.//g' | grep ${mkdepends} | grep -v "\-${mkdepends}" | cut -d " " -f2 | cut -d "-" -f1 | sed 's/.*://')
            
            
            #pegar versão do moduloextra do repo (sem pkgrel)
            modverrepo=$(pacman -Ss ${xanmod}-${mod} | grep biglinux-${repo} | sed 's/\.//g' | grep -v ${xanmod}-${mod}- | cut -d " " -f2 | cut -d "-" -f1 | sed 's/.*://')
            #pegar rel do moduloextra do repo
            modrelrepo=$(pacman -Ss ${xanmod}-${mod} | grep biglinux-${repo} | sed 's/\.//g' | grep -v ${xanmod}-${mod}- | awk '{print $2}' | awk -F- '{print $2}')
                #volta nome do virtualbox-modules
                if [ "${mod}" = "virtualbox-host-modules" ];then mod=virtualbox-modules; fi
            #pegar versão do xanmod
            xanver=$xanveraur
            
            #se a pkgver do git =! pkgver repo OU do pkgrel do modulo =! pkgver do xanmod , re-buildar
            if [ "$modvergit" != "$modverrepo" -o "$modrelrepo" != "$xanver" ];then
                echo "${xanmod}-${mod}"
                echo "Mod Vergit =$modvergit"
                echo "Mod Verrepo=$modverrepo"
                echo "Xan Ver=$xanver"
                echo "Mod Rel=$modrelrepo"
                echo "send webhooks ${xanmod}-${mod}"
                exwebhooks
            else
                echo "Versão do ${xanmod}-${mod} é igual"
            fi
        fi
    done
done
