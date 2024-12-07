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
  hypridle
  hyprland
  hyprlock
  hyprpaper
  hyprshot
  pamixer
  polkit-gnome
  pwvucontrol
  rofi-wayland
  swaync
  udiskie
  waybar
  wlogout
  xdg-desktop-portal-hyprland
)
formatted_pkg=()
for pkg in "${pkgs[@]}"; do
  formatted_pkg+=("   - $pkg")
done

gum style "Installing Hyprland and utils..." "${formatted_pkg[@]}"
install_pkgs=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_pkgs" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${pkgs[@]}"
  msg -n "Completed"
else
  exit 1
fi
printf "\n"

msg "Setting up Hyprland..."
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/hyprland.conf")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/hyprlock.conf")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/hyprpaper.conf")
msg_update "Setting up Hyprland: completed"

msg "Settings up scripts..."
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/scripts/power-profiles.sh")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/scripts/toggle-waybar.sh")
msg_update "Settings up scripts: completed"

msg "Setting up rofi..."
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/rofi/config-cliphist.rasi")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/rofi/config-power.rasi")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/rofi/config.rasi")
msg_update "Setting up rofi: completed"

msg "Setting up waybar..."
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/waybar/config")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/waybar/modules.jsonc")
msg_update "Setting up waybar: completed"

msg "Setting up zsh..."
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$HOME/.zshrc")
msg_update "Setting up zsh: completed"

msg -n "Hyprland setup all completed"
printf "\n"
