#!/usr/bin/env bash
# 查找 backpages/main.py 的进程
PIDS=$(pgrep -f "/data/codes/ranger/backpages/main.py")

if [ "$1" == "show" ]; then
    ~/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/main.py --show
else
  if [ -n "$PIDS" ]; then
    # 如果发现已有进程，则杀掉所有相关进程
    kill -9 $PIDS
  fi

  ~/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/main.py &
  notify-send "Backpages Restarted" -t 3000
fi
