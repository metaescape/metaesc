#!/usr/bin/env bash
xmodmap ~/myconf/keyboards/code01s2.xmodmap
sleep 0.2
killall xcape
sleep 0.2
xcape -e 'Shift_L=Control_R|Alt_L|Shift_R|l;Alt_L=Escape;Control_L=Control_R|c;Super_R=Control_R|Alt_L|Shift_R|i;Control_R=Menu' -t 300
