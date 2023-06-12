#!/usr/bin/env bash
xmodmap ~/myconf/keyboards/code01s4.xmodmap
sleep 0.2
killall xcape
sleep 0.2
xcape -e 'Alt_L=Escape;Control_L=Control_R|c;Super_L=Control_R|Alt_L|Shift_R|l;Super_R=Control_R|Alt_L|Shift_R|i;Hyper_R=Control_R|Alt_L|Shift_R|f' -t 240
