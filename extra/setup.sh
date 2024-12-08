#!/bin/bash
aur="$1"
need_copy=0
if [[ "$2" == "true" ]]; then
  config_folder="$HOME/Conf"
  need_copy=1
else
  config_folder="$PWD/extra/config"
fi

filter_not_installed() {
  local packages=("$@")
  local not_installed=()
  for package in "${packages[@]}"; do
    if ! pacman -Qi "$package" &>/dev/null; then
      not_installed+=("$package")
    fi
  done
  echo "${not_installed[@]}"
}

# ---------------------------------------- apps ---------------------------------------- #

apps=(
  btrfs-assistant
  chromium
  spotify
  timeshift
  vlc-git
  visual-studio-code-bin
  zotero-bin
)
not_installed_apps=($(filter_not_installed "${apps[@]}"))
if [[ -n $not_installed_apps ]]; then
  selected_apps=$(gum choose --header "Some exceptional GUI apps, if you like" "${not_installed_apps[@]}" --no-limit)
  if [[ -n $selected_apps ]]; then
    printf "Installing the following apps...\n"
    formatting_pkgs "${selected_apps[@]}"
    gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${selected_apps[*]}")
    msg -n "Completed"

    for app in "${selected_apps[@]}"; do
      case $app in
      "chromium")
        msg "Setting up chromium..."
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/chromium $HOME/Conf
        ./symlink.sh $config_folder/chromium/chromium-flags.conf --to-config
        msg_update "Setting up chromium: completed"
        ;;
      "spotify")
        msg "Setting up spotify..."
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/spotify $HOME/Conf
        ./symlink.sh $config_folder/spotify/spotify-flags.conf --to-config
        msg_update "Setting up spotify: completed"
        ;;
      "visual-studio-code-bin")
        msg "Setting up visual-studio-code-bin..."
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/code $HOME/Conf
        ./symlink.sh $config_folder/code/code-flags.conf --to-config
        msg_update "Setting up visual-studio-code-bin: completed"
        ;;
      esac
    done
  else
    msg -n "Skipping GUI apps installation"
  fi
  printf "\n"
fi

# -------------------------------------- cli utils ------------------------------------- #

cli_utils=(
  btop
  cava
  docker
  github-cli
  htop
  ncdu
  onefetch
  peaclock
  rate-mirrors
  rclone
  speedtest-cli
  trash-cli
)
not_installed_cli_utils=($(filter_not_installed "${cli_utils[@]}"))
if [[ -n $not_installed_cli_utils ]]; then
  selected_cli_utils=$(gum choose --header "Some useful CLI utilities, if you like" "${not_installed_cli_utils[@]}" --no-limit)
  if [[ -n $selected_cli_utils ]]; then
    printf "Installing the following CLI utilities...\n"
    formatting_pkgs "${selected_cli_utils[@]}"
    gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${selected_cli_utils[*]}")
    msg -n "Completed"

    for app in "${selected_cli_utils[@]}"; do
      case $app in
      "btop")
        msg -n "Setting up btop..."
        sudo setcap cap_perfmon=+ep /usr/bin/btop
        msg -n "Setting up btop: completed"
        ;;
      "cava")
        msg "Setting up cava..."
        mkdir -p $HOME/.config/cava
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/cava $HOME/Conf
        ./symlink.sh $config_folder/cava/config --custom-dir $HOME/.config/cava
        msg_update "Setting up cava: completed"
        ;;
      "docker")
        msg -n "Setting up docker..."
        sudo groupadd docker >/dev/null
        sudo usermod -aG docker $USER >/dev/null
        msg -n "Setting up docker: completed"
        ;;
      "htop")
        msg "Setting up htop..."
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/htop $HOME/Conf
        ./symlink.sh $config_folder/htop --to-config
        msg "Setting up htop: completed"
        ;;
      esac
    done
  else
    msg -n "Skipping CLI utilities installation"
  fi
  printf "\n"
fi

# ------------------------------------- build tools ------------------------------------ #

