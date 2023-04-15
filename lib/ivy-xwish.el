;; 会影响 app launcher, 因为会退出一次
;; (add-hook 'minibuffer-exit-hook 'delete-frame)
(global-set-key (kbd "<escape>") 'delete-frame)

;; (defun my-minibuffer-setup-hook ()
;;   (setq-local keyboard-escape-quit 'delete-frame))

;; (add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

(defun search-key-in-nested-list (lst item idx)
  (if (null lst)
      nil
    (if (string-equal (nth idx (car lst)) item)
        (car lst)
      (search-key-in-nested-list (cdr lst) item idx))))

(defun list-xwindows-ivy (&optional last-win-id)
  (interactive)
  (let* ((lines (split-string (shell-command-to-string "wmctrl -l") "\n" t))
         ;; (windows (mapcar (lambda (line)
         ;;                    (when (string-match "^\\(0x[0-9a-f]+\\) +[^ ]+ +\\([^ ]+\\) +\\(.*\\)" line)
         ;;                      (list (match-string 3 line) (match-string 1 line))))
         ;;                  lines))
         (windows (mapcar (lambda (line)
                            (when (string-match "^\\(0x[0-9a-f]+\\) +\\([0-9]+\\) +[^ ]+ +\\(.*\\)" line)
                              (list (format "%s: %s (%s) "
                                            (1+ (string-to-number (match-string 2 line)))
                                            (match-string 3 line)
                                            (match-string 1 line)
                                            )
                                    (match-string 1 line))))
                          lines))

         (filtered-windows (delq nil windows))
         (preselect (if last-win-id
                        (search-key-in-nested-list filtered-windows last-win-id 1) nil))
         )
    (ivy-read "XWin: " filtered-windows
              :action '(1
                        ("o" (lambda (selected)
                               (shell-command (concat "wmctrl -ia " (cadr selected))))
                         "切换到选中窗口")
                        ("x" (lambda (selected)
                               (shell-command (concat "wmctrl -ic " (cadr selected))))
                         "kill window")
                        ("s" (lambda (selected)
                               (shell-command (format "i3-msg \"[id=%s] swap container with id %s\""
                                                      (cadr selected)
                                                      last-win-id)))
                         "选中窗口与当前窗口交换")
                        ("k" (lambda (selected)
                               (shell-command (format "kill -9 $(xdotool getwindowpid %s)" (cadr selected))))
                         "kill -9 window")
                        ("e" (lambda (selected)
                               (launch-swap-and-kill selected))
                         "select a app to substitute current window")
                        )
              :preselect (car preselect)
              )
    (delete-frame)
    ))


(defun launch-swap-and-kill (selected)
  (let* ((wid (cadr selected))
         (appname (ivy-launch-apps)) ;; new app name
         (newapp-id (detect-window-number-change)) ;; new app id
         (newapp-name (call-bash-function-and-get-output (format "get-window-name-by-id %s" newapp-id))))
    (message wid)
    (message newapp-id)
    (message newapp-name)
    (shell-command (format "i3-msg \"[id=%s] swap container with id %s\"" wid newapp-id))
    (shell-command (concat "wmctrl -ic " wid)))
  )

(defun ivy-launch-apps ()
  "Launch an AppImage file selected by the user from ~/Downloads in the background and detach it from the shell."
  (interactive)
  (let* ((downloads-dir (expand-file-name "~/Downloads"))
         (apps (find-all-apps)))
    (ivy-read "Select an AppImage to launch: " apps
              :action (lambda (choice)
                        (let* ((process-connection-type nil)
                               (process (start-process
                                         "apps-background-process" nil "sh" "-c"
                                         (format "nohup %s > /dev/null 2>&1 & disown" (shell-quote-argument choice))
                                         )))
                          (process-id process)))
              :caller 'launch-appimage)))

(defun find-all-apps ()
  "Find all executables in the directories specified in the system's PATH."
  (let* ((path-dirs (split-string (getenv "PATH") path-separator))
         (downloads-dir (expand-file-name "~/Downloads"))
         (appimages (split-string (shell-command-to-string (format "find %s -name '*.AppImage'" downloads-dir)) "\n" t))
         executables)
    (dolist (dir path-dirs)
      (when (file-directory-p dir)
        (let ((files (directory-files dir nil nil t)))
          (dolist (file files)
            (let ((file-path (expand-file-name file dir)))
              (when (and (file-executable-p file-path)
                         (not (string-prefix-p "." file)))
                (push file executables)))))))
    (append appimages (delete-dups executables))))


(defun call-bash-function-and-get-output (function-name-arg)
  "Call a function defined in a Bash script and return its output as a string."
  (let ((script (concat (if load-file-name
                            (file-name-directory load-file-name)
                          "~/metaesc/lib/") "utils.sh")))
    (with-output-to-string
      (call-process-shell-command (format "source %s && %s" script function-name-arg) nil standard-output)
      )))


(defun detect-window-number-change ()
  "Detect changes in the number of windows in the current Xorg workspace every half second.
Returns the ID of the new window created, or nil if no window was created."
  (let ((window-count (get-window-count))
        (new-window-id nil)
        (counter 0))
    (while (and (not new-window-id) (< counter 8))
      (sleep-for 0.5) ; Wait half a second
      (setq counter (+ counter 1))
      (when (not (equal window-count (get-window-count)))
        (setq new-window-id (get-new-window-id))
        (message "New window detected: %s" new-window-id)))
    new-window-id))

(defun get-window-count ()
  "Get the number of windows in the current Xorg workspace."
  (length (remove "" (split-string (shell-command-to-string "wmctrl -l") "\n"))))

(defun get-new-window-id ()
  "Get the ID of the most recently created window in the current Xorg workspace."
  (call-bash-function-and-get-output "newest_process_winid"))
