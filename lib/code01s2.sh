#!/usr/bin/env bash
xmodmap ~/metaesc/lib/code01s2.xmodmap
sleep 0.2
killall xcape
sleep 0.2
xcape -e 'Alt_L=Escape;Control_L=Control_R|c;Shift_R=space;Shift_L=Cancel;Super_R=Redo;' -t 240
