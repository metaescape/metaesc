#!/usr/bin/env bash
xmodmap ~/metaesc/lib/code01s1.xmodmap
sleep 0.2
killall xcape
sleep 0.2
xcape -e 'Alt_L=Escape;Control_L=Control_R|c;Shift_L=space;Super_L=Cancel;Super_R=Redo;Hyper_R=Control_R|Alt_L|f' -t 240
