#!/bin/bash
set -e

monitors=$(echo "$(hyprctl monitors -j)" | jq length)
if [ $monitors -eq 1 ]; then
    echo "No external monitor used. Exiting"
    exit 0
fi

workspaces=($(echo "$(hyprctl workspaces -j)" | jq -r '.[] | .id'))
for workspace in "${workspaces[@]}"; do
    hyprctl dispatch moveworkspacetomonitor $workspace current > /dev/null
done
echo "Workspaces moved: $workspaces."
