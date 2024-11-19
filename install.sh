#!/bin/bash
setup_dir="$PWD"

echo -e "\n----- Arch setup script -----\n"
submodule_status=$(git submodule status)
if echo "$submodule_status" | grep -q '^-'; then
  echo ":: Initializing submodules..."
  git submodule update --init --recursive
fi

if ! command -v paru 2>&1 >/dev/null; then
  read -p ":: Error: paru is not install. Would you like to install? (Y/n): " install_paru
  install_paru=${install_paru:-Y}
  if [[ "$install_paru" =~ ^[Yy]$ ]]; then
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
    echo -e ":: Done. Proceeding to the next step...\n"
  else
    echo "Exiting."
    exit 1
  fi
fi

display_options() {
  echo ":: Pick one or more DE/WM with pre-configured setup:"
  echo "     1) GNOME"
  echo "     2) Hyprland"
  echo "     3) Niri"
}

validate_input() {
  for choice in $selection; do
    if ! [[ "$choice" =~ ^[1-3]$ ]]; then
      echo ":: Invalid input. Please try again."
      return 1
    fi
  done
  return 0
}

while true; do
  display_options
  read -p ":: Enter a selection (default=1): " selection

  if [[ -z "$selection" ]]; then
    selection="1"
  fi

  if validate_input; then
    break
  fi
done

for choice in $selection; do
  case $choice in
  1)
    cp -r "$setup_dir/Gnome" $HOME
    cd $HOME/Gnome
    ./setup.sh
    cd $setup_dir
    ;;
  2)
    cp -r "$setup_dir/Hypr" $HOME
    cd $HOME/Hypr
    ./setup.sh
    cd $setup_dir
    ;;
  3)
    cp -r "$setup_dir/Niri" $HOME
    cd $HOME/Niri
    ./setup.sh
    cd $setup_dir
    ;;
  esac
done

read -p ":: Would you like to install standalone apps? (Y/n): " standalone
standalone=${standalone:-Y}
if [[ "$standalone" =~ ^[Yy]$ ]]; then
  cd Standalone && ./setup.sh && cd ..
else
  echo -e ":: Skipping standalone apps installation\n"
fi
cd Conf && ./setup.sh && cd ..

read -p ":: Finally, would you like to install some useful scripts? (Y/n): " scripts
scripts=${scripts:-Y}
if [[ "$scripts" =~ ^[Yy]$ ]]; then
  git clone https://github.com/hengtseChou/Scripts.git ~/Scripts
else
  echo -e ":: Skipping scripts installation\n"
fi

echo ":: All Done!"
echo ":: Please reboot your system to apply changes."
echo ":: Exiting..."
echo ""
exit 0
