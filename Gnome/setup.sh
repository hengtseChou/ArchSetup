#!/bin/bash
apps=(
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
	xdg-user-dirs-gtk
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
	grand-theft-focus@zalckos.github.com
	kimpanel@kde.org
)

read -p ":: Skip extensions install? (y/N): " skip_extensions
skip_extensions=${skip_extensions:-N}
if [[ "$skip_extensions" =~ ^([nN][oO]?|[yY][eE][sS]?)$ ]]; then
	sudo pacman -S --needed python-pipx --noconfirm
	pipx ensurepath
	pipx install gnome-extensions-cli
	echo ":: Installing extensions..."
	for extension in "${extensions[@]}"; do
		gext install $extension
	done
	echo ":: Restoring extensions settings..."
	dconf load / <$PWD/extensions-settings.ini
	fi
else
	echo ":: Skipping extensions install."
fi