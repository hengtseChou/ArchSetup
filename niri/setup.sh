#!/bin/bash
aur="$1"
if [[ "$2" == "true" ]]; then
  config_folder="$HOME/Niri"
else
  config_folder="$PWD/niri"
fi

pkgs=(
  alacritty
  blueman
  brightnessctl
  cliphist
  fuzzel
  niri
  pamixer
  polkit-gnome
  pwvucontrol
  swaybg
  swayidle
  swaylock-effects
  swaync
  udiskie
  waybar
  wlogout
  xwayland-satellite
)


printf "Installing niri and utils...\n"
formatting_pkgs "${pkgs[@]}"
install_pkgs=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_pkgs" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm $(echo "${pkgs[*]}")
else
  exit 1
fi

msg "Setting up niri..."
bash -c "./symlink.sh '$config_folder/niri' --to-config" >/dev/null
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/niri/config.kdl")
msg_update "Setting up niri: completed"

msg "Settings up scripts..."
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/scripts/power-profiles.sh")
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/scripts/swayidle.sh")
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/scripts/toggle-swayidle.sh")
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/scripts/toggle-waybar.sh")
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/scripts/wlogout.sh")
msg_update "Settings up scripts: completed"

msg "Setting up waybar..."
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/waybar/config")
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$config_folder/waybar/modules.jsonc")
msg_update "Setting up waybar: completed"

msg "Setting up zsh..."
sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$HOME/.zshrc")
msg_update "Setting up zsh: completed"

printf "\n"
msg -n "niri setup all completed"
printf "\n"