build_tools=(
  cmake
  go
  meson
  ninja
  npm
  rust
)
not_installed_build_tools=($(filter_not_installed "${build_tools[@]}"))
if [[ -n $not_installed_build_tools ]]; then
  selected_build_tools=$(gum choose --header "Some essential build tools, if you like" "${not_installed_build_tools[@]}" --no-limit)
  if [[ -n $selected_build_tools ]]; then
    printf "Installing the following build tools...\n"
    formatting_pkgs "${selected_build_tools[@]}"
    gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${selected_build_tools[*]}")
    msg -n "Completed"

    for tool in "${selected_build_tools[@]}"; do
      case $tool in
      "go")
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/go $HOME/Conf

        msg "Setting up go..."
        mkdir -p $HOME/.config/go
        ./symlink.sh $config_folder/go/env --custom-dir $HOME/.config/go
        msg_update "Setting up go: completed"
        ;;
      "npm")
        [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/npm $HOME/Conf

        msg "Setting up npm..."
        ./symlink.sh $config_folder/npm/.npmrc --to-home
        msg_update "Setting up npm: completed"
        ;;
      esac
    done
  else
    msg -n "Skipping build tools installation"
  fi
  printf "\n"
fi

# --------------------------------------- fcitx5 --------------------------------------- #

install_fcitx5=$(gum choose --header "Do you need fcitx5 as input medhod?" "Yes" "No, skip this step")
if [[ "$install_fcitx5" == "Yes" ]]; then
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm fcitx5-im fcitx5-chewing fcitx5-mcbopomofo-git
  msg "Setting up fcitx5..."
  bash -c "
  sudo gtk-update-icon-cache /usr/share/icons/*

  if [ -f $HOME/.gtkrc-2.0 ]; then
    echo 'gtk-im-module=\"fcitx\"' >> $HOME/.gtkrc-2.0
  else
    echo 'gtk-im-module=\"fcitx\"' > $HOME/.gtkrc-2.0
  fi

  if [ -f $HOME/.config/gtk-3.0/settings.ini ]; then
    echo 'gtk-im-module=fcitx' >> $HOME/.config/gtk-3.0/settings.ini
  else
    echo '[Settings]' > $HOME/.config/gtk-3.0/settings.ini
    echo 'gtk-im-module=fcitx' >> $HOME/.config/gtk-3.0/settings.ini
  fi

  if [ -f $HOME/.config/gtk-4.0/settings.ini ]; then
    echo 'gtk-im-module=fcitx' >> $HOME/.config/gtk-4.0/settings.ini
  else
    echo '[Settings]' > $HOME/.config/gtk-4.0/settings.ini
    echo 'gtk-im-module=fcitx' >> $HOME/.config/gtk-4.0/settings.ini
  fi

  gsettings set org.gnome.settings-daemon.plugins.xsettings overrides \"{'Gtk/IMModule': <'fcitx'>}\"
  "
  msg_update "Setting up fcitx5: completed"
  msg -n "Note that this configuration is for GTK + Wayland"
else
  msg -n "Skipping fcitx5 installation"
fi
printf "\n"

# -------------------------------------- R/RStudio ------------------------------------- #

install_r=$(gum choose --header "Do you need R/RStudio?" "Yes" "No, skip this step")
if [[ "$install_r" == "Yes" ]]; then
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm r gcc-fortran
  # install RStudio with the gist PKGBUILD
  gum spin --title "Cloning and installing RStudio..." -- bash -c "
  git clone https://gist.github.com/9bad76d97ff17e37980cf40416fc5596.git rstudio-desktop-bin
  cd rstudio-desktop-bin
  makepkg -si
  cd ..
  rm -rf rstudio-desktop-bin
  "
  msg -n "Installing R/RStudio: completed"

  [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/r $HOME/Conf
  [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/rstudio $HOME/Conf

  msg "Setting up R..."
  ./symlink.sh $config_folder/R/.Rprofile --to-home
  msg_update "Setting up R: completed"
  msg "Setting up RStudio..."
  mkdir -p $HOME/.config/rstudio
  ./symlink.sh $config_folder/rstudio/config.json --custom-dir $HOME/.config/rstudio
  ./symlink.sh $config_folder/rstudio/keybindings --custom-dir $HOME/.config/rstudio
  ./symlink.sh $config_folder/rstudio/rstudio-prefs.json --custom-dir $HOME/.config/rstudio
  msg_update "Setting up RStudio: completed"
else
  msg -n "Skipping R/RStudio installation"
fi
printf "\n"

# -------------------------------------- spicetify ------------------------------------- #

if pacman -Qi spotify &>/dev/null; then
  install_spicetify=$(gum choose --header "You have installed spotify. Do your want to install spicetify for advanced styling?" "Yes" "No, skip this step")
  if [[ "$install_spicetify" == "Yes" ]]; then
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm spicetify-cli

    [ $need_copy -eq 1 ] && cp -r $PWD/extra/config/spicetify $HOME/Conf

    msg "Setting up spicetify..."
    mkdir -p $HOME/.config/spicetify
    ./symlink.sh $HOME/Conf/spicetify/Extensions --custom-dir $HOME/.config/spicetify
    ./symlink.sh $HOME/Conf/spicetify/Themes --custom-dir $HOME/.config/spicetify
    ./symlink.sh $HOME/Conf/spicetify/config-xpui.ini --custom-dir $HOME/.config/spicetify
    spicetify backup apply >/dev/null
    msg_update "Setting up spicetify: completed"
  else
    msg -n "Skipping spicetify installation"
  fi
fi
printf "\n"

msg -n "Extra setup all completed"