#!/usr/bin/env bash

<< comment
该脚本功能是，打开之后弹出 emacsclient 悬浮窗口，进入到 hugchange 目录执行 ./pub.sh p 命令发布 blog

1. 找到 emacsclient, 在编译后的 lib-src 目录中, 或直接在环境变量中
2. 设置 i3 使得 emacs 作为 popup window
   for_window [title="^Floating$"] floating enable
3. 识别当前窗口的坐标，将 popup 窗口定位到当前窗口的中心
   ~xdotool getactivewindow getwindowgeometry~
   获得坐标和像素范围，然后计算出中心

4. 启动 shell 并计入到 ~/codes/hugchangelife, 执行 ./pub.sh p
comment

focus_win_class=$(xprop -id $(xdotool getactivewindow) | grep WM_CLASS | cut -d'"' -f2)
focus_win_name=$(xprop -id $(xdotool getactivewindow) | grep WM_NAME\(STRING\) | cut -d'"' -f2)
if [[ $focus_win_name =~ 'Floating' ]]; then 
  if [[ $focus_win_class =~ 'emacs' ]]; then
	i3-msg kill
  else
	# send ESC 
	xdotool key Escape
  fi
else
	sleep 0.01
	~/metaesc/lib/restore_fullscreen.sh

	width=72
	height=32
	window_id=$(xdotool getactivewindow)

	# Get the position and size of the window
	window_info=$(xdotool getwindowgeometry --shell $window_id)
	window_x=$(echo "$window_info" | grep X | cut -d '=' -f 2)
	window_y=$(echo "$window_info" | grep Y | cut -d '=' -f 2)
	window_width=$(echo "$window_info" | grep WIDTH | cut -d '=' -f 2)
	window_height=$(echo "$window_info" | grep HEIGHT | cut -d '=' -f 2)

	# x 是从屏幕左侧开始，y 是从屏幕上边缘开始
	center_x=$(($window_x + ($window_width / 2)))
	# 放在稍微靠下的位置
	center_y=$(($window_y + ($window_height * 2)))
	
	# 单位转换，width 和 height 是按字符个数的，而 x，y 是像素坐标
	# 因为电脑设置的字体大小大约是 10 磅，12 px， 因此要乘以 6 但现实发现乘以 5 比较准
	# 因为 bash 算不了浮点，有误差，因此这是经验法则，没必要算太细
	x_corner=$(($center_x  - ($width * 5)))
	y_corner=$(($center_y  - ($height * 5)))
	# else
	emacsclient -a "" -c -F "((name . \"Floating\") (height . "$height") (width . "$width") (left . "$x_corner") (top . "$y_corner" ) (user-position . t) (menu-bar-lines . 0) )" --eval "(progn (set-frame-parameter (selected-frame) 'alpha '(98 . 90)) (shell) (end-of-buffer) (evil-insert-state) (comint-send-string nil \"cd ~/codes/hugchangelife\n\")  (comint-send-string nil \"./pub.sh p\n\"))"
	# fi
fi
