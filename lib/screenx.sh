#!/usr/bin/env bash
# 查找 videoio/main.py 的进程
PIDS=$(pgrep -f "/data/codes/ranger/screenX/main.py")

if [ -n "$PIDS" ]; then
  # 如果发现已有进程，则杀掉所有相关进程
  kill -9 $PIDS
fi
/home/pipz/miniconda3/envs/usr/bin/python /data/codes/ranger/screenX/main.py &
