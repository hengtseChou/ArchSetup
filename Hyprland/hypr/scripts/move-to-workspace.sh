#!/bin/bash
focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
if [ "$focused" == "eDP-1" ]; then
    hyprctl dispatch movetoworkspace $1
elif [ "$focused" == "HDMI-A-1" ]; then
    hyprctl dispatch movetoworkspace $(( $1 + 10 ))
elif [ "$focused" == "DP-1" ]; then
    hyprctl dispatch movetoworkspace $(( $1 + 20 ))
elif [ "$focused" == "DP-2" ]; then
    hyprctl dispatch movetoworkspace $(( $1 + 30 ))
fi