#!/usr/bin/env bash

# utf symbols:http://panmental.de/symbols/info.htm
# https://medium.com/feedium/huge-list-of-unicode-and-emoji-symbols-to-copy-and-paste-df1f408767a6
# ⚖ ⚗ ⚘ ⚙ ⚚ ⚛ ⚜ ⚝ ☭ 𝄆 𝄇 ⌚ ┇ 
brightness_file=/sys/class/backlight/amdgpu_bl0/brightness
prose_file="$HOME/braindump/self/prose.org"
vocab_file="$HOME/braindump/lib/vocab.org"
prose_lines=$(wc -l $prose_file | cut -d " " -f1)
vocab_lines=$(wc -l $vocab_file | cut -d " " -f1)
readarray -t proses < $prose_file
readarray -t vocab < $vocab_file

while true; do
	time=$(date +"%R")
	day=$(date +"%b%d")
	# gpu_mem=$(nvidia-smi 2> /dev/null | grep MiB | tr -sc '0-9M' '\n' | grep M | tr '\n' ' ' 2>/dev/null)
	# echo "$task : ${minutes}m      VOL $audio | GPU ${gpu_mem}"

	power=$(upower -i $(upower -e | grep BAT) | grep percentage | tr -s " " | cut -f 3 -d" ")
	power_value=$(echo $power | cut -d "%" -f1)
	if [ $power_value -lt 50 ]; then
		# zenity --notification --window-icon="info" --text="电量低: $power" --timeout=2
		notify-send -t 500 "电量低: $power"
	fi

	hour=$(date +"%H")
	sec=$(date +"%s")
	if [ "$hour" -ge 21 ]; then 
		line=$((($sec / 120) % $prose_lines))
		# prose=$(head -n $line $prose_file | tail -n 1)
		prose=$(echo ${proses[$line]})
	else
		line=$((($sec / 20) % $vocab_lines))
		prose=$(echo ${vocab[$line]} | cut -d "\"" -f1)
	fi
	# minute=$(date +"%M")
	# if [ $(($minute % 2)) == 0 ]; then
	# 	i3-msg bar mode dock
	# 	sleep 5
	# 	i3-msg bar mode hide 
	# fi

	echo "$prose ┣ ⚡$power ┇ ⌚$time ⚚ $day "
	sleep 2
done

# bright_frac=$(xrandr --verbose | grep -i brightness | head -n 1 | cut -d" " -f2)
# brightness=$(echo "$bright_frac * 100 / 2" | bc)
#audio=$(pactl list sinks | grep -e '^[[:space:]]Volume:' | tr -sc '0-9%' '\n' | grep % -m 1 2>/dev/null)
#┇ 🎶$audio
#┇ 🌟$brightness 
