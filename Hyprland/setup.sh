#!/bin/bash
aur="$1"
if [[ "$2" == "true" ]]; then
  config_folder="$HOME/Hypr"
else
  config_folder="$PWD/Hyprland"
fi

pkgs=(
  alacritty
  blueman
  brightnessctl
  cliphist
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
printf "\n"
echo "Installing Hyprland and utils..." 
formatting_pkgs "${pkgs[@]}"

install_pkgs=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_pkgs" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${pkgs[*]}")
else
  exit 1
fi

msg "Setting up Hyprland..."
bash -c "./symlink.sh $config_folder/hypr --to-config"
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/hyprland.conf")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/hyprlock.conf")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/hyprpaper.conf")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/scripts/power-profiles.sh")
sed -i "s|\$HYPRCONF|$config_folder|g" $(realpath "$config_folder/hypr/scripts/toggle-waybar.sh")
msg_update "Setting up Hyprland: completed"

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

printf "\n"
msg -n "Hyprland setup all completed"
printf "\n"
