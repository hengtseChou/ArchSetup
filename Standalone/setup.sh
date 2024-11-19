#!/bin/bash
if ! command -v paru 2>&1 >/dev/null; then
  echo ":: Error: paru is not installed. Exiting."
  exit 1
fi

apps=(
  btrfs-assistant
  chromium
  docker
  firefox
  onefetch
  onlyoffice-bin
  peaclock
  rclone
  spotify
  timeshift
  visual-studio-code-bin
  vlc-git
  zotero-bin
)

utils=(
  btop
  github-cli
  go
  gotop-bin
  htop
  ifuse
  man-db
  ncdu
  npm
  rate-mirrors-bin
  rust
  speech-dispatcher
  trash-cli
)

echo -e "\n----- Standalone apps installation -----\n"

echo ":: Installing apps..."
paru -S --needed "${apps[@]}"
echo -e ":: Done. Proceeding to the next step...\n"

echo ":: Installing utils..."
paru -S --needed "${utils[@]}"
echo -e ":: Done. Proceeding to the next step...\n"

read -p ":: Install fcitx5? (Y/n): " install_fcitx5
install_fcitx5=${install_fcitx5:-Y}
if [[ "$install_fcitx5" =~ ^([yY])$ ]]; then
  paru -S --needed fcitx5-im fcitx5-chewing fcitx5-mcbopomofo-git
  sudo update-icon-caches /usr/share/icons/*
  echo ":: Configuring fcitx5..."
  echo ":: Note that this configuration is for GTK + Wayland."
  if [ -f ~/.gtkrc-2.0 ]; then
    echo "gtk-im-module="fcitx"" >>~/.gtkrc-2.0
  else
    echo "gtk-im-module="fcitx"" >~/.gtkrc-2.0
  fi
  if [ -f ~/.config/gtk-3.0/settings.ini ]; then
    echo "gtk-im-module=fcitx" >>~/.config/gtk-3.0/settings.ini
  else
    echo "[Settings]" >~/.config/gtk-3.0/settings.ini
    echo "gtk-im-module=fcitx" >>~/.config/gtk-3.0/settings.ini
  fi
  if [ -f ~/.config/gtk-4.0/settings.ini ]; then
    echo "gtk-im-module=fcitx" >>~/.config/gtk-4.0/settings.ini
  else
    echo "[Settings]" >~/.config/gtk-4.0/settings.ini
    echo "gtk-im-module=fcitx" >>~/.config/gtk-4.0/settings.ini
  fi
  gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Gtk/IMModule':<'fcitx'>}"
  echo -e ":: Done. Proceeding to the next step...\n"
else
  echo ":: Skipping fcitx5 installation"
  echo -e ":: Proceeding to the next step...\n"
fi

read -p ":: Install R and RStudio? (Y/n): " install_r
install_r=${install_r:-Y}
if [[ "$install_r" =~ ^([yY])$ ]]; then
  paru -S --needed r gcc-fortran
  # install RStudio with the gist PKGBUILD
  git clone https://gist.github.com/9bad76d97ff17e37980cf40416fc5596.git rstudio-desktop-bin
  cd rstudio-desktop-bin
  makepkg -si
  cd ..
  rm -rf rstudio-desktop-bin
  echo -e ":: Done. Proceeding to the next step...\n"
else
  echo ":: Skipping R and RStudio installation"
  echo -e ":: Proceeding to the next step...\n"
fi

read -p ":: Install Spicetify? (Y/n): " install_spicetify
install_spicetify=${install_spicetify:-Y}
if [[ "$install_spicetify" =~ ^([yY])$ ]]; then
  sudo chmod a+wr /opt/spotify
  sudo chmod a+wr /opt/spotify/Apps -R
  paru -S --needed spicetify-cli
  spicetify backup apply
  echo ":: Done."
else
  echo ":: Skipping Spicetify installation"
fi

echo -e "\n:: Standalone apps installation completed. \n"
