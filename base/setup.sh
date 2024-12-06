#!/bin/bash
aur="$1"
if [[ -n "$2" ]]; then
  config_folder="$2"
else
  config_folder="$PWD/config"
fi


msg() {
  if [ "$1" == "-n" ]; then
    shift
    printf "\033[s\033[38;2;117;138;155m%s\033[0m\n" "$1"
  else
    printf "\033[s\033[38;2;117;138;155m%s\033[0m" "$1"
  fi
}
msg_update() {
  printf "\033[u\033[2K\r\033[38;2;117;138;155m%s\033[0m\n" "$1"
}

pkgs=(
  fontconfig
  greetd-tuigreetd
  nano
  starship
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
install_pkgs=$(gum choose --header "Proceed?" "Yes" "No")
if [[ "$install_pkgs" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${pkgs[@]}"
  msg -n "Completed"
else
  exit 1
fi

gum style "" "Installing fonts:" "${formatted_fonts[@]}"
install_fonts=$(gum choose --header "Proceed?" "Yes" "No")
if [[ "$install_fonts" == "Yes" ]]; then
  sudo -v
  gum spin --title "Running $aur..." -- sudo $aur -S --needed --noconfirm "${fonts[@]}"
  msg -n "Completed"
else
  exit 1
fi
printf "\n"

msg "Setting up fontconfig..."
bash -c "./../symlink.sh '$config_folder/fontconfig' --to-config; fc-cache -f" >/dev/null
msg_update "Setting up fontconfig: completed"

msg -n "Setting up git..."
bash -c "./../symlink.sh '$config_folder/git/.gitconfig' --to-home" >/dev/null
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
bash -c "./../symlink.sh '$config_folder/nano/.nanorc' --to-home" >/dev/null
msg_update "Setting up nano: completed"

msg "Setting up pacman..."
sudo -v
bash -c "sudo cp $config_folder/pacman/pacman.conf /etc/pacman.conf"
msg_update "Setting up pacman: completed"

msg "Setting up starship..."
bash -c "./../symlink.sh '$config_folder/starship/starship.toml' --to-config" >/dev/null
msg_update "Setting up starship: completed"

msg -n "Setting up zsh..."
bash -c "./../symlink.sh '$config_folder/zsh/.zshrc' --to-home" >/dev/null
chsh -s /bin/zsh
msg -n "Setting up zsh: completed"
