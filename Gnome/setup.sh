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
	ulauncher
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

paru -S --needed "${apps[@]}"
