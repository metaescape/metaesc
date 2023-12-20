(require 'package)
(setq package-user-dir "~/.wemacs/elpa")
(package-initialize)
(setq org-id-locations-file "~/.wemacs/.org-id-locations")
(setq org-confirm-babel-evaluate nil
      org-src-preserve-indentation t)
(org-babel-do-load-languages
 'org-babel-load-languages '((org . t) (shell . t))
 )
(require 'find-lisp)
(require 'org)
(require 'org-id)
(require 'ob-tangle)
(setq org-babel-default-header-args '((:comments . "noweb")))
;; 会对每个 tangle src block 所在 subtree 生成 id(如果没有）
(setq org-id-link-to-org-use-id t) 

(defun my/org-babel-comment-out-link-lines ()
  "Comment out all lines starting with # [[."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^[[:space:]]*# \\[\\[" nil t)
      (comment-region (line-beginning-position) (line-end-position))))
  (save-buffer)
  )


(defun my/org-babel-comment-out-ends-here-lines ()
  "Comment out all lines starting with # and ending with ends here."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^[[:space:]]*#.*ends here$" nil t)
      (comment-region (line-beginning-position) (line-end-position))))
  (save-buffer)
  )

(defun my/fix-nested-link-format ()
  "Modify link format in the tangled FILE."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\[\\[\\[\\[id:\\([^]]+\\)\\]\\[\\([^]]+\\)\\]\\]\\]\\[\\([^]]+\\)\\]\\]"
                              nil t)
      (replace-match "[[id:\\1][\\3]]"))
    (save-buffer)))

(add-hook 'org-babel-post-tangle-hook #'my/org-babel-comment-out-link-lines)
(add-hook 'org-babel-post-tangle-hook #'my/org-babel-comment-out-ends-here-lines)
(add-hook 'org-babel-post-tangle-hook #'my/fix-nested-link-format)

(setq file-map '(("init" "~/org/design/wemacs.org" "~/metaesc/.wemacs/init.el")
                 ("xwish" "~/org/design/web/posts/xwish.org")
                 ("i3" "~/org/logical/i3wm.org")
                 ("tmux" "~/org/logical/tmux.org")
                 ("vimrc" "~/org/logical/vim.org")
                 ("eaf" "~/org/logical/eaf.org")
                 ("inputrc" "/tmp/inputrc.org")
                 ("bashrc" "~/org/logical/bash.org")))

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
    (message (format "Tangled %s completed." name))))
