#!/usr/bin/env bash

webhooks() {
curl -X POST -H "Accept: application/json" -H "Authorization: token $CHAVE" --data '{"event_type": "clone", "client_payload": { "branch": "'$branch'", "base": "'$base'", "pkgver": "'$verAurOrg'", "arch": "'$arch'"}}' https://api.github.com/repos/BigLinuxAur/$package/dispatches
}

sendWebHooks() {
echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
echo -e "Base ${cor}${base}${std}"
echo " AUR ""$pkgname"="$verAurOrg"
echo "Repo ""$pkgname"="$verRepoOrg"
echo "Branch $branch"
package=$pkgname
sleep 1
webhooks
}

std='\e[m'

# newRepo(){
# Create
# curl -sH "Authorization: token $CHAVE" -H "Accept: application/vnd.github.baptiste-preview+json" --data '{"owner":"BigLinuxAur","name":"'$pkgname'"}' https://api.github.com/repos/BigLinuxAur/aurTemplate/generate > /dev/null

# Rename branch main to stable
# for i in ${lista[@]}; do curl -X POST -H "Authorization: token $BigLinuxAur_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/BigLinuxAur/$i/branches/main/rename -d '{"new_name":"stable"}' > /dev/null 2>&1 ; done
# }

# Limpa disable-list
sed -i 's/#.*$//' disable-list
sed -i '/^$/d' disable-list

# Numero de pacotes verificado
pkgNum=0

bases=(
manjaro
)
# archlinux

arch=x86_64

