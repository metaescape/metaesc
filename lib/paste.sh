#!/usr/bin/env bash
var1=$1
focus_win=$(xprop -id $(xdotool getactivewindow) | grep WM_CLASS | cut -d'"' -f2)
if [[ "$var1" == 'c' ]]; then
	timestamp=$(date +"%Y/%m/%d-%R")
	if [[ $focus_win =~ 'emacs' || $focus_win =~ 'gnome-terminal' ]]; then
		sleep 0.2
		xdotool key --clearmodifiers y
		sleep 0.1
		content=$(xclip -selection c -o)
		from=$(xprop -id $(xdotool getactivewindow) | egrep "^WM_NAME" | cut -d'"' -f2)
	elif [[ $focus_win =~ 'chrome' ]]; then
		notify-send 'copied from chrome' -t 1000
		sleep 0.2
		xdotool key --clearmodifiers ctrl+c
		sleep 0.1
		content=$(xclip -selection c -o)
		xdotool key Y
		sleep 0.1
		from=$(xclip -selection c -o)
	fi
	# echo "${content} \"$timestamp : ${from}\"" >> ~/braindump/lib/vocab.org
	# could use xprop to get WM_NAME for source refile
#WM_NAME(UTF8_STRING) = "ubuntu clipboard manager with i3wm - Google 搜索 - Google Chrome"
elif [[ "$var1" == 'v' ]]; then
	sleep 0.2
	if [[ $focus_win =~ 'gnome-terminal' ]]; then
	    xdotool key --clearmodifiers ctrl+V
	elif [[ $focus_win =~ 'urxvt' ]]; then
	    xdotool key --clearmodifiers ctrl+alt+v
    else
	    xdotool key --clearmodifiers ctrl+v
    fi
fi
