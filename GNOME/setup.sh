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
formatted_core_apps=()
for app in "${core_apps[@]}"; do
  formatted_core_apps+=("   - $app")
done

gum style "Installing GNOME shell and core applications..." "${formatted_core_apps[@]}"
install_core_apps=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_core_apps" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${core_apps[@]}"
  msg -n "Completed"
else
  exit 1
fi
printf "\n"

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
formatted_extra_apps=()
for app in "${extra_apps[@]}"; do
  formatted_extra_apps+=("   - $app")
done
gum style "Installing some GNOME extra applications..." "${formatted_extra_apps[@]}"
install_extra_apps=$(gum choose --header "Proceed?" "Yes" "No, skip this step")
if [[ "$install_extra_apps" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${extra_apps[@]}"
  msg -n "Completed"
else
  msg -n "Skipping GNOME extra allpications"
fi
printf "\n"

msg "Setting up nautilus-open-any-terminal..."
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal alacritty
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal keybindings '<Ctrl><Alt>t'
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal new-tab true
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal flatpak system
msg_update "Setting up nautilus-open-any-terminal: completed"
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
formatted_exts=()
for ext in "${extensions[@]}"; do
  formatted_exts+=("   - ${ext%@*}")
done

gum style "Installing some GNOME extensions..." "${formatted_exts[@]}"
install_apps=$(gum choose --header "Proceed?" "Yes" "No, skip this step")
if [[ "$install_apps" == "Yes, install extensions" ]]; then
  msg -n "Installing GNOME extensions requires python-pipx and jq"
  sudo -v
  gum spin --title "Installing dependencies..." -- $aur -S --needed --noconfirm python-pipx jq
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
  msg -n "Installing GNOME extensions: completed"
  extensions="[$(printf "'%s'," "${extensions[@]}" | sed 's/,$//')]"
  gsettings set org.gnome.shell enabled-extensions "$extensions"

  msg -n "Setting up extensions preferences..."
  dconf load / <./GNOME/extensions-settings.ini
  msg_update "Setting up extensions preferences: completed"
else
  msg -n "Skipping GNOME extensions"
fi

msg -n "GNOME setup all completed"
printf "\n"
