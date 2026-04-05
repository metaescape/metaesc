#!/usr/bin/env bash
# 查找 backpages/main.py 的进程
PIDS=$(pgrep -f "/data/codes/ranger/backpages/main.py")

if [ "$1" == "show" ]; then
	i3-msg "workspace t"
    # wmctrl -r :ACTIVE: -b remove,fullscreen
    # ~/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/main.py --show
elif [ "$1" == "uuid" ]; then
	i3-msg "workspace --no-auto-back-and-forth t"
    # ~/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/main.py --uuid $2
    ~/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/ipc.py --uuid $2
else
  if [ -n "$PIDS" ]; then
    # 如果发现已有进程，则杀掉所有相关进程
    kill -9 $PIDS
  fi

  ~/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/main.py &
  notify-send "Backpages Restarted" -t 3000
fi
