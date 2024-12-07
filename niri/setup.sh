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
  fd
  fuzzel
  niri
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
formatted_pkg=()
for pkg in "${pkgs[@]}"; do
  formatted_pkg+=("   - $pkg")
done

gum style "Installing niri apps and utils..." "${formatted_pkg[@]}"
install_pkgs=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_pkgs" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${pkgs[@]}"
  msg -n "Completed"
else
  exit 1
fi
printf "\n"

msg "Setting up niri..."
bash -c "./symlink.sh '$config_folder/niri' --to-config" >/dev/null
scripts_to_ensure=(
  "$config_folder/niri/config.kdl"
  "$config_folder/scripts/power-profiles.sh"
  "$config_folder/scripts/swayidle.sh"
  "$config_folder/scripts/toggle-swayidle.sh"
  "$config_folder/scripts/toggle-waybar.sh"
  "$config_folder/scripts/wlogout.sh"
  "$config_folder/waybar/config"
  "$config_folder/waybar/modules.jsonc"
  "$HOME/.zshrc"
)
for script in "${scripts_to_ensure[@]}"; do
  sed -i "s|\$NIRICONF|$config_folder|g" $(realpath "$script")
done
msg_update "Setting up niri: completed"
msg -n "niri setup all completed"
