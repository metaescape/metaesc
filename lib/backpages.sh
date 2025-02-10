#!/usr/bin/env bash
# 查找 backpages/main.py 的进程
PIDS=$(pgrep -f "/data/codes/ranger/backpages/main.py")

if [ -n "$PIDS" ]; then
  # 如果发现已有进程，则杀掉所有相关进程
  kill -9 $PIDS
else
  # 否则启动新进程
  /home/pipz/miniconda3/envs/usr/bin/python /data/codes/ranger/backpages/main.py &
fi
