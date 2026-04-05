#!/usr/bin/env bash

width=80
height=40
# 单位转换，width 和 height 是按字符个数的，而 x，y 是像素坐标
# 因为电脑设置的字体大小大约是 10 磅，12 px， 因此要乘以 6 但现实发现乘以 5 比较准
# 因为 bash 算不了浮点，有误差，因此这是经验法则，没必要算太细
x_corner=-10
y_corner=30
FRAME_NAME="Floating Layergraph Emacsclient"

# 每次创建新的 frame
# emacsclient -c -F "((name . \"$FRAME_NAME\") (height . $height) (width . $width) (left . $x_corner) (top . $y_corner ) (user-position . t) (menu-bar-lines . 0) )" --eval "(progn (find-file \"$1\") (end-of-buffer) (search-backward \"$2\" nil t) (next-line))"

# 复用 frame
# emacsclient -e "(let ((existing-frame (catch 'found
#                          (dolist (f (frame-list))
#                            (if (string= (frame-parameter f 'name) \"$FRAME_NAME\")
#                                (throw 'found f))))))
#   (if existing-frame
#       (select-frame-set-input-focus existing-frame)
#     (make-frame '((name . \"$FRAME_NAME\") 
#                   (height . $height) 
#                   (width . $width) 
#                   (left . $x_corner) 
#                   (top . $y_corner) 
#                   (user-position . t) 
# 			      (vertical-scroll-bars . nil)
#                   (horizontal-scroll-bars . nil)
#                   (menu-bar-lines . 0)))))" \
# --eval "(let ((buf (find-file-noselect \"$1\")))
#           (set-window-buffer (selected-window) buf)
#           (with-current-buffer buf
#             (goto-char (point-max))
#             (when (search-backward \"$2\" nil t)
#
emacsclient -s server -e "(let* ((frame-name \"$FRAME_NAME\")
               ;; 1. 寻找或创建 Frame
               (f (or (catch 'found
                        (dolist (frame (frame-list))
                          (if (string= (frame-parameter frame 'name) frame-name)
                              (throw 'found frame))))
                      (make-frame '((name . \"$FRAME_NAME\")
                                    (height . $height)
                                    (width . $width)
                                    (left . $x_corner)
                                    (top . $y_corner)
                                    (vertical-scroll-bars . nil)
                                    (menu-bar-lines . 0)))))
               ;; 2. 准备 Buffer (使用 noselect 避免自动跳转)
               (buf (find-file-noselect \"$1\"))
               ;; 3. 核心：强制在该 Frame 的窗口中设置 Buffer
               (win (frame-selected-window f)))
          
          (select-frame-set-input-focus f)
          (set-window-buffer win buf)
          
          ;; 4. 在该 Buffer 内部进行跳转
          (with-current-buffer buf
            (goto-char (point-max))
            (when (search-backward \"$2\" nil t)
              (forward-line 1)
			  (org-show-entry)
			  (recenter)
			  ))
          
          ;; 返回结果，避免在终端打印长字符串
          nil)"
