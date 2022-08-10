#!/usr/bin/env bash
#
# pos-os-postinstall.sh - Instalar e configura programas no Pop!_OS (20.04 LTS ou superior)
#
# Website:       https://diolinux.com.br
# Autor:         Dionatan Simioni
#
# ------------------------------------------------------------------------ #

set -e

##URLS

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_INSYNC="https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.7.2.50318-impish_amd64.deb"
URL_VSCODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
URL_GITKRAKEN="https://www.gitkraken.com/download/linux-deb"
URL_INSOMNIA="https://updates.insomnia.rest/downloads/ubuntu/latest?&app=com.insomnia.app&source=website"

##DIRETÓRIOS E ARQUIVOS

DIRETORIO_DOWNLOADS="$HOME/Downloads/Programas"
FILE="/home/$USER/.config/gtk-3.0/bookmarks"

#CORES

VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'

#FUNÇÕES

## Atualizando repositório e fazendo atualização do sistema ##
apt_update() {
  sudo apt update && sudo apt dist-upgrade -y
}

## Removendo travas eventuais do apt ##
travas_apt() {
  sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock
}

## Adicionando/Confirmando arquitetura de 32 bits ##
add_archi386() {
  sudo dpkg --add-architecture i386
}

## Atualizando o repositório ##
just_apt_update() {
  sudo apt update -y
}

## Pacotes .DEB a serem instalados via apt ##
PROGRAMAS_PARA_INSTALAR=(
  snapd
  ratbagd
  synaptic
  vlc
  code
  gnome-sushi 
  folder-color
  git
  wget
  ubuntu-restricted-extras
  tensorman # Para o PopOS -> Gerenciador de pacotes TensorFlow
  nvidia-docker2 # Para o PopOS -> Gerenciador de pacotes CUDA-TensorFlow
  fonts-firacode # Fonte extra
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##
install_debs() {

  echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"

  mkdir "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_4K_VIDEO_DOWNLOADER" -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_INSYNC"              -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_SYNOLOGY_DRIVE"      -P "$DIRETORIO_DOWNLOADS"

  ## Instalando pacotes .deb baixados na sessão anterior ##
  echo -e "${VERDE}[INFO] - Instalando pacotes .deb baixados${SEM_COR}"
  sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

  # Instalar programas no apt
  echo -e "${VERDE}[INFO] - Instalando pacotes apt do repositório${SEM_COR}"

  for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
    if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
      sudo apt install "$nome_do_programa" -y
    else
      echo "[INSTALADO] - $nome_do_programa"
    fi
  done
}

## Instalando pacotes Flatpak ##
install_flatpaks() {

  echo -e "${VERDE}[INFO] - Instalando pacotes flatpak${SEM_COR}"

  flatpak install flathub com.obsproject.Studio -y
  flatpak install flathub org.gimp.GIMP -y
  flatpak install flathub com.spotify.Client -y
  flatpak install flathub com.bitwarden.desktop -y
  flatpak install flathub org.freedesktop.Piper -y
  flatpak install flathub org.onlyoffice.desktopeditors -y
  flatpak install flathub org.qbittorrent.qBittorrent -y
  flatpak install flathub org.flameshot.Flameshot -y
  flatpak install flathub org.inkscape.Inkscape -y
  flatpak install flathub com.discordapp.Discord -y
}

## Instalando pacotes Snap ##

install_snaps() {

  echo -e "${VERDE}[INFO] - Instalando pacotes snap${SEM_COR}"

}

## Instalando ferramentas de desenvolvimento ##
install_development_packages() {

  echo -e "${VERDE}[INFO] - Instalando ferramentas de desenvolvimento${SEM_COR}"

  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  sudo nvm install-latest-npm

  npm install -g yarn
  npm install -g @angular/cli
  npm install -g create-react-app
}

# -------------------------------------------------------------------------- #
# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #


## Finalização, atualização e limpeza ##
system_clean(){
  apt_update -y
  flatpak update -y
  sudo apt autoclean -y
  sudo apt autoremove -y
  nautilus -q
}

# -------------------------------------------------------------------------- #
# ----------------------------- CONFIGS EXTRAS ----------------------------- #

## Cria pastas para produtividade no nautilus ##
extra_config() {

  mkdir /home/$USER/Projetos
  mkdir /home/$USER/Vídeos/'OBS Rec'

  #Adiciona atalhos ao Nautilus
  if test -f "$FILE"; then
      echo "$FILE já existe"
  else
      echo "$FILE não existe, criando..."
      touch /home/$USER/.config/gkt-3.0/bookmarks
  fi

  echo "file:///home/$USER/Projetos 🔵 Projetos" >> $FILE
  #echo "file:///home/$USER/Resolve 🔴 Resolve" >> $FILE
  #echo "file:///home/$USER/TEMP 🕖 TEMP" >> $FILE
}

# -------------------------------------------------------------------------------- #
# -------------------------------EXECUÇÃO----------------------------------------- #

travas_apt
travas_apt
apt_update
travas_apt
add_archi386
just_apt_update
install_debs
install_flatpaks
# install_snaps
install_development_packages
extra_config
apt_update
system_clean

## finalização ##
echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"
