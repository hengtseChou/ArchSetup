#!/bin/bash
apps=(
	gnome-browser-connector
	gnome-calculator
	gnome-control-center
	gnome-logs
	gnome-menus
	gnome-screenshot
	gnome-shell
	gnome-terminal
	gnome-text-editor
	polkit-gnome
	xdg-user-dirs-gtk
	nautilus
	sushi
	file-roller
	font-manager
	loupe
)

theming=(
	yaru-gtk-theme
	yaru-icon-theme
)
fonts=(
	ttf-ubuntu-font-family
	ttf-ubuntu-mono-nerd
)

echo ":: Installing apps..."
paru -S --needed "${apps[@]}"
echo ":: Installing fonts..."
paru -S --needed "${fonts[@]}"
read -p ":: Skip theming? (y/N): " skip_theming
skip_theming=${skip_theming:-N}
if [[ "$skip_theming" =~ ^([nN][oO]?|[yY][eE][sS]?)$ ]]; then
	echo ":: Installing theme..."
	paru -S --needed "${theming[@]}"
	gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
	gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
else
	echo ":: Skipping theme installation."
fi
echo ":: Restoring base settings..."
dconf load / <$PWD/base-settings.ini

extensions=(
	AlphabeticalAppGrid@stuarthayhurst
	blur-my-shell@aunetx
	burn-my-windows@schneegans.github.com
	caffeine@patapon.info
	clipboard-indicator@tudmotu.com
	dash-to-dock@micxgx.gmail.com
	kimpanel@kde.org
)

if ! command -v gext 2>&1 >/dev/null; then
	echo ":: Error: gnome-extensions-cli is not installed. Skipping install extensions."
	exit 1
else
	echo ":: Installing extensions..."
	for extension in "${extensions[@]}"; do
		gext install $extension
	done
fi