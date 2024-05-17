#!/usr/bin/env bash

webhooks() {
curl -X POST -H "Accept: application/json" -H "Authorization: token $CHAVE" --data '{"event_type": "clone", "client_payload": { "branch": "'$repo'"}}' https://api.github.com/repos/BigLinuxAur/$package/dispatches
}

sendWebHooks() {
echo -e "Enviando \033[01;31m$pkgname\033[0m para Package Build"
echo " AUR ""$pkgname"="$veraur"
echo "Repo ""$pkgname"="$verrepo"
package=$pkgname
sleep 10
webhooks
}

repo=testing
sed -i 's/#.*$//' BigLinuxAur-${repo}
sed -i '/^$/d' BigLinuxAur-${repo}

for pkgname in $(cat BigLinuxAur-${repo}); do
  #versão do repositorio BigLinux
  verrepo=
  verrepo=$(pacman -Ss $pkgname | grep biglinux-${repo} | grep -v "$pkgname-" | grep -v "\-$pkgname" | grep "$pkgname" | cut -d "/" -f2 | grep -w $pkgname | cut -d " " -f2 | cut -d ":" -f2 | sed 's/\.//g;s/-//g')

  sleep 1

  #versão do AUR
  #limpa todos os $
  veraur=
  pkgver=
  pkgrel=

  git clone https://aur.archlinux.org/${pkgname}.git > /dev/null 2>&1
#   chmod 777 -R $pkgname
  cd $pkgname

  if [ -z "$(grep -q 'pkgver()' PKGBUILD)" ];then
    source PKGBUILD
    veraur=$pkgver-$pkgrel
    veraur=${veraur//[.-]}
  else
    sudo -u builduser bash -c 'makepkg -so --noconfirm --skippgpcheck --needed'
    sleep 5
    source PKGBUILD
    veraur=$pkgver-$pkgrel
  fi

  #apagar diretorio do git
  cd ..
  rm -r $pkgname

  # MSG de ERRO
  if [ -z "$veraur" ];then
    echo -e '\033[01;31m!!!ERRRRRO!!!\033[0m' $pkgname '\033[01;31m!!!ERRRRRO!!!\033[0m'
  fi
  
  if [ -z "$verrepo" ];then
    sendWebHooks
  fi
  
  # se contiver apenas numeros ou se for com hash
  if [[ $veraur =~ ^[0-9]+$ ]]; then
    if [ "$veraur" -gt "$verrepo" ]; then
      sendWebHooks
    else
      echo "Versão do $pkgname é igual !"
      sleep 1
    fi
  else
    if [ "$veraur" != "$verrepo" ]; then
      sendWebHooks
    else
      echo "Versão do $pkgname é igual !"
      sleep 1
    fi
  fi
echo
echo
done




