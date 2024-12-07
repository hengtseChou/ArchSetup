#!/bin/bash
aur="$1"
if [[ "$2" == "true" ]]; then
  config_folder="$HOME/Conf"
else
  config_folder="$PWD/base/config"
fi

pkgs=(
  eza
  fastfetch
  fd
  fontconfig
  fzf
  greetd-tuigreetd
  ifuse
  man-db
  nano
  power-profiles-daemon
  starship
  tealdeer
  xdg-user-dirs
  zoxide
  zsh
)
fonts=(
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-jetbrains-mono-nerd
  ttf-ubuntu-font-family
  ttf-ubuntu-mono-nerd
)

formatted_pkgs=()
for pkg in "${pkgs[@]}"; do
  formatted_pkgs+=("   - $pkg")
done
formatted_fonts=()
for font in "${fonts[@]}"; do
  formatted_fonts+=("   - $font")
done

figlet "Base Setup" -f smslant

gum style "Installing packages:" "${formatted_pkgs[@]}"
install_pkgs=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_pkgs" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${pkgs[@]}"
  msg -n "Completed"
else
  exit 1
fi

gum style "" "Installing fonts:" "${formatted_fonts[@]}"
install_fonts=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_fonts" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${fonts[@]}"
  msg -n "Completed"
else
  exit 1
fi
printf "\n"

msg "Setting up fontconfig..."
bash -c "./symlink.sh '$config_folder/fontconfig' --to-config; fc-cache -f" >/dev/null
msg_update "Setting up fontconfig: completed"

msg -n "Setting up git..."
bash -c "./symlink.sh '$config_folder/git/.gitconfig' --to-home" >/dev/null
git_username=$(gum input --header "Enter your username for git:")
git_email=$(gum input --header "Enter your email for git:")
git config --global user.name "$git_username"
git config --global user.email "$git_email"
msg -n "Setting up git: completed"

msg "Setting up greetd..."
sudo -v
bash -c "sudo systemctl enable greetd.service; sudo cp $config_folder/greetd/config.toml /etc/greetd/config.toml"
msg_update "Setting up greetd: completed"

msg "Setting up makepkg..."
sudo -v
bash -c "sudo cp $config_folder/makepkg/makepkg.conf /etc/makepkg.conf"
msg_update "Setting up makepkg: completed"

msg "Setting up nano..."
bash -c "./symlink.sh '$config_folder/nano/.nanorc' --to-home" >/dev/null
msg_update "Setting up nano: completed"

msg "Setting up pacman..."
sudo -v
bash -c "sudo cp $config_folder/pacman/pacman.conf /etc/pacman.conf"
msg_update "Setting up pacman: completed"

msg "Setting up starship..."
bash -c "./symlink.sh '$config_folder/starship/starship.toml' --to-config" >/dev/null
msg_update "Setting up starship: completed"

msg "Setting up tealdeer..."
tldr --update --quiet
msg_update "Setting up tealdeer: completed"

msg "Setting up xdg-user-dirs..."
xdg-user-dirs-update
msg_update "Setting up xdg-user-dirs: completed"

msg -n "Setting up zsh..."
bash -c "./symlink.sh '$config_folder/zsh/.zshrc' --to-home" >/dev/null
chsh -s /bin/zsh
msg -n "Setting up zsh: completed"

msg -n "Base setup all completed"
printf "\n"
