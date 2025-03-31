#!/usr/bin/env bash
# 用这种方式打开文件比 vim 还好，因为无论在哪个 shell 打开文件，由于连接的都是同一个 emacs server
# 因此会记住文件上次光标所在的位置, 还可以作为 magit 的快速启动脚本
# 在 bashrc 中通过设置以下函数来快速执行：
# ec () {
#    nohup ~/metaesc/lib/popup-emacsclient.sh $@ > /dev/null 2>&1 &
# }



width=100
height=45
window_id=$(xdotool getactivewindow)
# Get the position and size of the window
window_info=$(xdotool getwindowgeometry --shell $window_id)
window_x=$(echo "$window_info" | grep X | cut -d '=' -f 2)
window_y=$(echo "$window_info" | grep Y | cut -d '=' -f 2)
window_width=$(echo "$window_info" | grep WIDTH | cut -d '=' -f 2)
window_height=$(echo "$window_info" | grep HEIGHT | cut -d '=' -f 2)

echo $window_width $window_height $window_x $window_y
# x 是从屏幕左侧开始，y 是从屏幕上边缘开始
center_x=$(($window_x + ($window_width / 2)))
center_y=$(($window_y + ($window_height / 2)))

# 单位转换，width 和 height 是按字符个数的，而 x，y 是像素坐标
# 因为电脑设置的字体大小大约是 10 磅，12 px， 因此要乘以 6 但现实发现乘以 5 比较准
# 因为 bash 算不了浮点，有误差，因此这是经验法则，没必要算太细
x_corner=$(($center_x  - ($width * 5)))
y_corner=$(($center_y  - ($height * 11)))
# echo $x_corner $y_corner >> /tmp/testout
# 如果不是 chome ，直接打开 buffer 到最后一行结尾开始记录
emacsclient "$1" -c -F "((name . \"Floating\") (height . "$height") (width . "$width") (left . "$x_corner") (top . "$y_corner" ) (user-position . t) (menu-bar-lines . 0) )"
