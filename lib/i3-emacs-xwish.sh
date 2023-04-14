#!/usr/bin/env bash

# 本脚本主要目的是通过 emacs 进行窗口切换，启动等操作，从 ivy 显示窗口列表：
# - enter 直接切换到目标窗口
# - M-o x 结束当前窗口
# - M-o k kill -9 当前进程
# - M-o s 当前窗口与 ivy 选择窗口进行交换 swap
# - M-o e 弹出新的 ivy 选择一个 app 启动到当前窗口
#   - 如果当前窗口是 nil （说明是当前的空的 workspace, 那么就在当前窗口启动）
#   - 如果当前窗口是有其他进程的 app，则先和该窗口里的 app 交换，然后 kill 掉交换的 app


focus_win_class=$(xprop -id $(xdotool getactivewindow) | grep WM_CLASS | cut -d'"' -f2)
focus_win_name=$(xprop -id $(xdotool getactivewindow) | grep WM_NAME\(STRING\) | cut -d'"' -f2)
focus_wid=$(printf 0x%08x $(xdotool getactivewindow))

if [[ $focus_win_name =~ 'EmacsAnywhere' ]]; then
	# emacsclient --eval "(minibuffer-keyboard-quit)"
	xdotool key Escape #send ESC to 
	i3-msg kill
else
	~/metaesc/lib/restore_fullscreen.sh

	width=72
	height=12
	window_id=$(xdotool getactivewindow)

	# Get the position and size of the window
	window_info=$(xdotool getwindowgeometry --shell $window_id)
	window_x=$(echo "$window_info" | grep X | cut -d '=' -f 2)
	window_y=$(echo "$window_info" | grep Y | cut -d '=' -f 2)
	window_width=$(echo "$window_info" | grep WIDTH | cut -d '=' -f 2)
	window_height=$(echo "$window_info" | grep HEIGHT | cut -d '=' -f 2)

	# x 是从屏幕左侧开始，y 是从屏幕上边缘开始
	center_x=$(($window_x + ($window_width / 2)))
	center_y=$(($window_y + ($window_height / 2)))
	
	# 单位转换，width 和 height 是按字符个数的，而 x，y 是像素坐标
	# 因为电脑设置的字体大小大约是 10 磅，12 px， 因此要乘以 6 但现实发现乘以 5 比较准
	# 因为 bash 算不了浮点，有误差，因此这是经验法则，没必要算太细
	x_corner=$(($center_x  - ($width * 5)))
	y_corner=$(($center_y  - ($height * 9)))
	# echo $x_corner $y_corner >> /tmp/testout
	emacsclient -a "" -n -c -F "((name . \"EmacsAnywhere\") (height . "$height") (width . "$width") (left . "$x_corner") (top . "$y_corner" ) (user-position . t) (menu-bar-lines . 0) (alpha . (98 . 90)) (minibuffer . only))" --eval "(progn (let ((debug-file \"/tmp/ivy-xwish.el\")) (when (file-exists-p debug-file) (load-file debug-file))) (list-xwindows-ivy \"$focus_wid\"))" 
fi

