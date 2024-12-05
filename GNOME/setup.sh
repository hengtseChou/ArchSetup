#!/bin/bash
if ! command -v paru 2>&1 >/dev/null; then
  echo ":: Error: paru is not installed. Exiting."
  exit 1
fi

apps=(
  fastfetch
  fontconfig
  starship
  zsh
)

gnome_apps=(
  dconf-editor
  file-roller
  font-manager
  gnome-browser-connector
  gnome-calculator
  gnome-control-center
  gnome-logs
  gnome-menus
  gnome-screenshot
  gnome-shell
  gnome-terminal
  gnome-text-editor
  gthumb
  gvfs-google
  loupe
  menulibre
  nautilus
  polkit-gnome
  seahorse
  sushi
)

utils=(
  eza
  fzf
  ifuse
  networkmanager
  power-profiles-daemon
  udiskie
  xdg-user-dirs-gtk
  zoxide
)

theming=(
  yaru-gtk-theme
  yaru-icon-theme
)

fonts=(
  ttf-ubuntu-font-family
  ttf-ubuntu-mono-nerd
)

extensions=(
  AlphabeticalAppGrid@stuarthayhurst
  blur-my-shell@aunetx
  burn-my-windows@schneegans.github.com
  caffeine@patapon.info
  clipboard-indicator@tudmotu.com
  dash-to-dock@micxgx.gmail.com
  grand-theft-focus@zalckos.github.com
  kimpanel@kde.org
)

echo -e "\n----- GNOME configuration script -----\n"
echo ":: Installing apps..."
paru -S --needed "${apps[@]}"
echo -e ":: Done. Proceeding to the next step...\n"

echo ":: Installing GNOME apps..."
paru -S --needed "${gnome_apps[@]}"
echo -e ":: Done. Proceeding to the next step...\n"

echo ":: Installing utils..."
paru -S --needed "${utils[@]}"
echo -e ":: Done. Proceeding to the next step...\n"

echo ":: Installing fonts..."
paru -S --needed "${fonts[@]}"
echo -e ":: Done. Proceeding to the next step...\n"

if [[ "$SHELL" != "/bin/zsh" ]]; then
  echo ":: Setting up default shell..."
  chsh -s /bin/zsh
  echo -e ":: Done. Proceeding to the next step...\n"
else
  echo ":: Setting up default shell: Already set to zsh"
  echo -e ":: Proceeding to the next step...\n"
fi

read -p ":: Skip theming? (y/N): " skip_theming
skip_theming=${skip_theming:-N}
if [[ "$skip_theming" =~ ^([yY])$ ]]; then
  echo ":: Skipping theme installation"
  echo -e ":: Proceeding to the next step...\n"
else
  echo ":: Installing theme..."
  paru -S --needed "${theming[@]}"
  gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
  gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
  echo -e ":: Done. Proceeding to the next step...\n"
fi

echo ":: Restoring base settings..."
dconf load / <$PWD/base-settings.ini
sleep 3
echo -e ":: Done. Proceeding to the next step...\n"

read -p ":: Skip extensions installation? (y/N): " skip_extensions
skip_extensions=${skip_extensions:-N}
if [[ "$skip_extensions" =~ ^([yY])$ ]]; then
  echo -e ":: Skipping extensions installation"
else
  sudo pacman -S --needed python-pipx
  pipx ensurepath
  pipx install gnome-extensions-cli
  echo ":: Installing extensions..."
  for extension in "${extensions[@]}"; do
    gext install $extension
  done
  echo ":: Restoring extensions settings..."
  dconf load / <$PWD/extensions-settings.ini
  echo ":: Done."
fi

echo ":: Setting up configuration files..."
echo "" && sleep 0.5
sudo systemctl enable greetd.service
sudo cp ./greetd/config.toml /etc/greetd/config.toml
echo ":: Copied $PWD/greetd/config.toml to /etc/greetd/config.toml"
echo "" && sleep 0.5

./symlink.sh $PWD/starship/starship.toml --to-config
echo "" && sleep 0.5
./symlink.sh $PWD/zsh --to-config
echo "" && sleep 0.5
./symlink.sh $PWD/zsh/.zshrc --to-home
echo "" && sleep 0.5

echo -e "\n:: GNOME configuration completed. \n"
