#!/usr/bin/env bash
xmodmap ~/metaesc/lib/code01.xmodmap 
killall xcape
notify-send "Keymap: default" -t 3000
