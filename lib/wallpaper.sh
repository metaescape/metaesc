#!/usr/bin/env bash

wallpapers=(/data/resource/pictures/wallpaper-dark/*)
count=$(ls -1q  /data/resource/pictures/wallpaper-dark | wc -l)
ps aux | grep wallpaper.sh | grep -v "grep\|vim\|$$" | awk '{ print $2 }' | xargs kill -9
i=$(($RANDOM % $count))
while true
do
	feh --bg-scale ${wallpapers[$i]} --bg-fill
	i=$(( (i + 1) % $count))
    sleep 600
done
