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
  greetd-tuigreet
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

figlet "Base Setup" -f smslant

printf "Installing packages...\n"
formatting_pkgs "${pkgs[@]}"
install_pkgs=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_pkgs" == "Yes" ]]; then
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${pkgs[*]}")
else
  exit 1
fi

printf "Installing fonts...\n"
formatting_pkgs "${fonts[@]}"
install_fonts=$(gum choose --header "Proceed?" "Yes" "No (exit)")
if [[ "$install_fonts" == "Yes" ]]; then
  gum spin --title "Running $aur..." -- $aur -S --needed --noconfirm $(echo "${fonts[*]}")
else
  exit 1
fi

msg "Setting up fontconfig..."
./symlink.sh $config_folder/fontconfig --to-config
fc-cache -f
msg_update "Setting up fontconfig: completed"

msg -n "Setting up git..."
./symlink.sh $config_folder/git/.gitconfig --to-home
git_username=$(gum input --header "Enter your username for git:")
git_email=$(gum input --header "Enter your email for git:")
git config --global user.name "$git_username"
git config --global user.email "$git_email"
msg -n "Setting up git: completed"

msg "Setting up greetd..."
bash -c "sudo systemctl enable greetd.service; sudo cp $config_folder/greetd/config.toml /etc/greetd/config.toml"
msg_update "Setting up greetd: completed"

msg "Setting up makepkg..."
bash -c "sudo cp $config_folder/makepkg/makepkg.conf /etc/makepkg.conf"
msg_update "Setting up makepkg: completed"

msg "Setting up nano..."
./symlink.sh $config_folder/nano/.nanorc --to-home
msg_update "Setting up nano: completed"

msg "Setting up pacman..."
bash -c "sudo cp $config_folder/pacman/pacman.conf /etc/pacman.conf"
msg_update "Setting up pacman: completed"

msg "Setting up starship..."
./symlink.sh $config_folder/starship/starship.toml --to-config
msg_update "Setting up starship: completed"

msg "Setting up tealdeer..."
tldr --update --quiet
msg_update "Setting up tealdeer: completed"

msg "Setting up xdg-user-dirs..."
xdg-user-dirs-update
msg_update "Setting up xdg-user-dirs: completed"

msg -n "Setting up zsh..."
./symlink.sh $config_folder/zsh/.zshrc --to-home
chsh -s /bin/zsh
msg -n "Setting up zsh: completed"

msg -n "Base setup all completed"
printf "\n"
