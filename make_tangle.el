;; (require 'package)
;; (setq package-user-dir "~/.wemacs/elpa")
;; (package-initialize)
(require 'find-lisp)
(require 'org)
(require 'org-id)
(require 'ob-tangle)
(setq org-id-locations-file "~/.wemacs/.org-id-locations")
(setq org-confirm-babel-evaluate nil
      org-src-preserve-indentation t)
(org-babel-do-load-languages
 'org-babel-load-languages '((org . t) (shell . t))
 )

(setq org-babel-default-header-args '((:comments . "noweb")))

;; org-id-link-to-org-use-id 为 t 会对每个 tangle src block 所在 subtree 生成 id(如果没有）
;; not work after org9.5, so the comments is always file link, not ids
(setq org-id-link-to-org-use-id nil) 

;; 用绝对路径，因为相对路径经常算错
(setq org-babel-tangle-use-relative-file-links nil)


(defun my/org-babel-comment-out-link-lines ()
  "Comment out all lines starting with # [[."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^[[:space:]]*# \\[\\[" nil t)
      (comment-region (line-beginning-position) (line-end-position))))
  (save-buffer))


(defun my/org-babel-comment-out-ends-here-lines ()
  "Comment out all lines starting with # and ending with ends here."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^[[:space:]]*#.*ends here$" nil t)
      (comment-region (line-beginning-position) (line-end-position))))
  (save-buffer))

(defun my/fix-nested-link-format ()
  "Modify link format in the tangled FILE."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\[\\[\\[\\[\\(id:\\|file:\\)\\([^]]+\\)\\]\\[\\([^]]+\\)\\]\\]\\]\\[\\([^]]+\\)\\]\\]"
                              nil t)
      (replace-match "[[\\1\\2][\\4]]"))
    (save-buffer)))

(add-hook 'org-babel-post-tangle-hook #'my/org-babel-comment-out-link-lines)
(add-hook 'org-babel-post-tangle-hook #'my/org-babel-comment-out-ends-here-lines)
(add-hook 'org-babel-post-tangle-hook #'my/fix-nested-link-format)

(setq file-map '(("init" "~/org/design/wemacs.org" "~/metaesc/.wemacs/init.el")
                 ("xwish" "~/org/design/web/posts/xwish.org")
                 ("i3" "~/org/design/web/posts/i3wm.org")
                 ("tmux" "~/org/logical/tmux.org")
                 ("vimrc" "~/org/logical/vim.org")
                 ("eaf" "~/org/logical/eaf.org")
                 ("inputrc" "/tmp/inputrc.org")
                 ("bashrc" "~/org/logical/bash.org")))

(defun my/count-org-ids ()
  "Count the number of IDs in the org-id-locations-file."
  (if (and (file-exists-p org-id-locations-file)
           (require 'org-id nil t))
      (with-temp-buffer
        (insert-file-contents org-id-locations-file)
        (goto-char (point-min))
        (let ((ids-list (read (current-buffer))))
          (message "Total org IDs: %d"
                   (apply '+ (mapcar (lambda (x) (- (length x) 1)) ids-list)))))
    (message "org-id-locations-file does not exist or org-id not loaded.")))

(defun tangle-config-file (name)
  "Tangle only specific language blocks from org file based on file extension."
  (let ((prog-mode-hook nil)  ; Avoid running hooks when tangling
        (original-lang-exts org-babel-tangle-lang-exts))
    (let ((args (cdr (assoc name file-map))))
      ;; 如果第二个参数非 nil 且为 .el 文件，则仅导出 elisp 代码块
      (when (and (nth 1 args) (string-suffix-p ".el" (nth 1 args)))
        (setq org-babel-tangle-lang-exts '(("elisp" . "el"))))
      (apply #'org-babel-tangle-file args)
      ;; 恢复原始的 org-babel-tangle-lang-exts
      (setq org-babel-tangle-lang-exts original-lang-exts))
    (message (format "Tangled %s completed with org version %s"
                     name
                     org-version))))
