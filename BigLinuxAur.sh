#!/usr/bin/env bash

webhooks() {
curl -X POST -H "Accept: application/json" -H "Authorization: token $CHAVE" --data '{"event_type": "clone", "client_payload": { "branch": "'$repo'", "pkgver": "'$veraur'"}}' https://api.github.com/repos/BigLinuxAur/$package/dispatches
}

sendWebHooks() {
echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
echo " AUR ""$pkgname"="$verAurOrg"
echo "Repo ""$pkgname"="$verRepoOrg"
package=$pkgname
sleep 10
webhooks
}

newRepo(){
curl -sH "Authorization: token $CHAVE" -H "Accept: application/vnd.github.baptiste-preview+json" --data '{"owner":"BigLinuxAur","name":"'$pkgname'"}' https://api.github.com/repos/BigLinuxAur/aurTemplate/generate > /dev/null
}

# Define repo
repo=$1
if [ "$repo" = "development" ]; then
  branch=$REPO_DEV
else
  branch=$repo
fi

echo '...'
echo -e "\033[01;31mEXCUÇÃO no BRANCH $repo\033[0m"
echo '...'

sed -i 's/#.*$//' BigLinuxAur-${repo}
sed -i '/^$/d' BigLinuxAur-${repo}

for p in $(cat BigLinuxAur-${repo}); do
  pkgname=$p
  #versão do repositorio BigLinux
  verrepo=
  verrepo=$(pacman -Ss $pkgname | grep biglinux-$branch | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d "/" -f2 | grep -w $pkgname | cut -d " " -f2 | cut -d ":" -f2)
  verRepoOrg=$verrepo
  verrepo=${verrepo//[-.]}

  # Verificar se repo existe no BigLinuxAur
  if [ "$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/BigLinuxAur/$pkgname)" != "200" ];then
    echo -e "\033[01;31mCriando\033[0m repo \033[01;31m$pkgname\033[0m no GitHub"
    newRepo
    ## Esperar fazer o pull do AUR
    # while [ "$(curl -s -o /dev/null -w "%{http_code}" https://api.github.com/repos/BigLinuxAur/$pkgname/contents/$pkgname)" != "200" ]; do
    #   sleep 3
    # done
    # Passar para o proximo da lista
    continue
  fi

  #versão do AUR
  #limpa todos os $
  veraur=
  pkgver=
  pkgrel=
  git clone https://aur.archlinux.org/${pkgname}.git > /dev/null 2>&1
  cd $pkgname
  if [ -z "$(grep -q 'pkgver()' PKGBUILD)" ];then
    source PKGBUILD
    veraur=$pkgver-$pkgrel
    verAurOrg=$veraur
    veraur=${veraur//[.-]}
  else
    chmod 777 -R $pkgname
    sudo -u builduser bash -c 'makepkg -so --noconfirm --skippgpcheck --needed'
    sleep 5
    source PKGBUILD
    veraur=$pkgver-$pkgrel
  fi

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
  # Enviar caso não encontre no repo
  elif [ -z "$verrepo" ];then
    sendWebHooks
  # se contiver apenas numeros ou se for com hash
  elif [[ $veraur =~ ^[0-9]+$ ]]; then
#     if [ "$veraur" -gt "$verrepo" ]; then
      sendWebHooks
#     else
#       echo -e "Versão do \033[01;31m$pkgname\033[0m é igual !"
#       sleep 1
#     fi
  else
    # Enviar hooks
    if [ "$veraur" != "$verrepo" ]; then
      sendWebHooks
    else
      echo "Versão do $pkgname é igual !"
      sleep 1
    fi
  fi
done




