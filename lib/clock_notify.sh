#!/usr/bin/env bash

# Script: clock_notify.sh
# Description: This script provides periodic notifications for battery level and time.
# It first terminates any existing instances of itself to avoid duplicates.
# Then, it enters an infinite loop, where it performs two main functions:
# 1. Battery Check: Every 30 seconds, checks the battery level. If the battery level is below 50%,
#    it displays a notification for 2 seconds indicating "Low Battery" along with the current percentage.
# 2. Time Notification: Also every 30 seconds, checks if the current minute is a multiple of 10.
#    If so, it displays the current time in a notification that lasts for 5 seconds.
# Usage: Run the script in the background for continuous notifications. 
#        Example: ./clock_notify.sh &
#        started by i3wm, a simple server for low power notification
# Dependencies: Requires 'upower' for battery status and 'notify-send' for sending notifications.

ps aux | grep clock_notify.sh | grep -v "grep\|vim\|$$" | awk '{ print $2 }' | xargs kill 2>/dev/null

while true; do
    time=$(date +"%R")
    minute=$(date +"%M")
    power=$(upower -i $(upower -e | grep BAT) | grep percentage | tr -s " " | cut -f 3 -d" ")
    power_value=$(echo $power | cut -d "%" -f1)
    if [ $power_value -lt 30 ]; then
        notify-send -t 2000 "电量低: $power"
    fi

    if [ $((10#$minute % 10)) == 0 ]; then
        notify-send --icon=user-idle-panel -t 5000 "⌚$time"
    fi
    sleep 30
done
