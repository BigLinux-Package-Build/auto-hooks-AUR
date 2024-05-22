#!/usr/bin/env bash

webhooks() {
curl -X POST -H "Accept: application/json" -H "Authorization: token $CHAVE" --data '{"event_type": "clone", "client_payload": { "branch": "'$repo'", "pkgver": "'$verAurOrg'"}}' https://api.github.com/repos/BigLinuxAur/$package/dispatches
}

sendWebHooks() {
echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
echo " AUR ""$pkgname"="$verAurOrg"
echo "Repo ""$pkgname"="$verRepoOrg"
echo "Branch $branch"
package=$pkgname
sleep 1
webhooks
}

# newRepo(){
# Create
# curl -sH "Authorization: token $CHAVE" -H "Accept: application/vnd.github.baptiste-preview+json" --data '{"owner":"BigLinuxAur","name":"'$pkgname'"}' https://api.github.com/repos/BigLinuxAur/aurTemplate/generate > /dev/null

# Rename branch main to stable
# for i in ${lista[@]}; do curl -X POST -H "Authorization: token $BigLinuxAur_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/BigLinuxAur/$i/branches/main/rename -d '{"new_name":"stable"}' > /dev/null 2>&1 ; done
# }

# echo '...'
# echo -e "\033[01;31mEXCUÇÃO no BRANCH $repo\033[0m"
# echo '...'

# sed -i 's/#.*$//' BigLinuxAur-${repo}
# sed -i '/^$/d' BigLinuxAur-${repo}

# Numero de pacotes verificado
pkgNum=0

gh auth login --with-token <<< $BigLinuxAur_TOKEN
for p in $(gh repo list BigLinuxAur --limit 1000 | awk '{print $1}' | cut -d "/" -f2 | sed '/aurTemplate/d'); do
# for p in $(cat BigLinuxAur-${repo}); do

  pkgname=
  # declara nome do pacote
  pkgname=$p

  # Disabled List
  if [ -n "$(grep $pkgname disable-list)" ];then
    continue
  fi

  # Define o branch
  branch=$(gh repo view BigLinuxAur/$pkgname --json defaultBranchRef -q .defaultBranchRef.name)
  if [ "$branch" = "main" ]; then
    branch=$REPO_DEV
  fi

  # Versão do repositorio BigLinux
  verrepo=
  verRepoOrg=
  verrepo=$(pacman -Ss $pkgname | grep biglinux-$branch | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d "/" -f2 | grep -w $pkgname | cut -d " " -f2 | cut -d ":" -f2)
  verRepoOrg=$verrepo
  verrepo=${verrepo//[-.]}

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
  veraur=${veraur//[.-]}


  # Remove +...
  veraur=${veraur%%+*}
  verAurOrg=${verAurOrg%%+*}

  # Vririficar se source PKGBUILD alterou o $pkgname
  if [ "$pkgname" != "$p" ]; then
    pkgname=$p
  fi

  #apagar diretorio do git
  cd ..
  rm -r $pkgname

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
      echo "Branch $branch"
      sleep 1
    fi
  else
    # Enviar hooks
    if [ "$veraur" != "$verrepo" ]; then
      sendWebHooks
    else
      echo -e "Versão do \033[01;31m$pkgname\033[0m é igual !"
      echo "Branch $branch"
      sleep 1
    fi
  fi
done

# Print numero final de pacotes
echo "pkgNum=$pkgNum"


