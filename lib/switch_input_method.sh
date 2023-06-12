#!/usr/bin/env bash

<< comment
在非 emacs 窗口中，发送 ibus 命令切换输入法，否则发送对应按键到 emacs 中切换输入法的方法
comment

focus_win=$(xprop -id $(xdotool getactivewindow) | grep WM_CLASS | cut -d'"' -f4)
 if [[ $focus_win =~ 'Emacs' ]]; then
	 # emacsclient --eval 切换不到
	 xdotool key alt+plus #switch in emacs
 else
	current_engine=$(ibus engine)
	# Check if the current engine is rime
	if [ "$current_engine" == "rime" ]; then
		# Set the IBus engine to xkb:us::eng
		ibus engine xkb:us::eng
	else
		# Set the IBus engine to rime
		ibus engine rime
	fi
fi
