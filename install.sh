#!/bin/bash
gnome=true
hypr=true
conf=true
scripts=true

_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --skip-gnome: Skip GNOME apps and settings"
    echo "  --skip-hypr: Skip Hyprland apps and settings"
    echo "  --skip-conf: Skip app config files"
    echo "  --skip-scripts: Skip cloning scripts"
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
        _help
        exit 0
        ;;
    *)
        echo "Unknown option: $arg"
        _help
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
    ./Gnome/setup.sh
fi
if $hypr; then
    ./Hypr/setup.sh
fi
./Standalone/setup.sh
if $conf; then
    ./Conf/setup.sh
fi
if $scripts; then
    git clone https://github.com/hengtseChou/Scripts.git ~/Scripts
fi


