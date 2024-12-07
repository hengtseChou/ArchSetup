#!/bin/bash
if [ -z $(pidof waybar) ]; then
	waybar -c $HYPRCONF/waybar/config -s $HYPRCONF/waybar/style.css &
else
	pkill waybar
fi
