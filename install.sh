#!/bin/bash
gnome=true
hypr=true
conf=true
scripts=true

_usage() {
  echo "Usage: ./install.sh [options]"
  echo "Options:"
  echo "  --skip-gnome      Skip GNOME apps and settings"
  echo "  --skip-hypr       Skip Hyprland apps and settings"
  echo "  --skip-conf       Skip app config files"
  echo "  --skip-scripts    Skip cloning scripts"
}

for arg in "$@"; do
  case $arg in
  --skip-gnome)
    gnome=false
    shift
    ;;
  --skip-hypr)
    hypr=false
    shift
    ;;
  --skip-conf)
    conf=false
    shift
    ;;
  --skip-scripts)
    scripts=false
    shift
    ;;
  --help)
    _usage
    exit 0
    ;;
  *)
    echo "Unknown option: $arg"
    _usage
    exit 1
    ;;
  esac
done

# install aur helper
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru

if $gnome; then
  echo ":: Setting up GNOME..."
  cd Gnome && ./setup.sh && cd ..
  echo ":: Done."
fi
if $hypr; then
  echo ":: Setting up Hyprland..."
  cd Hypr && ./setup.sh && cd ..
  echo ":: Done."
fi
echo ":: Installing standalone apps..."
cd Standalone && ./setup.sh && cd ..
echo ":: Done."
if $conf; then
  echo ":: Applying app config files..."
  cd Conf && ./setup.sh && cd ..
  echo ":: Done."
fi
if $scripts; then
  echo ":: Cloning scripts into Home folder..."
  git clone https://github.com/hengtseChou/Scripts.git ~/Scripts
  echo ":: Done."
fi
