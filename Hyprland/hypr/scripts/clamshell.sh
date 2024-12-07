#!/usr/bin/env zsh
if [[ "$(hyprctl monitors)" =~ "\sDP-[0-9]+" || "$(hyprctl monitors)" =~ "HDMI-A-1" ]]; then
  if [[ $1 == "on" ]]; then
    hyprctl keyword monitor "eDP-1,disable"
  else
    hyprctl keyword monitor "eDP-1,2880x1800,0x0,1.5"
  fi
fi
