#!/usr/bin/env bash

PIDS=$(pgrep -f "Clash/cfw")

if [ -n "$PIDS" ]; then
  # 如果发现已有进程，pass
  notify-send "🐱 CFWis already running, pass" -a CFW -t 3000
else # start cfw
  ~/.local/Clash/cfw
fi