gh auth login --with-token <<< $BigLinuxAur_TOKEN
for p in $(gh repo list BigLinuxAur --limit 1000 | awk '{print $1}' | cut -d "/" -f2 | sed '/aurTemplate/d' | sort); do
  for base in ${bases[@]}; do

    pkgname=
    # declara nome do pacote
    pkgname=$p

    # Disabled List
    if [ -n "$(grep $pkgname disable-list)" ];then
      continue
    fi

    # Define o branch
    branch=$(gh repo view BigLinuxAur/$pkgname --json defaultBranchRef -q .defaultBranchRef.name)
    if [ "$branch" = "main" -a "$base" = "manjaro" ]; then
      branch=$REPO_DEV
      repo='bigiborg'
    else
      repo='biglinux'
    fi

    # Versão do repositorio BigLinux
    verrepo=
    verRepoOrg=
    veraur=
    verAurOrg=
    pkgver=
    pkgrel=
    if [ "$base" = "manjaro" ];then
      # verrepo=$(pacman -Ss $pkgname | grep $repo-$branch | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d "/" -f2 | grep -w $pkgname | cut -d " " -f2 | cut -d ":" -f2)
      verrepo=$(pacman -Sl $repo-$branch | grep " $pkgname " | awk '{print $3}' | cut -d ":" -f2)
      cor='\e[32;1m'
    elif [ "$base" = "archlinux" ]; then
      verrepo=$(pacman -Sl $repo-$base | grep " $pkgname " | awk '{print $3}' | cut -d ":" -f2)
      cor='\e[34;1m'
    fi

    if [ -n "$(grep xanmod <<< $pkgname)" ];then
      verRepoOrg=$verrepo
      #add 0 no 2º numero da versão
      verrepo=$(echo "$verrepo" | awk -F'.' '{ split($3, a, "-"); if (length($2) == 1) $2 = "0"$2; print $1"."$2"."a[1]"-"a[2]}')
      #add 0 no 3º numero da versão
      verrepo=$(echo "$verrepo" | awk -F'.' '{ split($3, a, "-"); if (length(a[1]) == 1) a[1] = "0"a[1]; print $1"."$2"."a[1]"-"a[2] }')
      #remove . e -
      verrepo=${verrepo//[-.]}
    else
      verRepoOrg=$verrepo
      verrepo=${verrepo//[-.]}
    fi

    # Enviar caso não encontre no repo
    if [ -z "$verrepo" ];then
      sendWebHooks
      continue
    fi

    # Verificar se repo existe no BigLinuxAur
    # if [ "$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/BigLinuxAur/$pkgname)" != "200" ];then
    #   echo -e "\033[01;31mCriando\033[0m repo \033[01;31m$pkgname\033[0m no GitHub"
    #   newRepo
    #   ## Esperar fazer o pull do AUR
    #   # while [ "$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/BigLinuxAur/$pkgname/contents/$pkgname)" != "200" ]; do
    #   #   sleep 3
    #   # done
    #   # Passar para o proximo da lista
    #   continue
    # fi

    # soma +1 ao pkgNum
    pkgNum=$((pkgNum+1))

    #versão do AUR
    #limpa todos os $
    veraur=
    verAurOrg=
    pkgver=
    pkgrel=

    # if Linux Xanmod rename
    if [ -n "$(grep "linux-xanmod" <<< $pkgname | grep -v "lts")" ];then
      pkgname=$(sed 's/linux-xanmod/linux-xanmod-linux-bin/' <<< $pkgname)
    elif [ -n "$(grep "linux-xanmod-lts" <<< $pkgname)" ];then
      pkgname=$(sed 's/linux-xanmod-lts/linux-xanmod-lts-linux-bin/' <<< $pkgname)
    fi

    git clone https://aur.archlinux.org/${pkgname}.git > /dev/null 2>&1
    cd $pkgname
    if [ -z "$(grep 'pkgver()' PKGBUILD)" ];then
      source PKGBUILD
      veraur=$pkgver-$pkgrel
      verAurOrg=$veraur
    else
      chmod 777 -R ../$pkgname
      sudo -u builduser bash -c 'makepkg -so --noconfirm --skippgpcheck --needed > /dev/null 2>&1'
      sleep 1
      source PKGBUILD
      veraur=$pkgver-$pkgrel
      verAurOrg=$veraur
    fi

    if [ -n "$(grep xanmod <<< $pkgname)" ];then
      #add 0 no 2º numero da versão
      veraur=$(echo "$veraur" | awk -F'.' '{ split($3, a, "-"); if (length($2) == 1) $2 = "0"$2; print $1"."$2"."a[1]"-"a[2]}')
      #add 0 no 3º numero da versão
      veraur=$(echo "$veraur" | awk -F'.' '{ split($3, a, "-"); if (length(a[1]) == 1) a[1] = "0"a[1]; print $1"."$2"."a[1]"-"a[2] }')
      #remove . e -
      veraur=${veraur//[.-]}
    else
      veraur=${veraur//[.-]}
    fi


    # Remove +...
    veraur=${veraur%%+*}
    verAurOrg=${verAurOrg%%+*}

    # Vririficar se source PKGBUILD alterou o $pkgname
    if [ "$pkgname" != "$p" ]; then
      pkgname=$p
    fi

    #apagar diretorio do git
    cd ..
    if [ "$(grep "linux-xanmod" <<< $pkgname)" ];then
      rm -r linux-xanmod*
    else
      rm -r $pkgname
    fi

    # echo "..."
    # echo "pkgname=$pkgname"
    # echo "veraur=$veraur"
    # echo "verAurOrg=$verAurOrg"
    # echo "verrepo=$verrepo"
    # echo "verRepoOrg=$verRepoOrg"

    # MSG de ERRO
    if [ -z "$veraur" ];then
      echo -e '\033[01;31m!!!ERRRRRO!!!\033[0m' $pkgname não encontrado '\033[01;31m!!!ERRRRRO!!!\033[0m'
      continue
    # se contiver apenas numeros ou se for com hash
    elif [[ $veraur =~ ^[0-9]+$ ]] || [[ $verrepo =~ ^[0-9]+$ ]]; then
      if [ "$veraur" -gt "$verrepo" ]; then
        sendWebHooks
      else
        echo -e "Versão do \033[01;31m$pkgname\033[0m é igual !"
        echo -e "Base ${cor}${base}${std}"
        echo "Branch $branch"
        sleep 1
      fi
    else
      # Enviar hooks
      if [ "$veraur" != "$verrepo" ]; then
        sendWebHooks
      else
        echo -e "Versão do \033[01;31m$pkgname\033[0m é igual !"
        echo -e "Base ${cor}${base}${std}"
        echo "Branch $branch"
        sleep 1
      fi
    fi
  done
  echo '---'
done

# Print numero final de pacotes
echo "pkgNum=$pkgNum"


