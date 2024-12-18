#!/usr/bin/env bash

<< comment
用 F10 作为快捷键(i3 中设置)，检测到当前是 chrome 浏览器的话，直接发送 Y 键复制链接（sufingkey 配合），
之后弹出 emacs 悬浮窗口打开文件跳到文件最后一行，将内容复制到 org 文件中，换行，进入 evil-insert-status 等待输入一些描述，再按 F10 则关闭 emacsclient 窗口
如果是在 emacs 窗口但是不是 popup 窗口, 那么 f10 是打开 agenda

1. 找到 emacsclient, 在编译后的 lib-src 目录中, 或直接在环境变量中
2. 设置 i3 使得 emacs 作为 popup window
   for_window [title="^Floating"] floating enable
3. 编写脚本判断是否在 chrome, 是则发送 Y 按键
4. 发送完后调用 emacsclient 打开特定 org 文件，跳到最后一行，调用粘贴
5. 绑定 i3 按键 F10 激活该脚
   bindsym F10 --release exec current_script
   需要 release 否则会无法释放掉
6. emacs 中新增 switch-to-agenda-or-cycle 函数绑定成 s-F10, 防止 xdotool 发按键给 i3 无限循环
7. 把 rime 设置成默认英文
   ~/.config/ibus/rime/pinyin.schema.yaml 中 switches 设置，一直没有搞清楚是怎么设置的？
   以下是可以的
   #+begin_src conf
   switches:
   - name: ascii_mode
     reset: 0 # en
     states: [中文,西文]
   - name: full_shape
     states: [全角,半角]
   #+end_src
8. 识别当前窗口的坐标，将 popup 窗口定位到当前窗口的中心
   ~xdotool getactivewindow getwindowgeometry~
   获得坐标和像素范围，然后计算出中心
comment

focus_win_class=$(xprop -id $(xdotool getactivewindow) | grep WM_CLASS | cut -d'"' -f2)
focus_win_name=$(xprop -id $(xdotool getactivewindow) | grep WM_NAME\(STRING\) | cut -d'"' -f2)
if [[ $focus_win_name =~ 'Floating' ]]; then
	i3-msg kill
elif [[ $focus_win_class =~ 'emacs' ]]; then
	# 以下命令会执行失败
	# emacsclient -e "(cycle-tasks-in-agenda)"
	# 所以还是不用 emacsclient 的方式来做轮询，因为 emacsclient 无法获得 server 里打开
	# 的buffer 的丰富信息
	# emacsclient -e "(switch-to-agenda-or-cycle)"
	# 改用发送按键的方式
	# echo "Processing F10 key... 检测死循环" >> /tmp/testout
	# xdotool key F10 #send F10 to emacs window to cycle agenda，触发了死循环
	# 必须修改 emacs 中 agenda cycle 按键
	xdotool key super+F10
elif [[ $focus_win_class =~ 'Vcode' ]]; then
	# 如果当前是 vscode 窗口，那么用 emacsclient 打开当前文件, 目前注释掉
	# VS code setting
	# “window.title”: “${activeEditorLong}${separator}${rootName}”,
	# How To:
	# Open Settings: hit: Command+ ,
	# Search for “title”
	# In the input replace activeEditorShort with activeEditorLong
	# Save.
	sleep 0.01
	~/metaesc/lib/restore_fullscreen.sh

	window_id=$(xdotool getactivewindow)

	# Get the position and size of the window
	window_info=$(xdotool getwindowgeometry --shell $window_id)
	window_x=$(echo "$window_info" | grep X | cut -d '=' -f 2)
	window_y=$(echo "$window_info" | grep Y | cut -d '=' -f 2)
	window_width=$(echo "$window_info" | grep WIDTH | cut -d '=' -f 2)
	window_height=$(echo "$window_info" | grep HEIGHT | cut -d '=' -f 2)

	width=$window_width
	height=$window_height

	# 获取窗口名称
	WINDOW_NAME=$(xprop -id $window_id WM_NAME)

	# 提取文件路径（假设窗口名称格式为 "<filename> - <directory> - Visual Studio Code"）
	FILE_PATH=$(echo $WINDOW_NAME | awk -F '"' '{print $2}' | awk -F ' - ' '{print $1}')

	# x 是从屏幕左侧开始，y 是从屏幕上边缘开始
	center_x=$(($window_x + ($window_width / 2)))
	# 放在稍微靠下的位置
	center_y=$(($window_y + ($window_height * 2 /4)))
	
	x_corner=$(($center_x  - ($width * 5)))
	y_corner=$(($center_y  - ($height * 5)))
	emacsclient -a "" -c -F "((name . \"Floating\") (height . "$height") (width . "$width") (left . "$x_corner") (top . "$y_corner" ) (user-position . t) (menu-bar-lines . 0) )" \
		--eval "(progn (set-frame-parameter (selected-frame) 'alpha '(96 . 90)) (find-file \"$FILE_PATH\"))"
else
	sleep 0.01
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
	# 放在稍微靠下的位置
	center_y=$(($window_y + ($window_height * 2 /4)))
	
	# 单位转换，width 和 height 是按字符个数的，而 x，y 是像素坐标
	# 因为电脑设置的字体大小大约是 10 磅，12 px， 因此要乘以 6 但现实发现乘以 5 比较准
	# 因为 bash 算不了浮点，有误差，因此这是经验法则，没必要算太细
	x_corner=$(($center_x  - ($width * 5)))
	y_corner=$(($center_y  - ($height * 5)))
	# echo $x_corner $y_corner >> /tmp/testout
	# if [[ $focus_win_class =~ 'google-chrome' ]]; then
	# 	xdotool key Escape "Y"
	# 	sleep 0.01
	# 	emacsclient -a "" -c -F "((name . \"Floating\") (height . "$height") (width . "$width") (left . "$x_corner") (top . "$y_corner" ) (user-position . t) (menu-bar-lines . 0) )" --eval "(progn (set-frame-parameter (selected-frame) 'alpha '(98 . 90)) (find-file \"~/org/self/journal/j2023.org\") (end-of-buffer) (insert-time) (insert (format \"%s \" (current-kill 0 t))) (evil-insert-state) )"
	# else
	# 先复制，再粘贴到 buffer 最后一行结尾
    ~/metaesc/lib/paste.sh c
	emacsclient -a "" -c -F "((name . \"Floating\") (height . "$height") (width . "$width") (left . "$x_corner") (top . "$y_corner" ) (user-position . t) (menu-bar-lines . 0) )" \
	--eval "(progn (set-frame-parameter (selected-frame) 'alpha '(98 . 90)) (find-file (car (sort (directory-files \"~/org/self/journal/\" t \"^j\" t) 'string>))) (end-of-buffer) (evil-insert-state) (my/insert-time) (insert \"Anki:\") (evil-paste-after 1))"
	# fi
fi
