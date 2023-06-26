#!/bin/sh
if [ $(hostname) != "code01" ]; then
xrandr --output DVI-I-0 --off --output DVI-I-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-0 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off --output VGA-1-1 --mode 1600x900 --pos 1920x0 --rotate left --output DP-1-1 --off --output HDMI-1-1 --off --output DP-1-2 --off --output HDMI-1-2 --off
fi
