#!/bin/bash
aur="$1"

# -------------------------------------- core apps ------------------------------------- #

core_apps=(
  evince
  firefox
  gnome-browser-connector
  gnome-calculator
  gnome-control-center
  gnome-logs
  gnome-menus
  gnome-screenshot
  gnome-shell
  gnome-terminal
  gnome-text-editor
  loupe
  nautilus
  sushi
)

printf "Installing GNOME shell and core applications...\n"
formatting_pkgs "${core_apps[@]}"

install_core_apps=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_core_apps" == "Yes" ]]; then
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${core_apps[*]}")
else
  exit 1
fi

msg "Setting up wm-preferences..."
dconf load / <./GNOME/wm-preferences.ini
msg_update "Setting up wm-preferences: completed"

msg "Setting up keybindings..."
dconf load / <./GNOME/keybindings.ini
msg_update "Setting up keybindings: completed"

msg "Setting up terminal theme..."
sed -i "s/\$DEFAULT/$(gsettings get org.gnome.Terminal.ProfilesList default)/g" ./GNOME/terminal-theme.ini
dconf load / <./GNOME/terminal-theme.ini
msg_update "Setting up terminal theme: completed"
printf "\n"

# ------------------------------------- extra apps ------------------------------------- #

extra_apps=(
  dconf-editor
  font-manager
  file-roller
  gthumb
  gvfs-google
  impression
  menulibre
  nautilus-open-any-terminal
  turtle
)
printf "Installing some GNOME extra applications...\n"
formatting_pkgs "${extra_apps[@]}"

install_extra_apps=$(gum choose --header "Proceed?" "Yes" "No, skip this step")
if [[ "$install_extra_apps" == "Yes" ]]; then
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${extra_apps[*]}")
  msg "Setting up nautilus-open-any-terminal..."
  gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal alacritty
  gsettings set com.github.stunkymonkey.nautilus-open-any-terminal keybindings '<Ctrl><Alt>t'
  gsettings set com.github.stunkymonkey.nautilus-open-any-terminal new-tab true
  gsettings set com.github.stunkymonkey.nautilus-open-any-terminal flatpak system
  msg_update "Setting up nautilus-open-any-terminal: completed"
else
  msg -n "Skipping GNOME extra applications"
fi
printf "\n"

# ------------------------------------- extensions ------------------------------------- #

extensions=(
  AlphabeticalAppGrid@stuarthayhurst
  blur-my-shell@aunetx
  caffeine@patapon.info
  clipboard-indicator@tudmotu.com
  gnome-ui-tune@itstime.tech
  grand-theft-focus@zalckos.github.com
  kimpanel@kde.org
)
export EXTENSIONS="${extensions[*]}"

printf "Installing some GNOME extensions...\n"
for ext in "${extensions[@]}"; do
  echo -ne "   - \033[38;2;117;138;155m${ext%@*}\033[0m\n"
done
printf "\n"

install_extensions=$(gum choose --header "Proceed?" "Yes" "No, skip this step")
if [[ "$install_extensions" == "Yes" ]]; then

  deps=("python-pipx" "jq")
  printf "Installing dependencies...\n"
  formatting_pkgs "${deps[@]}"
  install_deps=$(gum choose --header "Proceed?" "Yes" "No (exit)")
  if [[ "$install_deps" == "Yes" ]]; then
    gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${deps[*]}")
  else
    exit 1
  fi

  gum spin --title "Installing gnome-extensions-cli..." -- pipx install gnome-extensions-cli --system-site-packages
  export PATH="$HOME/.local/bin:$PATH"
  gum spin --title "Installing GNOME extensions..." -- bash -c '
  IFS=" " read -r -a extensions <<< "$EXTENSIONS"
  shell_version=$(gnome-shell --version | cut -d" " -f3)
  for uuid in "${extensions[@]}"; do
    info_json=$(curl -sS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")
    download_url=$(echo "$info_json" | jq ".download_url" --raw-output)
    gnome-extensions install "https://extensions.gnome.org$download_url"
  done
  '
  printf "\n"
  msg -n "Installing GNOME extensions: completed"
  extensions="[$(printf "'%s'," "${extensions[@]}" | sed 's/,$//')]"
  gsettings set org.gnome.shell enabled-extensions "$extensions"

  msg -n "Setting up extensions preferences..."
  dconf load / <./GNOME/extensions-settings.ini
  msg_update "Setting up extensions preferences: completed"
else
  msg -n "Skipping GNOME extensions"
fi
printf "\n"

msg -n "GNOME setup all completed"
printf "\n"
