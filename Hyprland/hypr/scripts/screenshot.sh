#!/bin/bash
#  ____                               _           _
# / ___|  ___ _ __ ___  ___ _ __  ___| |__   ___ | |_
# \___ \ / __| '__/ _ \/ _ \ '_ \/ __| '_ \ / _ \| __|
#  ___) | (__| | |  __/  __/ | | \__ \ | | | (_) | |_
# |____/ \___|_|  \___|\___|_| |_|___/_| |_|\___/ \__|
#
mode="$1"

export HYPRSHOT_DIR="$HOME/Pictures/Screenshots"
NAME="Screenshot from $(date "+%Y-%m-%d %H-%M-%S").png"

if [ "$mode" == "region" ]; then
    hyprshot -m region -f "$NAME"
elif [ "$mode" == "window" ]; then
    hyprshot -m window -f "$NAME"
elif [ "$mode" == "output" ]; then
    hyprshot -m output -f "$NAME"
fi
