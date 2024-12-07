#!/bin/bash
hypridle=$(pgrep -x hypridle)
if [ -z $hypridle ]; then
    hypridle &
else
    pkill hypridle
fi