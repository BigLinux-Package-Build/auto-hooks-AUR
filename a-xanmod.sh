#!/bin/bash

repo=stable


xanwebhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'AUR/$xanmod'"'", "'"client_payload"'": { "'"branch"'": "'"'$repo'"'", "'"url"'": "'"https://aur.archlinux.org/'$xanmod'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}

exwebhooks() {
echo '
curl -X POST \
-H "Accept: application/json" \
-H "Authorization: token '$CHAVE'" \
--data '"'{"'"event_type"'": "'"'${xanmod}/${mod}'"'", "'"client_payload"'": { "'"xanmod"'": "'"'${xanmod}'"'", "'"kver"'": "'"'${major}${pkgver}'"'", "'"branch"'": "'"'$repo'"'", "'"url"'": "'"https://gitlab.manjaro.org/packages/extra/linux'${kver}-extramodules/${mod}'"'", "'"version"'": "'"1.2.3"'"}}'"' \
'https://api.github.com/repos/BigLinux-Package-Build/build-package/dispatches'' > run-webhooks-aur.sh

bash -x run-webhooks-aur.sh
rm run-webhooks-aur.sh
}

xanmod=(
linux-xanmod
linux-xanmod-lts
linux-xanmod-rt
)

extramodules=(
acpi_call
bbswitch
broadcom-wl
nvidia
nvidia-390xx
nvidia-470xx
r8168
rtl8723bu
tp_smapi
vhba-module
virtualbox-modules
zfs
)

funxanverrepo () {
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
    
    #se versão do AUR foi maior que a versão do repo local
    if [ "$xanveraur" -gt "$xanverrepo" ]; then
        echo "Envia $xanmod"
        echo "AUR =$xanveraur"
        echo "Repo=$xanverrepo"
        xanwebhooks
    elif [ -z "$xanverrepo" ]; then
        echo "Sem Pacote $xanmod no Repo, enviando....."
        xanwebhooks
    else
        echo "Versão do $xanmod é igual"
        echo "AUR =$xanveraur"
        echo "Repo=$xanverrepo"
    fi

    #verifica se a versão do kernel do kernel e do repo são iguais
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
        #se a versão do repo for igual, enviar webhooks dos extramodules
        if [ "$xanveraur" -eq "$xanverrepo" ]; then
            kver=$(echo $major | sed 's|\.||g')
            #pega a versão do extramodules do gitlad do manjaro
            curlmodvergit=$(curl -s https://gitlab.manjaro.org/packages/extra/linux${kver}-extramodules/${mod}/-/raw/master/PKGBUILD | grep pkgver= | grep -v _pkgver | cut -d "=" -f2 | sed 's/\.//g' | sed 's/\-//g')
            curlmodrelgit=$(curl -s https://gitlab.manjaro.org/packages/extra/linux${kver}-extramodules/${mod}/-/raw/master/PKGBUILD | grep pkgrel= | grep -v _pkgver | cut -d "=" -f2 | sed 's/\.//g' | sed 's/\-//g')
            modvergit=${curlmodvergit}${curlmodrelgit}
            
            #troca nome do virtualbox-modules na busca do repo
            if [ "${mod}" = "virtualbox-modules" ];then
                mod=virtualbox-host-modules
            fi            
            #versão do extramodules do repo do biglinux
            modverrepo=$(pacman -Ss ${xanmod}-${mod} | grep biglinux-${repo} | sed 's/\.//g' | sed 's/\-//g' | grep -w $(echo ${xanmod}-${mod} | sed 's/\.//g' | sed 's/\-//g') | cut -d " " -f2)
            #volta nome do virtualbox-modules
            if [ "${mod}" = "virtualbox-host-modules" ];then
                mod=virtualbox-modules
            fi 
            
            echo "${xanmod}-${mod}"
            echo "vergit =$modvergit"
            echo "verrepo=$modverrepo"
            if [ "$modvergit" != "$modverrepo" ];then
                echo "send webhooks ${xanmod}-${mod}"
                exwebhooks
            fi            
        fi
    done
done