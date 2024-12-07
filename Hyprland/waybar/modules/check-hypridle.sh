#!/bin/bash
hypridle=$(pgrep -x hypridle)
if [ -z $hypridle ]; then
  printf '{"text": "", "alt": "deactivated", "tooltip": "deactivated", "class": "deactivated"}'
else
  printf '{"text": "", "alt": "activated", "tooltip": "activated", "class": "activated"}'
fi
