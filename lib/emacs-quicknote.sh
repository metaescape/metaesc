#!/usr/bin/env bash

# 打开 emacs journal 并写入内容，不需要窗口
emacsclient -a "" --eval "(let* ((files (directory-files \"~/org/self/journal/\" t \"^j\" t))
         (latest-file (car (sort files 'string>))))
    (with-current-buffer (find-file-noselect latest-file)
      (goto-char (point-max))
      (unless (bolp) (insert \"\n\"))
      (insert (format-time-string \"=%H:%M= \"))
      (insert \"$@\")
      (save-buffer)))"
 # (evil-paste-after 1)
