;; [[file:~/org/design/wemacs.org::*Garbage Collection][Garbage Collection:1]]
;;; -*- lexical-binding: t -*-
(defvar better-gc-cons-threshold (* 1024 1024 20)) ; 20mb
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold better-gc-cons-threshold)
            (setq file-name-handler-alist file-name-handler-alist-original)
            (makunbound 'file-name-handler-alist-original)))

(setq garbage-collection-messages nil) ;show garbage

(add-hook 'emacs-startup-hook
          (lambda ()
            (if (boundp 'after-focus-change-function)
                (add-function :after after-focus-change-function
                              (lambda ()
                                (unless (frame-focus-state)
                                  (garbage-collect))))
              (add-hook 'after-focus-change-function 'garbage-collect))
            (defun gc-minibuffer-setup-hook ()
              (setq gc-cons-threshold (* better-gc-cons-threshold 2)))

            (defun gc-minibuffer-exit-hook ()
              (garbage-collect)
              (setq gc-cons-threshold better-gc-cons-threshold))

            (add-hook 'minibuffer-setup-hook #'gc-minibuffer-setup-hook)
            (add-hook 'minibuffer-exit-hook #'gc-minibuffer-exit-hook)))
;; Garbage Collection:1 ends here

;; [[file:~/org/design/wemacs.org::*用 package 从 melpa 安装 use-package][用 package 从 melpa 安装 use-package:1]]
(require 'package)
;; (setq package-archives
;;       '(("gnu"   . "https://elpa.gnu.org/packages/")
;;         ("melpa" . "https://melpa.org/packages/")))

(setq package-archives
      '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))


;; update the package metadata if the local cache is missing
;; (unless package-archive-contents (package-refresh-contents))

(defun my/set-proxy ()
  (interactive)
  (setq url-proxy-services
        '(("no_proxy" . "^\\(localhost\\|10.*\\)")
          ("http" . "127.0.0.1:7890")
          ("https" . "127.0.0.1:7890"))))

(defun my/set-unproxy ()
  (interactive)
  (setq url-proxy-services nil))
;; 用 package 从 melpa 安装 use-package:1 ends here

;; [[file:~/org/design/wemacs.org::*用 package 从 melpa 安装 use-package][用 package 从 melpa 安装 use-package:2]]
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
;; (setq use-package-verbose t)  
(setq use-package-always-ensure t)
(setq load-prefer-newer t) ;; Always load newest byte code
;; 用 package 从 melpa 安装 use-package:2 ends here

;; [[file:~/org/design/wemacs.org::*which-key 和 general][which-key 和 general:1]]
(use-package which-key 
  :init (which-key-mode)
  :defer 2
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.5))
;; which-key 和 general:1 ends here

;; [[file:~/org/design/wemacs.org::*which-key 和 general][which-key 和 general:2]]
(use-package general
  :config
  (general-define-key
   :keymaps 'general-override-mode-map
   "C-M-u" 'universal-argument))
;; which-key 和 general:2 ends here

;; [[file:~/org/design/wemacs.org::*快速插入代码 bootstrap][快速插入代码 bootstrap:1]]
(use-package org-tempo
  :ensure nil
  :config
  (add-to-list 'org-structure-template-alist '("," . "src emacs-lisp :results none"))
  (fset 'yes-or-no-p 'y-or-n-p))
;; 快速插入代码 bootstrap:1 ends here

;; [[file:~/org/design/wemacs.org::*包的升级管理方案][包的升级管理方案:1]]
(use-package pkg-update-checker
  :defer 10
  :load-path "site-lisp/pkg-update-checker" 
  :config
  (start-pkg-update-checker-timer))
;; 包的升级管理方案:1 ends here

;; [[file:~/org/design/wemacs.org::*Evil][Evil:1]]
;; # [[file:~/org/logical/evil.org::evil-basic][evil-basic]]
(use-package evil
  :init
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config 
  (evil-mode 1)
  ;; [[file:~/org/logical/evil.org::evil-esc][evil-esc]]
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
  (defun minibuffer-keyboard-quit ()
    "Abort recursive edit.
  In Delete Selection mode, if the mark is active, just deactivate it;
  then it takes a second \\[keyboard-quit] to abort the minibuffer."
    (interactive)
    (if (and delete-selection-mode transient-mark-mode mark-active)
        (setq deactivate-mark  t)
      (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
      (abort-recursive-edit)))
  
    (general-define-key
     :keymaps '(normal visual global)
     [escape] 'keyboard-quit
     )
  
  (general-define-key
   :keymaps '(minibuffer-local-map
              minibuffer-local-ns-map
              minibuffer-local-completion-map
              minibuffer-local-must-match-map
              minibuffer-local-isearch-map)
   [escape] 'minibuffer-keyboard-quit)
  ;; evil-esc ends here
  ;; [[file:~/org/logical/evil.org::evil-undo-fu][evil-undo-fu]]
  (use-package undo-fu
    :config
    (define-key evil-normal-state-map "u" 'undo-fu-only-undo)
    (define-key evil-normal-state-map "\C-r" 'undo-fu-only-redo))
  ;; evil-undo-fu ends here
  ;; [[file:~/org/logical/evil.org::evil-collections][evil-collections]]
  (use-package evil-collection
    :after evil
    :config
    (evil-collection-init))
  
  (use-package evil-org
    :after org
    :hook (org-mode . (lambda () (evil-org-mode +1)))
    :config
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys)
    ;; (evil-org-set-key-theme '(navigation insert textobjects additional calendar))
    (evil-org-set-key-theme '(textobjects))
    
    (general-define-key
     :keymaps '(org-mode-map)
     :states '(normal visual)
     "<return>" 'org-open-at-point)
    
    (evil-define-key 'normal 'evil-org-mode
      (kbd "go") 'evil-org-open-below
      (kbd "gO") 'evil-org-open-above
      (kbd "o") 'evil-open-below
      (kbd "O") 'evil-open-above
      (kbd "<") 'org-promote-subtree
      (kbd ">") 'org-demote-subtree
    ))
  
  (add-hook 'org-log-buffer-setup-hook 'evil-insert-state)
  ;; evil-collections ends here
  ;; [[file:~/org/logical/evil.org::expand-region][expand-region]]
  (use-package expand-region
    :general
    (:keymaps 'visual
              "v" 'er/expand-region)
    :config
    (setq expand-region-contract-fast-key "z"))
  ;; expand-region ends here
  ;; [[file:~/org/logical/evil.org::evil-surround][evil-surround]]
  (use-package evil-surround
    :config
    (global-evil-surround-mode 1)
  
    (defun insert-around-region (begin end left right)
      "Insert LEFT and RIGHT around the current region."
      (save-excursion
        (goto-char end)
        (insert right)
        (goto-char begin)
        (insert left)))
  
    (defun surround-with-correct-punctuation (char)
      "Surround region with CHAR. Use Chinese punctuation if the region contains Chinese characters."
      (interactive "cEnter surround character: ")
      (let ((begin (region-beginning))
            (end (region-end))
            (region (buffer-substring-no-properties (region-beginning) (region-end)))
            (chinese-punctuation (pcase char
                                   (?\" "“”")
                                   (?' "‘’")
                                   (?\( "（）")
                                   (?\) "（）")
                                   (?\[ "【】")
                                   (?\] "【】")
                                   (?\{ "｛｝")
                                   (?\} "｛｝")
                                   (?\> "《》")
                                   (?\< "《》")
                                   (_ nil))))
        (if (and chinese-punctuation (string-match-p "\\cc" region))
            (let ((left (substring chinese-punctuation 0 1))
                  (right (substring chinese-punctuation 1 2)))
              (insert-around-region begin end left right))
          (evil-surround-region (region-beginning) (region-end) 'char char))))
  
    (defun my-evil-surround-dwim ()
      "Detect the surrounding character and use the correct punctuation based on the region content."
      (interactive)
      (call-interactively 'surround-with-correct-punctuation))
  
    (general-define-key
     :keymaps 'general-override-mode-map
     :states '(visual)
     "S" 'my-evil-surround-dwim
     ))
  ;; evil-surround ends here
  ;; [[file:~/org/logical/evil.org::evil-commentary][evil-commentary]]
  (use-package evil-commentary
    ;; :diminish evil-commentary
    :config
    (evil-commentary-mode)
  )
  ;; evil-commentary ends here
  ;; [[file:~/org/logical/evil.org::evil-multiedit][evil-multiedit]]
  (use-package evil-multiedit
    :load-path "site-lisp/evil-multiedit"
    ;; git@github.com:metaescape/evil-multiedit.git
    :general
     (:keymaps '(evil-visual-state-map)
     ;; Highlights all matches of the selection in the buffer.
     "R" 'evil-multiedit-match-all
     ;; incrementally add the next unmatched match.
     "n" 'evil-multiedit-match-and-next
     "N" 'evil-multiedit-match-and-prev ;; p for evil past
     )
     (:keymaps '(evil-multiedit-state-map) 
     "SPC" 'evil-multiedit-toggle-or-restrict-region
     "ESC" 'evil-multiedit-abort
     "C-j" 'evil-multiedit-next
     "C-k" 'evil-multiedit-prev
     "n" 'evil-multiedit-match-and-next
     "N" 'evil-multiedit-match-and-prev
     )
     (:keymaps '(evil-multiedit-insert-state-map) 
     "C-j" 'evil-multiedit-next
     "C-k" 'evil-multiedit-prev
     )
    :config
    (define-key evil-motion-state-map (kbd "RET") 'evil-multiedit-toggle-or-restrict-region)
    ;; Ex command that allows you to invoke evil-multiedit with a regular expression, e.g.
    (evil-ex-define-cmd "ie[dit]" 'evil-multiedit-ex-match))
  ;; evil-multiedit ends here
  ;; [[file:~/org/logical/evil.org::evil-select-paste][evil-select-paste]]
  (setq-default evil-kill-on-visual-paste nil)
  ;; evil-select-paste ends here
  ;; [[file:~/org/logical/evil.org::snipe-pinyin][snipe-pinyin]]
  (use-package evil-snipe
    :defer
    :config
    (evil-snipe-mode -1) ;; disabled 2 char jump
    (evil-snipe-override-mode +1) ;; enable 1 char jump
    (setq evil-snipe-scope 'line) ;; jump in line
  )
  
  (use-package evil-find-char-pinyin
    :config
    (evil-find-char-pinyin-toggle-snipe-integration t)
    (setq evil-find-char-pinyin-only-simplified t) ;; nil for traditional chinese
    (setq evil-find-char-pinyin-enable-punctuation-translation t) ;;punctuation
    )
  ;; snipe-pinyin ends here
  ;; [[file:~/org/logical/evil.org::avy-ace-pinyin][avy-ace-pinyin]]
  (use-package avy
    :bind
    (:map evil-normal-state-map
          ("C-\\" . ace-pinyin-goto-char-timer))
    :config
    (setq avy-all-windows t) ;; jump to any buffer in window
    (setq avy-timeout-seconds 0.5)
  
    (use-package ace-pinyin
      :config
      (ace-pinyin-global-mode +1))
  
    (defun ace-pinyin--build-string-regexp (string)
      (pinyinlib-build-regexp-string
       string
       (not ace-pinyin-enable-punctuation-translation)
       (not ace-pinyin-simplified-chinese-only-p)))
  
    (defun ace-pinyin-goto-char-timer (&optional arg)
      "Read one or many consecutive chars and jump to the first one.
  The window scope is determined by `avy-all-windows' (ARG negates it)."
      (interactive "P")
      (let ((avy-all-windows (if arg
                                 (not avy-all-windows)
                               avy-all-windows)))
        (avy-with avy-goto-char-timer
          (setq avy--old-cands
                (avy--read-candidates #'ace-pinyin--build-string-regexp))
          (avy-process avy--old-cands))))
  
    (general-define-key
     :keymaps 'org-agenda-mode-map
     :states 'motion ;; agenda 下用 motion 代替 normal state
     "C-\\" 'ace-pinyin-goto-char-timer
     ))
  ;; avy-ace-pinyin ends here
  ;; [[file:~/org/logical/evil.org::evil-9line][evil-9line]]
  ;; Use visual line motions even outside of visual-line-mode buffers
  ;; deal with wrap
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  
  (evil-define-motion move-9-lines-down () (evil-next-visual-line 9))
  (evil-define-motion move-9-lines-up () (evil-previous-visual-line 9))
  
  (general-define-key
   :keymaps 'general-override-mode-map
   :states '(normal visual motion)
   "J" 'move-9-lines-down
   "K" 'move-9-lines-up
   )
  ;; evil-9line ends here
  ;; [[file:~/org/logical/evil.org::ex-quit-buffer][ex-quit-buffer]]
  ;; :q should kill the current buffer rather than quitting emacs entirely
  (evil-ex-define-cmd "q" 'kill-this-buffer)
  (evil-ex-define-cmd "wq" 'kill-this-buffer)
   ;; Need to type out :quit to close emacs
  (evil-ex-define-cmd "quit" 'evil-quit)
  ;; ex-quit-buffer ends here
  (general-define-key
   :keymaps '(visual)
   "DEL" (lambda ()
           (interactive)
           (evil-delete (region-beginning) (region-end) nil ?_))))
;; # evil-basic ends here
;; Evil:1 ends here

;; [[file:~/org/design/wemacs.org::*eshell][eshell:1]]
(defun eshell--set-indent ()
  (setq-local indent-line-function (lambda () 'noindent)))

(add-hook 'eshell-mode-hook 'eshell--set-indent)
;; eshell:1 ends here

;; [[file:~/org/design/wemacs.org::*dird mode][dird mode:1]]
 ;; # [[file:~/org/logical/dired.org::dired-setting][dired-setting]]
 (use-package dired
   :ensure nil
   :commands (dired dired-jump)
   :bind (("C-c d" . dired-jump))
   :custom ((dired-listing-switches "-agho --group-directories-first"))
   :config
   (setq delete-by-moving-to-trash t) ;; trash is loacated at .local/share/Trash
   (require 'dired-x)
   ;; detect target path of other window automatically 
   (setq dired-dwim-target 1)
   ;; [[file:~/org/logical/dired.org::dired-sort][dired-sort]]
   (defun xah-dired-sort ()
     "Sort dired dir listing in different ways.
     Prompt for a choice.
     URL `http://ergoemacs.org/emacs/dired_sort.html'
     Version 2018-12-23"
     (interactive)
     (let ($sort-by $arg)
       (setq $sort-by (ido-completing-read "Sort by:" '( "date" "size" "name" )))
       (cond
        ((equal $sort-by "name") (setq $arg "-Al "))
        ((equal $sort-by "date") (setq $arg "-Al -t"))
        ((equal $sort-by "size") (setq $arg "-Al -S"))
        ;; ((equal $sort-by "dir") (setq $arg "-Al --group-directories-first"))
        (t (error "logic error 09535" )))
       (dired-sort-other $arg )))
     (define-key dired-mode-map (kbd "s") 'xah-dired-sort)
   ;; dired-sort ends here
   ;; [[file:~/org/logical/dired.org::md-to-org][md-to-org]]
   (require 'seq)
   (defun dired-md-to-org ()
     (interactive)
     (let
         ((shell-command "pandoc -t org `?`.md | sed -E '/^[[:space:]]+:/ d' > `?`.org"))
       (setq marked-filepathes (dired-get-marked-files))
       (setq marked-filenames (mapcar 'file-name-nondirectory marked-filepathes))
       (setq marked-source-filenames
             (seq-filter
              (lambda (x) (equal "md" (file-name-extension x))) marked-filenames))
       (setq marked-source-names (mapcar 'file-name-sans-extension marked-source-filenames))
       (dired-do-shell-command shell-command nil marked-source-names))) 
   
   (defun md-buffer-to-org ()
     "Convert the current buffer's content from markdown to orgmode format and save it with the current buffer's file name but with .org extension."
     (interactive)
     (let ((filename (file-name-sans-extension (buffer-file-name))))
       (shell-command-on-region (point-min) (point-max)
                                (format "pandoc -t org %s.md | sed -E '/^[[:space:]]+:/ d' > %s.org" filename filename))))
   ;; md-to-org ends here
   ;; [[file:~/org/logical/dired.org::ipynb-to-md][ipynb-to-md]]
   (defun ipynb-to-md ()
     (interactive)
     (let
           ((shell-command "notedown `?`.ipynb --to markdown --strip > `?`.md"))
           (setq marked-filepathes (dired-get-marked-files))
           (setq marked-filenames (mapcar 'file-name-nondirectory marked-filepathes))
           (setq marked-source-filenames
            (seq-filter
             (lambda (x) (equal "ipynb" (file-name-extension x))) marked-filenames))
           (setq marked-source-names (mapcar 'file-name-sans-extension marked-source-filenames))
      (dired-do-shell-command shell-command nil marked-source-names)
     )) 
   ;; ipynb-to-md ends here
   ;; [[file:~/org/logical/dired.org::md-to-ipynb][md-to-ipynb]]
   (defun md-to-ipynb ()
     (interactive)
     (let
           ((shell-command "notedown `?`.md > `?`.ipynb"))
           (setq marked-filepathes (dired-get-marked-files))
           (setq marked-filenames (mapcar 'file-name-nondirectory marked-filepathes))
           (setq marked-source-filenames
            (seq-filter
             (lambda (x) (equal "md" (file-name-extension x))) marked-filenames))
           (setq marked-source-names (mapcar 'file-name-sans-extension marked-source-filenames))
      (dired-do-shell-command shell-command nil marked-source-names)
     )) 
   ;; md-to-ipynb ends here
   ;; [[file:~/org/logical/dired.org::ipynb-to-org][ipynb-to-org]]
   (defun ipynb-to-org ()
     (interactive)
     (let
           ((shell-command "notedown `?`.ipynb --to markdown --strip > tmp.md; pandoc -t org tmp.md | sed -E '/^[[:space:]]+:/ d' > `?`.org;sleep 1; rm tmp.md"))
           (setq marked-filepathes (dired-get-marked-files))
           (setq marked-filenames (mapcar 'file-name-nondirectory marked-filepathes))
           (setq marked-source-filenames
            (seq-filter
             (lambda (x) (equal "ipynb" (file-name-extension x))) marked-filenames))
           (setq marked-source-names (mapcar 'file-name-sans-extension marked-source-filenames))
      (dired-do-shell-command shell-command nil marked-source-names)
     )) 
   ;; ipynb-to-org ends here
   )
 
 ;; [[file:~/org/logical/dired.org::dired-single][dired-single]]
 (use-package dired-single
   :config
   (evil-collection-define-key 'normal 'dired-mode-map
     "h" 'dired-single-up-directory
     "l" 'dired-single-buffer
     ;;(kbd "<backspace>") 'dired-single-up-directory
   )
 )
 ;; dired-single ends here
 ;; [[file:~/org/logical/dired.org::icons-dired][icons-dired]]
 (use-package nerd-icons-dired
   :hook
   (dired-mode . nerd-icons-dired-mode))
 ;; icons-dired ends here
 ;; [[file:~/org/logical/dired.org::dired-hide-dotfiles][dired-hide-dotfiles]]
 (use-package dired-hide-dotfiles
   :hook (dired-mode . dired-hide-dotfiles-mode)
   :config
   (evil-collection-define-key 'normal 'dired-mode-map
     "H" 'dired-hide-dotfiles-mode))
 ;; dired-hide-dotfiles ends here
 ;; # dired-setting ends here
;; dird mode:1 ends here

;; [[file:~/org/design/wemacs.org::*startup screen][startup screen:1]]
;; disable startup page, same as (setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
;; disable tool-bar (icon bar)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(set-fringe-mode 10)        ; Give some breathing room 左右边距
;; open in right most (don't need because i3wm)
;;(setq initial-frame-alist (quote ((left . 550) (width . 90) (fullscreen . fullheight))))
;; startup screen:1 ends here

;; [[file:~/org/design/wemacs.org::*mode line and theme][mode line and theme:1]]
;; M-x nerd-icons-install-fonts to download fonts
;; 如果下载失败，参考 https://emacs-china.org/t/raw-githubusercontent-com/14430
(use-package nerd-icons)
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-oceanic-next t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
  (doom-themes-treemacs-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 12))
  :config
  (custom-set-faces
   '(mode-line-inactive ((t (:background nil)))))
  (setq doom-modeline-buffer-encoding nil)

  ;;~/m/emacs/emacs_conf.rg
  (setq doom-modeline-buffer-file-name-style 'truncate-upto-root)

  ;; don't show tabbar name
  (setq doom-modeline-workspace-name nil)

  (column-number-mode t))
;; mode line and theme:1 ends here

;; [[file:~/org/design/wemacs.org::*encodings and fonts][encodings and fonts:1]]
  ;; font setting
;; (set-frame-font "Consolas:size=16")
(set-frame-font "Noto Sans Mono:size=16")

(setq default-frame-alist nil)

;; encoding
(set-language-environment "UTF-8")
(set-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq system-time-locale "C")
;; encodings and fonts:1 ends here

;; [[file:~/org/design/wemacs.org::*unicode-fonts][unicode-fonts:1]]
(use-package unicode-fonts
  :disabled
  :config
  (unicode-fonts-setup))
;; unicode-fonts:1 ends here

;; [[file:~/org/design/wemacs.org::*unicode-fonts][unicode-fonts:2]]
(when (member "Noto Color Emoji" (font-family-list))
  (set-fontset-font
   t 'symbol (font-spec :family "Noto Color Emoji") nil 'prepend))
;; unicode-fonts:2 ends here

;; [[file:~/org/design/wemacs.org::*中文对齐][中文对齐:1]]
(use-package valign
  :defer)
;; 中文对齐:1 ends here

;; [[file:~/org/design/wemacs.org::*line number, cursor/line highlight][line number, cursor/line highlight:1]]
(global-display-line-numbers-mode t)
(line-number-mode)
;; Disable line numbers for some modes
(dolist (mode '(term-mode-hook
                shell-mode-hook
                image-mode-hook
                pdf-view-mode-hook
                org-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; highlight the current line
(use-package hl-line
  :ensure nil
  :config
  (global-hl-line-mode +1))

;; alternative method: highlight current line
;;(global-hl-line-mode 1)

;; set cursor to bar instead of block
  (setq-default cursor-type 'bar)
;; line number, cursor/line highlight:1 ends here

;; [[file:~/org/design/wemacs.org::*line number, cursor/line highlight][line number, cursor/line highlight:2]]
(use-package beacon
  :defer 1
  :config
  (progn
    (setq beacon-blink-when-point-moves-vertically nil) ; default nil
    (setq beacon-blink-when-point-moves-horizontally nil) ; default nil
    (setq beacon-blink-when-buffer-changes t) ; default t
    (setq beacon-blink-when-window-scrolls t) ; default t
    (setq beacon-blink-when-window-changes t) ; default t
    (setq beacon-blink-when-focused nil) ; default nil

    (setq beacon-blink-duration 0.3) ; default 0.3
    (setq beacon-blink-delay 0.3) ; default 0.3
    (setq beacon-size 25) ; default 40
    ;; (setq beacon-color "yellow") ; default 0.5
    (setq beacon-color "grey") ; default 0.5

    (add-to-list 'beacon-dont-blink-major-modes 'term-mode)

    (beacon-mode 1)))
;; line number, cursor/line highlight:2 ends here

;; [[file:~/org/design/wemacs.org::*better default behavior(misc)][better default behavior(misc):1]]
  ;;disable ring bell,防止每次使用c-g时产生告警声
(setq ring-bell-function 'ignore)

;; 默认情况下当鼠标移动到屏幕最后一行，再往下移时，emacs会翻半页，这很突兀
;; scroll-conservatively控制是否翻页的行为，设置为大于100即可
;; scroll-margin设置屏幕滚动时光标距离上下端的行数
;; nice scrolling
(setq scroll-margin 5
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; selection and replace
(delete-selection-mode 1)

;; Wrap lines at 80 characters
;; (setq-default fill-column 80)

;; enable auto indent
(electric-indent-mode 1)
;; better default behavior(misc):1 ends here

;; [[file:~/org/design/wemacs.org::*solong][solong:1]]
(use-package so-long
  :ensure nil
  :config (global-so-long-mode 1))

;; warn when opening files bigger than 50MB
(setq large-file-warning-threshold (* 60 1024 1024))
;; solong:1 ends here

;; [[file:~/org/design/wemacs.org::*hideshow][hideshow:1]]
(use-package hideshow
  :ensure nil
  :diminish hs-minor-mode
  :hook (prog-mode . hs-minor-mode)
  )
;; hideshow:1 ends here

;; [[file:~/org/design/wemacs.org::*backup files][backup files:1]]
  ;; start server
(server-start)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; auto save abbrevs in .emacs.d/abbrev_defs without asking
(setq save-abbrevs 'silently)
  ;;; also you can disable auto backup
;; disable auto backup
;; (setq make-backup-files nil)
;; disable auto save list
;; (setq auto-save-default nil)

(defconst my-savefile-dir (expand-file-name "savefile" user-emacs-directory))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p my-savefile-dir)
  (make-directory my-savefile-dir))

;; saveplace remembers your location in a file when saving files
(use-package saveplace
  :ensure nil
  :defer 2
  :config
  (setq save-place-file (expand-file-name "saveplace" my-savefile-dir))
  ;; activate it for all buffers
  (save-place-mode 1)
  ) 

(use-package savehist
  :ensure nil
  :config
  (setq savehist-additional-variables
        ;; search entries
          '(search-ring regexp-search-ring)
          ;; save every minute
          savehist-autosave-interval 60
          ;; keep the home clean
          savehist-file (expand-file-name "savehist" my-savefile-dir))
    (savehist-mode +1))

(use-package recentf
  :ensure nil
  :defer 1
  :config
  (setq recentf-save-file (expand-file-name "recentf" my-savefile-dir)
        recentf-max-saved-items 200
        ;; disable recentf-cleanup on Emacs start, because it can cause
        ;; problems with remote files
        recentf-auto-cleanup 'never)
  (recentf-mode +1))
;; backup files:1 ends here

;; [[file:~/org/design/wemacs.org::*括号高亮][括号高亮:1]]
(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :config
  (set-face-attribute 'show-paren-match nil
                      :background "gray30"
                      :foreground "bisque"
                      :underline t)
  (setq
       show-paren-style 'parenthesis
       show-paren-when-point-inside-paren t
       show-paren-when-point-in-periphery t)
  )
;; 括号高亮:1 ends here

;; [[file:~/org/design/wemacs.org::*括号高亮][括号高亮:2]]
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
)
;; 括号高亮:2 ends here

;; [[file:~/org/design/wemacs.org::*rgb 颜色编码的高亮][rgb 颜色编码的高亮:1]]
(use-package rainbow-mode
  :hook (org-mode . rainbow-mode))
;; rgb 颜色编码的高亮:1 ends here

;; [[file:~/org/design/wemacs.org::*透明设置][透明设置:1]]
;; (set-frame-parameter (selected-frame) 'alpha '(95 . 96))
(set-frame-parameter (selected-frame) 'alpha '(100 . 100))
(add-to-list 'default-frame-alist '(alpha . (100 . 90)))
;; 透明设置:1 ends here

;; [[file:~/org/design/wemacs.org::*不再使用][不再使用:1]]
  ;; (setq frame-title-format "%b - emacs")
;; 不再使用:1 ends here

;; [[file:~/org/design/wemacs.org::*auto save file][auto save file:1]]
(use-package auto-save
  :load-path "site-lisp/auto-save"
  :defer 5
  :custom
  (auto-save-idle 2)
  :config
  (auto-save-enable)
  (setq auto-save-silent t)   ; quietly save
  )
(setq auto-save-default nil)
;; auto save file:1 ends here

;; [[file:~/org/design/wemacs.org::*auto read file][auto read file:1]]
(global-auto-revert-mode t)
(setq enable-local-variables :safe)
;; auto read file:1 ends here

;; [[file:~/org/design/wemacs.org::*occur 搜索][occur 搜索:1]]
;; occur do what i mean: M-s o to select current word to search
;; like grep in vim,but more powerful.
(defun occur-dwim ()
  "Call `occur' with a sane default."
  (interactive)
  (push (if (region-active-p)
	    (buffer-substring-no-properties
	     (region-beginning)
	     (region-end))
	  (let ((sym (thing-at-point 'symbol)))
	    (when (stringp sym)
	      (regexp-quote sym))))
	regexp-history)
  (call-interactively 'occur))
(global-set-key (kbd "M-s o") 'occur-dwim)
;; occur 搜索:1 ends here

;; [[file:~/org/design/wemacs.org::*copy file path][copy file path:1]]
(defun copy-file-name-on-clipboard ()
  "Put the current file name on the clipboard"
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (with-temp-buffer
        (insert filename)
        (clipboard-kill-region (point-min) (point-max)))
      (message filename))))
;; copy file path:1 ends here

;; [[file:~/org/design/wemacs.org::*引擎搜索选择][引擎搜索选择:1]]
(use-package webjump
  :ensure nil
  :config
  (setq browse-url-handlers
        '(("." . browse-url-default-browser)))
  (setq webjump-baidu-query "https://www.baidu.com/s?wd=%s"
        webjump-google-query "https://www.google.com/search?q=%s"
        webjump-google-trans "https://translate.google.com/?hl=zh-CN&sl=auto&tl=zh-CN&text=%s&op=translate"
        webjump-google-trans2 "https://translate.google.com/?hl=zh-CN&sl=auto&tl=en&text=%s&op=translate"
        webjump-google-trans2 "https://translate.google.com/?hl=zh-CN&sl=auto&tl=en&text=%s&op=translate"
        webjump-leetcode-query "https://leetcode.cn/problemset/?search=%s&page=1"
        )
  (setq webjump-sites
        (append '(
                  ("Baidu" . baidu-query)
                  )
                webjump-sample-sites))

  (cl-defun search-evil-visual-selection (&optional (engin-name webjump-google-query))
    (interactive)
    (let* ((query-target (buffer-substring (region-beginning) (region-end))))
      (message query-target)
      (browse-url (format engin-name query-target))))

  :general
  (:keymaps 'visual
            "s g" 'search-evil-visual-selection
            "s b" '(lambda () (interactive) (search-evil-visual-selection webjump-baidu-query))
            "s t" '(lambda () (interactive) (search-evil-visual-selection webjump-google-trans))
            "s l" '(lambda () (interactive) (search-evil-visual-selection webjump-leetcode-query))
            "s T" '(lambda () (interactive) (search-evil-visual-selection webjump-google-trans2))))
;; 引擎搜索选择:1 ends here

;; [[file:~/org/design/wemacs.org::*选择后设置为 radio link][选择后设置为 radio link:1]]
(defun convert-to-radio-link()
  (interactive)
  (let* ((end (region-end))
         (beg (region-beginning))
         (radio-target (buffer-substring beg end))
         )
    (delete-region beg end)
    (insert (concat "<<<" radio-target ">>>"))))
(general-define-key
 :keymaps 'org-mode-map
 :states '(visual)
 "C-\\" 'ace-pinyin-goto-char-timer
 "s >" 'convert-to-radio-link)
;; 选择后设置为 radio link:1 ends here

;; [[file:~/org/design/wemacs.org::*arxiv 转为 ar5iv 链接][arxiv 转为 ar5iv 链接:1]]
(defun check-and-copy-arxiv-link-to-ar5iv ()
  "Check if the cursor is on an arXiv link and copy a modified link to the clipboard."
  (interactive)
  (let ((link-text (thing-at-point 'url)))
    (when (and link-text (string-match "^https://arxiv\\.org/abs/\\(.*\\)$" link-text))
      (let* ((paper-id (match-string 1 link-text))
             (new-link (format "[[https://ar5iv.labs.arxiv.org/html/%s][Ar5iv]]" paper-id)))
        (kill-new new-link)
        (message "ar5iv link copied: %s" new-link)))))
;; arxiv 转为 ar5iv 链接:1 ends here

;; [[file:~/org/design/wemacs.org::*ivy 生态][ivy 生态:1]]
;; # [[file:~/org/logical/ivy.org::ivy][ivy]]
(use-package ivy
  :defer 1
  :diminish
  :general
  (:keymaps '(global-map Info-mode-map bibtex-mode-map markdown-mode-map comint-mode-map)
            "M-n" 'swiper-isearch
            "s-n" 'projectile-ripgrep)
  :bind ( 
         ("C-s" . swiper)
         ("s-s T" . search-all-tasks)
         ("s-s p" . projectile-ripgrep)
         ("s-s g" . counsel-rg)
         ("s-s v" . counsel-rg-my-vocab)
         :map org-mode-map
         ("s-r c" . counsel-rg-named-src)
         :map ivy-minibuffer-map ;; bind in minibuufer
         ("C-l" . ivy-alt-done) 
         ("C-j" . ivy-next-line)
         ("s-i" . ivy-restrict-to-matches)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill))
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t ;;add recent file, book marker, view
        ivy-count-format "(%d/%d) ")
  (general-define-key
   :keymaps '(general-override-mode-map org-agenda-mode-map)
   :states '(motion normal visual) ;; agenda 下用motion 代替 normal state
   "SPC" 'ivy-switch-buffer
   "/" 'swiper-isearch
   )
  ;; [[file:~/org/logical/ivy.org::search-all-tasks][search-all-tasks]]
  (defun search-all-tasks ()
    (interactive)
    (let* ((org-refile-targets '((org-agenda-files :maxlevel . 2))))
      (org-refile '(4))))
  ;; search-all-tasks ends here
  ;; [[file:~/org/logical/ivy.org::ivy-fly][ivy-fly]]
  ;; @see https://www.reddit.com/r/emacs/comments/b7g1px/withemacs_execute_commands_like_marty_mcfly/
  (defvar my-ivy-fly-commands
    '(query-replace-regexp
      flush-lines keep-lines ivy-read
      swiper swiper-backward swiper-all
      swiper-isearch swiper-isearch-backward
      lsp-ivy-workspace-symbol lsp-ivy-global-workspace-symbol
      counsel-grep-or-swiper counsel-grep-or-swiper-backward
      counsel-grep counsel-ack counsel-ag counsel-rg counsel-pt))
  (defvar-local my-ivy-fly--travel nil)
  
  (defun my-ivy-fly-back-to-present ()
    (cond ((and (memq last-command my-ivy-fly-commands)
                (equal (this-command-keys-vector) (kbd "M-p")))
           ;; repeat one time to get straight to the first history item
           (setq unread-command-events
                 (append unread-command-events
                         (listify-key-sequence (kbd "M-p")))))
          ((or (memq this-command '(self-insert-command
                                    ivy-forward-char
                                    ivy-delete-char delete-forward-char
                                    end-of-line mwim-end-of-line
                                    mwim-end-of-code-or-line mwim-end-of-line-or-code
                                    yank ivy-yank-word counsel-yank-pop))
               (equal (this-command-keys-vector) (kbd "M-n")))
           (unless my-ivy-fly--travel
             (delete-region (point) (point-max))
             (when (memq this-command '(ivy-forward-char
                                        ivy-delete-char delete-forward-char
                                        end-of-line mwim-end-of-line
                                        mwim-end-of-code-or-line
                                        mwim-end-of-line-or-code))
               (insert (ivy-cleanup-string ivy-text))
               (when (memq this-command '(ivy-delete-char delete-forward-char))
                 (beginning-of-line)))
             (setq my-ivy-fly--travel t)))))
  
  (defun my-ivy-fly-time-travel ()
    (when (memq this-command my-ivy-fly-commands)
      (let* ((kbd (kbd "M-n"))
             (cmd (key-binding kbd))
             (future (and cmd
                          (with-temp-buffer
                            (when (ignore-errors
                                    (call-interactively cmd) t)
                              (buffer-string))))))
        (when future
          (save-excursion
            (insert (propertize (replace-regexp-in-string
                                 "\\\\_<" ""
                                 (replace-regexp-in-string
                                  "\\\\_>" ""
                                  future))
                                'face 'shadow)))
          (add-hook 'pre-command-hook 'my-ivy-fly-back-to-present nil t)))))
  
  (add-hook 'minibuffer-setup-hook #'my-ivy-fly-time-travel)
  (add-hook 'minibuffer-exit-hook
            (lambda ()
              (remove-hook 'pre-command-hook 'my-ivy-fly-back-to-present t)))
  ;; ivy-fly ends here
  ;; [[file:~/org/logical/ivy.org::counsel-rg-my-vocab][counsel-rg-my-vocab]]
  (defun counsel-rg-my-vocab ()
    (interactive)
    (counsel-rg "" "~/codes/ranger/vocab/" "" "-g *.org ")
  )
  ;; counsel-rg-my-vocab ends here
  (use-package ivy-rich
    :init
    (ivy-rich-mode 1))
  (use-package wgrep)
  )
;; # ivy ends here
;; # [[file:~/org/logical/ivy.org::counsel][counsel]]
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x f" . counsel-find-file) ;;origin is set-fill-column
         :map org-mode-map
         ("C-c o" . counsel-org-goto)  ;; outline, similar to pdf/epub outline
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)
  (use-package smex)
  ;;将 c-c c-q(默认 org-set-tags-command) 定向为 counsel-org-tag
  ;;进入 tag 选择菜单后，通过 alt+enter 可以进行多选（选中当前而不退出）
  (global-set-key [remap org-set-tags-command] #'counsel-org-tag)
  )
;; # counsel ends here
;; # [[file:~/org/logical/ivy.org::helpful][helpful]]
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))
;; # helpful ends here
;; ivy 生态:1 ends here

;; [[file:~/org/design/wemacs.org::*窗口、 tab 管理][窗口、 tab 管理:1]]
;; # [[file:~/org/logical/window_manager.org::tab-bar][tab-bar]]
;; [[file:~/org/logical/window_manager.org::dashboard][dashboard]]
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          ))
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  (setq dashboard-startup-banner "/data/resource/pictures/dashboard/moutain.png")
  (setq dashboard-image-banner-max-width 300)
  (setq dashboard-banner-logo-title "don't panic") ;;nil to delete

  (setq dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-newline
                                    dashboard-insert-banner-title
                                    dashboard-insert-newline
                                    dashboard-insert-navigator
                                    dashboard-insert-newline
                                    dashboard-insert-init-info
                                    dashboard-insert-items
                                    dashboard-insert-newline
                                    dashboard-insert-footer))

  ;; Format: "(icon title help action face prefix suffix)"
  (setq dashboard-navigator-buttons
        `(;; line1
          ((,(nerd-icons-mdicon
              "nf-md-dock_window"
              :height 1.1 :v-adjust 0.0)
            "desktop-read (R)"
            ""
            (lambda (&rest _) (desktop-read))))))

  (setq dashboard-set-file-icons t)
  (setq dashboard-footer-messages '("-------------------"))
  (setq dashboard-display-icons-p t) ;; display icons on both GUI and terminal
  (setq dashboard-icon-type 'nerd-icons) ;; use `nerd-icons' package

  (general-define-key
   :keymaps '(dashboard-mode-map)
   :states 'normal
   ;; "gd" 'evil-goto-definition
   "R" 'desktop-read)
  )
;; dashboard ends here
(use-package tab-bar
  :ensure nil
  :config
  ;; [[file:~/org/logical/window_manager.org::tab-utils][tab-utils]]
  (tab-bar-mode 1)
  (setq tab-bar-new-button-show nil)
  (setq tab-bar-close-button-show nil)
  (setq tab-bar-show 1)
  (setq tab-bar-tab-hints t) ;; show number
  (setq tab-bar-auto-width nil) ;; 取消自动 padding 大小(29.2 引入)
  (setq tab-bar-format '(tab-bar-format-tabs tab-bar-separator tab-bar-format-align-right tab-bar-format-global))
  (defun my/update-tab-bar-after-theme-change (&rest _args)
    "Update tab bar face attributes after a theme change."
    (set-face-attribute 'tab-bar-tab nil
                        :inherit 'doom-modeline-panel
                        :foreground 'unspecified
                        :background 'unspecified)
  
    (set-face-attribute 'tab-bar nil
                        :foreground (face-attribute 'default :foreground)))
  
  (advice-add 'load-theme :after #'my/update-tab-bar-after-theme-change)
  (my/update-tab-bar-after-theme-change)
  ;; tab-utils ends here
  ;; [[file:~/org/logical/window_manager.org::switch-tab-by-name-num][switch-tab-by-name-num]]
  (defun switch-to-tab-by-number (num)
    (let ((current-prefix-arg num)  ;; emulate C-u num
          (current-tab-index (tab-bar--current-tab-index)))
      ;; (update-ivy-tabs)
      (if (equal (1+ current-tab-index) num) ;; num start from 1
          (tab-bar-switch-to-recent-tab)
        (call-interactively 'tab-select))))
  
  (general-define-key
   :keymaps 'general-override-mode-map
   "M-1" '(lambda () (interactive) (switch-to-tab-by-number 1))
   "M-2" '(lambda () (interactive) (switch-to-tab-by-number 2))
   "M-3" '(lambda () (interactive) (switch-to-tab-by-number 3))
   "M-4" '(lambda () (interactive) (switch-to-tab-by-number 4))
   "M-5" '(lambda () (interactive) (switch-to-tab-by-number 5))
   "M-6" '(lambda () (interactive) (switch-to-tab-by-number 6))
   "M-7" '(lambda () (interactive) (switch-to-tab-by-number 7))
   "M-8" '(lambda () (interactive) (switch-to-tab-by-number 8))
   "M-9" '(lambda () (interactive) (switch-to-tab-by-number 9))
   )
  ;; switch-tab-by-name-num ends here
  ;; [[file:~/org/logical/window_manager.org::quick-switch-back][quick-switch-back]]
  (defvar last-switch-action nil)
  (defun my/tab-switch-advice (&rest _) (setq last-switch-action "tab-switch"))
  (defun my/buffer-switch-advice (&rest _) (setq last-switch-action "buffer-switch"))
  (defun my/avy-goto-advice (&rest _) (setq last-switch-action "avy-goto"))
  
  (advice-add 'switch-to-tab-by-number :after #'my/tab-switch-advice)
  (advice-add 'ivy--switch-buffer-action :after #'my/buffer-switch-advice)
  (add-hook 'find-file-hook 'my/buffer-switch-advice)
  (advice-add 'ace-pinyin-goto-char-timer :after #'my/avy-goto-advice)
  
  (defun my/switch-back ()
    "Switch to the recent buffer, or destoried window configuration."  
    (interactive)
    (cond 
     ((member major-mode '(special-mode
                           messages-buffer-mode
                           helpful-mode
                           magit-status-mode
                           help-mode
                           Custom-mode
                           ibuffer-mode
                           debugger-mode
                           org-roam-mode
                           compilation-mode))
      (quit-window))
     ((member major-mode '(package-menu-mode))
      (switch-to-buffer (other-buffer (current-buffer) nil)))
     ((equal last-switch-action "window-switch")
      (evil-window-mru))
     ((equal last-switch-action "avy-goto")
      (avy-pop-mark))
     ((equal last-switch-action "tab-switch")
      (tab-bar-switch-to-recent-tab))
     ((equal last-switch-action "buffer-switch")
      (switch-to-buffer (other-buffer (current-buffer) nil)))))
  
  (general-define-key
   :keymaps '(general-override-mode-map org-agenda-mode-map eaf-mode-map*)
   :states '(motion normal visual) ;; agenda 下用motion 代替 normal state
   "gq" 'my/switch-back)
  ;; quick-switch-back ends here
  ;; [[file:~/org/logical/window_manager.org::confirm-scratch-delete][confirm-scratch-delete]]
  (defun my/confirm-kill-scratch-buffer (orig-fun &rest args)
    "Confirm before killing the *scratch* buffer."
    (let ((buffer-to-kill (car args)))
      (if (and (get-buffer "*scratch*") 
               (equal buffer-to-kill (get-buffer "*scratch*"))
               (not (yes-or-no-p "*scratch* Don't want to be Killed, Confirm? ")))
          (message "Aborted")
        (apply orig-fun args))))
  
  (advice-add 'kill-buffer :around #'my/confirm-kill-scratch-buffer)
  ;; confirm-scratch-delete ends here
  ;; [[file:~/org/logical/window_manager.org::windmove-ibuffer][windmove-ibuffer]]
  (general-define-key
   :keymaps 'general-override-mode-map
   :states '(normal insert visual motion)
   "M-h" 'windmove-left
   "M-l" 'windmove-right
   "M-j" 'windmove-down
   "M-k" 'windmove-up)
  
  (use-package ibuffer
    :defer
    :config
    (general-define-key
     :keymaps 'ibuffer-mode-map
     :states 'normal
     "," nil 
     "s," 'ibuffer-toggle-sorting-mode
     "SPC" 'switch-to-buffer))
  ;; windmove-ibuffer ends here
  (use-package popwin
    :config
    (popwin-mode 1))

  (use-package winner 
    :ensure nil
    :hook (after-init . winner-mode))
  )
;; # tab-bar ends here
;; 窗口、 tab 管理:1 ends here

;; [[file:~/org/design/wemacs.org::*ediff][ediff:1]]
(defun user--ediff-mode-hook ()
  "Ediff mode hook."
  (setq
   ;; Don't wrap long lines.
   truncate-lines t))


(defun user--ediff-startup-hook ()
  "Ediff startup hook."
  (setq
   ;; Split window differently depending on frame width.
   ediff-split-window-function
   (if (> (frame-width) (* 2 80))
       'split-window-horizontally
     'split-window-vertically))
  ;; Go to the first difference on startup.
  (ediff-next-difference))

(use-package ediff
  :defer
  :ensure nil
  :init  ;; Go to first difference on start.
  (add-hook 'ediff-startup-hook 'user--ediff-startup-hook)
  :hook (ediff-quit . winner-undo)
  :config
  (setq
   ;; Ignore changes in whitespace.
   ediff-diff-options "-w"
   ediff-ignore-similar-regions t)

  (use-package ediff-wind
    :ensure nil
    :config
    (setq
     ;; Don't create a separate frame for ediff.
     ediff-window-setup-function 'ediff-setup-windows-plain))
  ;; (use-package ztree)
  )
;; ediff:1 ends here

;; [[file:~/org/design/wemacs.org::*pyim + rime \[+ sis\]][pyim + rime  [+ sis]:1]]
;; # [[file:~/org/logical/input_method.org::pyim-minimum][pyim-minimum]]
;; [[file:~/org/logical/input_method.org::pyim-ivy][pyim-ivy]]
(require 'pyim-cregexp-utils)
(setq ivy-re-builders-alist
    '((t . pyim-cregexp-ivy)))
;; pyim-ivy ends here
(use-package pyim
  :general
  (:keymaps '(evil-insert-state-map company-active-map)
            "M-DEL" 'pyim-delete-backward-word
            "<C-backspace>" 'pyim-delete-backward-word
            "C-w" 'pyim-delete-backward-word
            )
  :config
  (use-package pyim-basedict
    :after pyim
    :config (pyim-basedict-enable))
  ;; [[file:~/org/logical/input_method.org::pyim-delete-chinese-word][pyim-delete-chinese-word]]
  (require 'pyim-cstring-utils) ;;  needed in native-comp
  (defun pyim-delete-backward-word ()
      (interactive)
    (let ((cur (point))
          (char (pyim-char-before-to-string 0))
          )
      (if (pyim-string-match-p " " char)
          (skip-chars-backward " ")
          (pyim-backward-word)
      )
      (delete-region (point) cur)
    )
  )
  ;; pyim-delete-chinese-word ends here
  )
;; # pyim-minimum ends here
;; # [[file:~/org/logical/input_method.org::emacs-rime][emacs-rime]]
(use-package rime
  :general
   (:keymaps '(rime-active-mode-map)
   "M-DEL" 'rime--escape 
   "C-w" 'rime--escape 
   )
   (:keymaps '(evil-insert-state-map minibuffer-local-map ivy-minibuffer-map)
   "C-\\" 'convert-code-or-disable-rime
   )
  :custom
  (default-input-method "rime")
  :config
  (use-package popup) ;; depend
  ;; [[file:~/org/logical/input_method.org::emacs-rime-posframe][emacs-rime-posframe]]
  (setq rime-show-candidate 'posframe)
  
  (setq rime-posframe-properties
            (list :background-color "#333333"
                  :foreground-color "#dcdccc"
                  :internal-border-width 10))
  ;; emacs-rime-posframe ends here
  (setq default-input-method "rime"
        rime-user-data-dir "~/.config/emacs_rime")
  ;; [[file:~/org/logical/input_method.org::rime-switch-manually][rime-switch-manually]]
  (defun +translate-symbol-to-rime ()
    (interactive)
    (let* ((end (point))
           (beg (+ end (skip-chars-backward "a-z")))
           (input (buffer-substring beg end))
           )
      (delete-region beg end)
      (if current-input-method nil (toggle-input-method))
      (dolist (c (string-to-list input))
        (rime-lib-process-key c 0)
        )
      (rime--redisplay)))
  
  (defun convert-code-or-disable-rime ()
    (interactive)
    (if (not (featurep 'ecb))
        (require 'pyim)
        )
    (let ((str-before-1 (pyim-char-before-to-string 0)))
      (cond ((pyim-string-match-p "[a-z]" str-before-1)
             (+translate-symbol-to-rime))
            ((pyim-string-match-p "[[:punct:]]\\|：" str-before-1)
             (pyim-punctuation-translate-at-point))
            (t (toggle-input-method)))))
  ;; rime-switch-manually ends here
  ;; [[file:~/org/logical/input_method.org::rime-switch-auto][rime-switch-auto]]
  (setq rime-disable-predicates
        '(
          rime-predicate-after-ascii-char-p 
          rime-predicate-evil-mode-p 
          rime-predicate-punctuation-after-space-cc-p 
          rime-predicate-punctuation-after-ascii-p 
          rime-predicate-punctuation-line-begin-p 
          rime-predicate-org-in-src-block-p
          rime-predicate-prog-in-code-p
          rime-predicate-org-latex-mode-p
          ;; rime-predicate-space-after-ascii-p 
          rime-predicate-space-after-cc-p 
          rime-predicate-current-uppercase-letter-p 
          rime-predicate-tex-math-or-command-p 
          ))
  ;; rime-switch-auto ends here
  ;; [[file:~/org/logical/input_method.org::rime-color-change][rime-color-change]]
  (advice-add 'toggle-input-method :after 'change-cursor-color-on-input-method)
  (defvar input-method-cursor-color "white"
    "Default cursor color if using an input method.")
  
  (defun get-frame-cursor-color ()
    "Get the cursor-color of current frame."
    (interactive)
    (frame-parameter nil 'cursor-color))
  
  (defvar default-cursor-color (get-frame-cursor-color)
    "Default text cursor color.")
  
  (defun change-cursor-color-on-input-method ()
    "Set cursor color depending on whether an input method is used or not."
    (interactive)
    (set-cursor-color (if (and (rime--should-enable-p)
                               (not (rime--should-inline-ascii-p))
                               current-input-method)
                          input-method-cursor-color
                        default-cursor-color)))
  
  (add-hook 'post-command-hook 'change-cursor-color-on-input-method)
  ;; rime-color-change ends here
  (defun sync-ibus-and-emacs-rime-userdb ()
    (interactive)
    (rime-sync)
    (start-process-shell-command
     ""
     nil
     "ibus exit;cd ~/.config/ibus/rime; rime_dict_manager -s;ibus-daemon --xim -d -r")
    (message "ibus-rime and emacs rime sync done")
    )
  )
;; # emacs-rime ends here
;; pyim + rime  [+ sis]:1 ends here

;; [[file:~/org/design/wemacs.org::*中文与英文之间保持空格][中文与英文之间保持空格:1]]
(use-package pangu-spacing 
  :defer
  :config
  ;;(global-pangu-spacing-mode t)
  (setq pangu-spacing-real-insert-separtor t)
)
;; 中文与英文之间保持空格:1 ends here

;; [[file:~/org/design/wemacs.org::*常用函数的 hydra 界面][常用函数的 hydra 界面:1]]
(use-package hydra)

(setq text-scale-mode-step 1.1) ;; text scalle ratio

(defhydra main-hydra (:color red :hint nil :exit t :timeout 3 :idle 0.2)
  "
    most common used functions
    _f_: projectile-find-file        _m_: maximize current window
    _r_: open files in reading dir   _b_: add bookmark and save
    _w_: save-buffer                 _q_: quickly quitely quit window
    _-_: split-window-below          _\\_: split-window-right
    _h_: winner-undo                 _l_: winner-redo
    _i_: org-clock-in                _o_: org-clock-out
    _d_: org-clock done              _v_: org-imagine-view
    _._: repeat operations           _x_: kill-this-buffer               
    "
  ;;("d" debug-test-hydra/body)
  ("r" (lambda () (interactive) (counsel-file-jump " " "/data/resource/readings/")))
  ("f" counsel-file-jump)
  ;; bookmark-set is temporary, you need save
  ("b" (lambda () (interactive) (bookmark-set) (bookmark-save)))
  ("p" nil)
  ("m" delete-other-windows)
  ("q"  delete-window)
  ("w"  save-buffer)
  ("x"  kill-this-buffer)
  ("\\"  split-window-right)
  ("-"  split-window-below)
  ("i" (lambda () (interactive) (org-clock-in) (org-agenda "" " ")
         (evil-window-mru)))
  ("o" (lambda () (interactive) (org-clock-out) (org-agenda "" " ")
         (evil-window-mru)))
  ("d" (lambda () (interactive) (org-todo "DONE") (org-agenda "" " ")
         (evil-window-mru)))
  ("v" org-imagine-view)
  ("," narrow-or-widen-dwim)
  ("h" winner-undo :exit nil)
  ("l" winner-redo :exit nil)
  ("." hydra-repeats/body))

(general-define-key
 :keymaps '(general-override-mode-map org-agenda-mode-map)
 :states '(normal visual motion)
 "," 'main-hydra/body)

(use-package ivy
  :config 
  (defun open-with-system-app (file)
    (let* ((ext (file-name-extension file))
           (app-list (cond ((equal ext "pdf") '("masterpdfeditor5" "xdg-open"))
                           ((equal ext "epub") '("foliate"))
                           ((equal ext "md") '("typora"))))
           (app (completing-read
                 "Select Apps: "
                 (append app-list '("code" "nautilus")))))
      ;;(message (format "%s %s" default-directory file))
      (if (or (equal app "code") (equal app "natuils"))
          (start-process "open-external" nil
                         "setsid" app
                         (cdr (project-current "" file)))
        (start-process "open-external" nil "setsid" app file))))
  

  (defun open-with-system-app-dwim ()
    (interactive)
    (if (derived-mode-p 'dired-mode)
        (open-with-system-app  (dired-get-file-for-visit))
      (open-with-system-app (buffer-file-name))))
  
  (ivy-add-actions
   'counsel-file-jump
   '(("p" open-with-system-app "open file with system app")))

  (general-define-key
   :keymaps '(org-mode-map pdf-view-mode-map markdown-mode-map
                           prog-mode-map nov-mode-map dired-mode-map
                           general-override-mode-map)
   :states '(normal visual)
   "M-o" 'open-with-system-app-dwim))
;; 常用函数的 hydra 界面:1 ends here

;; [[file:~/org/design/wemacs.org::*重复操作的子按键 hydra][重复操作的子按键 hydra:1]]
(defhydra hydra-repeats (:timeout 5 :hint nil)
  "
   repeated actions
    _-_: window-zoom-in        _h_: shrink-window
    _=_: window-zoon-out       _l_: enlarge-window     
    _s_: swap window
    "
  ("s" window-swap-states)
  ("-" text-scale-decrease)
  ("=" text-scale-increase)
  ("h" shrink-window-horizontally)
  ("l" enlarge-window-horizontally)
  ("H" (lambda () (interactive)
         (shrink-window-horizontally 5)))
  ("L" (lambda () (interactive)
         (enlarge-window-horizontally 5)))
  ("q" nil :exit t))
;; 重复操作的子按键 hydra:1 ends here

;; [[file:~/org/design/wemacs.org::*tab 冲突处理][tab 冲突处理:1]]
(defvar my/folded-state nil
  "跟踪全局折叠状态。如果 t，表示最近执行的是折叠操作。")

(defun my/toggle-all-folds ()
  "切换所有代码块的折叠状态。"
  (interactive)
  (if my/folded-state
      (progn
        (evil-open-folds)
        (setq my/folded-state nil))
    (progn
      (evil-close-folds)
      (setq my/folded-state t))))
;; tab 冲突处理:1 ends here

;; [[file:~/org/design/wemacs.org::*tab 冲突处理][tab 冲突处理:3]]
(defun my/special-elisp-setup ()
  "如果当前 buffer 的文件名后缀为 '.el'，则应用特殊的键位绑定。"
  (when (and (buffer-file-name)
             (string-match-p "\\.el\\'" (buffer-file-name)))
    (general-define-key
     :states 'normal
     :keymaps 'local
     "TAB" 'evil-toggle-fold
     "<backtab>" 'my/toggle-all-folds)))

(add-hook 'emacs-lisp-mode-hook 'my/special-elisp-setup)
;; tab 冲突处理:3 ends here

;; [[file:~/org/design/wemacs.org::*tab 冲突处理][tab 冲突处理:4]]
  (defun yas-expand-only-in-insert-state (orig-fun &rest args)
    "只在 evil 的 insert 模式下允许 yas-expand."
    (when (and (bound-and-true-p evil-mode)
               (eq evil-state 'insert))
      (apply orig-fun args)))
  
  (advice-add 'yas-expand-from-trigger-key :around #'yas-expand-only-in-insert-state)
;; tab 冲突处理:4 ends here

;; [[file:~/org/design/wemacs.org::*projectile][projectile:1]]
(use-package projectile
  :diminish projectile-mode
  :custom ((projectile-completion-system 'ivy))
  :defer 1
  :bind-keymap
  ("C-c p" . projectile-command-map)
  ("s-p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  ;; (setq projectile-project-search-path '("~/myconf/" "~/org/" ))
  (setq projectile-switch-project-action #'projectile-dired)
  :config
  (projectile-mode)
  (use-package counsel-projectile
    :config (counsel-projectile-mode))
  )
;; projectile:1 ends here

;; [[file:~/org/design/wemacs.org::*gitgutter 和 git timemachine][gitgutter 和 git timemachine:1]]
(use-package git-timemachine
  :defer)
(use-package git-gutter
  :bind ("M-g M-g" . hydra-git-gutter/body)
  :config
  (global-set-key (kbd "M-g M-g") 'hydra-git-gutter/body)
  (defhydra hydra-git-gutter (:body-pre (git-gutter-mode 1)
                                        :hint nil :color blue)
    "
Git gutter:
  _j_: next hunk        _s_tage hunk   _q_uit and deactivate git-gutter
  _k_: previous hunk    _r_evert hunk    
  ^ ^                   _p_opup hunk
  _h_: first hunk       
  _l_: last hunk        set start _R_evision
"
    ("j" git-gutter:next-hunk)
    ("k" git-gutter:previous-hunk)
    ("h" (progn (goto-char (point-min))
                (git-gutter:next-hunk 1)))
    ("l" (progn (goto-char (point-min))
                (git-gutter:previous-hunk 1)))
    ("s" git-gutter:stage-hunk)
    ("r" git-gutter:revert-hunk)
    ("p" git-gutter:popup-hunk)
    ("R" git-gutter:set-start-revision)
    ("q" (progn (git-gutter-mode -1)
                ;; git-gutter-fringe doesn't seem to
                ;; clear the markup right away
                (sit-for 0.1)
                (git-gutter:clear)))))
;; gitgutter 和 git timemachine:1 ends here

;; [[file:~/org/design/wemacs.org::*makefile 选择菜单][makefile 选择菜单:1]]
(use-package makefile-executor
  :config
  (add-hook 'makefile-mode-hook 'makefile-executor-mode))

(defun make-metaesc ()
  (interactive)
  (let ((default-directory "~/metaesc"))
    (makefile-executor-execute-project-target)))

(defun makefile-executor-execute-target (filename &optional target)
  "Execute a Makefile target from FILENAME using eshell.

FILENAME defaults to current buffer."
  (interactive
   (list (file-truename buffer-file-name)))

  (let ((target (or target (makefile-executor-select-target filename))))
    
    (makefile-executor-store-cache filename target)
    (let ((command (format "make -f %s -C %s %s"
                           (shell-quote-argument filename)
                           (shell-quote-argument (file-name-directory filename))
                           target)))
      (async-shell-command command)
      )))
;; makefile 选择菜单:1 ends here

;; [[file:~/org/design/wemacs.org::*electric 括号的自动补全][electric 括号的自动补全:1]]
(electric-pair-mode 1)

(add-hook 'org-mode-hook (lambda () 
            (set (make-local-variable 'electric-pair-pairs) 
                         '(
                            (?\( . ?\))
                            (?\{ . ?\})
                            ))))
(setq electric-pair-inhibit-predicate
      `(lambda (c)
          (if (char-equal c ?\<) t (,electric-pair-inhibit-predicate c))))
;; electric 括号的自动补全:1 ends here

;; [[file:~/org/design/wemacs.org::*smartparens 括号的自动补全][smartparens 括号的自动补全:1]]
(use-package smartparens
  :diminish smartparens-mode
  :bind
  :custom
  (sp-escape-quotes-after-insert nil)
  :config
  ;; Stop pairing single quotes in elisp
  (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
  (sp-local-pair 'org-mode "[" nil :actions nil))
;; smartparens 括号的自动补全:1 ends here

;; [[file:~/org/design/wemacs.org::*abbrev][abbrev:1]]
(setq abbrev-mode nil) ;;change to t to try abbrev
(define-abbrev-table 'global-abbrev-table 
 '(("cnfi" "#+begin_src emacs-lisp :results none\n#+end_src"))
 )
;; abbrev:1 ends here

;; [[file:~/org/design/wemacs.org::*company][company:1]]
(use-package company
 :config
 (setq company-idle-delay 0) ;;default 0.2
 (setq company-echo-delay 0) ;;default 0.01
 (setq company-show-numbers t) 
 (setq company-minimum-prefix-length 2) ;;default 3
 (setq company-dabbrev-minimum-length 2) ;;default 4
 (setq company-selection-wrap-around t) ;;default nil, next of end is begin
 (setq company-dabbrev-downcase nil)
 (setq company-backends '(company-capf
                        company-keywords
                        company-semantic
                        company-files
                        company-dabbrev
                        company-etags
                        company-clang
                        company-cmake
                        company-yasnippet))
 (setq company-require-match nil)
 (global-company-mode)

 (use-package company-posframe
  :after company
  :hook (company-mode . company-posframe-mode)
  :config
  (use-package posframe) 
  )
 )
;; company:1 ends here

;; [[file:~/org/design/wemacs.org::*与 yasnippet 冲突问题问题][与 yasnippet 冲突问题问题:2]]
;; # [[file:~/org/logical/text_completion.org::company-dabbrev-with-hyphen][company-dabbrev-with-hyphen]]
(setq company-dabbrev-char-regexp "\\sw...[a-zA-Z0-9-]?+")
;; # company-dabbrev-with-hyphen ends here
;; 与 yasnippet 冲突问题问题:2 ends here

;; [[file:~/org/design/wemacs.org::*org-mode environment][org-mode environment:1]]
;; # [[file:~/org/logical/orgmode_workflow.org::org][org]]
(use-package org
  :ensure nil
  :init 
  ;; fix bug for expand a heading with tab : Subtree (no children)
  (setq org-fold-core-style 'overlays) 
  (setq org-ellipsis " ▾")
  (global-set-key (kbd "C-c l") 'org-store-link)
  (bind-key "C-c n" 'narrow-or-widen-dwim)
  :general
  (:keymaps 'org-mode-map
            "s-l"  'org-toggle-link-display)
  :hook (org-mode . org-mode-ui-setup)
  :config
  (require 'ol-man) ;; support follow link in woman buffer
  (setq org-id-method 'ts)
  (setq org-image-actual-width nil)
  ;; [[file:~/org/logical/orgmode_workflow.org::org-basic-ui][org-basic-ui]]
  (defun org-mode-ui-setup ()
    (org-indent-mode)
    (setq word-wrap nil) 
    (visual-line-mode 1)
    (font-lock-add-keywords
     'org-mode
     '(("^ *\\([-]\\) "
        (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
    (setq org-emphasis-alist
          '(("*" (bold :slant italic :weight black )) ;; this make bold both italic and bold, but not color change
            ("/" (italic :foreground "dark salmon" )) ;; italic text, the text will be "dark salmon"
            ("_" underline :foreground "cyan" ) ;; underlined text, color is "cyan"
            ("=" (org-verbatim :background "black" :foreground "deep slate blue" )) ;; background of text is "snow1" and text is "deep slate blue"
            ("~" (org-code :background "dim gray" :foreground "PaleGreen1" ))
            ("+" (:strike-through t :foreground "dark orange" ))))
  
    (use-package org-appear
      :after org
      :hook (org-mode . org-appear-mode)
      :config
      (setq org-hide-emphasis-markers t)
      (setq org-appear-autolinks t)
      )
  
    (defun org-mode-visual-fill ()
      (setq visual-fill-column-width 100
            visual-fill-column-center-text t)
      (visual-fill-column-mode 1))
  
    (use-package visual-fill-column
      :hook (org-mode . org-mode-visual-fill))
    )
  ;; org-basic-ui ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::narrow-or-widen-dwim][narrow-or-widen-dwim]]
  (defun narrow-or-widen-dwim ()
    "If the buffer is narrowed, it widens. Otherwise, it narrows to region, or Org subtree."
    (interactive)
    (cond ((buffer-narrowed-p) (widen))
          ((region-active-p) (narrow-to-region (region-beginning) (region-end)))
          ((equal major-mode 'org-mode) (org-narrow-to-subtree))
          (t (error "Please select a region to narrow to"))))
  ;; narrow-or-widen-dwim ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::org-file-apps][org-file-apps]]
  (setq org-file-apps
        '((auto-mode . emacs)
          (directory . emacs)
          ("\\.mp4\\'" . "vlc \"%s\"")
          ("\\.mp3\\'" . "vlc \"%s\"")
          ("\\.drawio\\'" . "drawio \"%s\"")
          ("\\.mm\\'" . default)
          ("\\.x?html?\\'" . default)
          ("\\.pdf\\'" . default)))
  ;; org-file-apps ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::read-org-block-by-name][read-org-block-by-name]]
  (defun my/read-org-block-by-name (file block-name)
    "Read the content of a named org-mode block from
  a file."
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (if (re-search-forward (concat "^#\\+name: " (regexp-quote block-name)) nil t)
          (when (re-search-forward "^#\\+begin_src" nil t)
            (forward-line)
            (beginning-of-line)
            (let ((start (point)))
              (if (re-search-forward "^#\\+end_src" nil t)
                  (string-trim (buffer-substring-no-properties
                                start
                                (match-beginning 0)))
                (error "End of source block not found"))))
        (error "Named block not found"))))
  
  (defun my/jump-to-org-block-by-name (file block-name)
    "Jump inside the src block with name: block-name in the specified file."
    (find-file file)  ; 打开文件
    (goto-char (point-min))  ; 移动到 buffer 的开始位置
    (if (re-search-forward (concat "^#\\+name: " (regexp-quote block-name)) nil t)
        (when (re-search-forward "^#\\+begin_src" nil t)
          (forward-line 1)  ; 移动到 #+begin_src 的下一行
          (beginning-of-line))
      (error "Named block not found")))
  ;; read-org-block-by-name ends here
  )
;; # org ends here

;; # [[file:~/org/logical/orgmode_workflow.org::org-agenda][org-agenda]]
(use-package org-agenda
  :ensure nil
  :init
  ;; [[file:~/org/logical/orgmode_workflow.org::agenda-archive-gtd-files][agenda-archive-gtd-files]]
  (global-unset-key (kbd "C-'"))
  (global-unset-key (kbd "C-,"))
  
  (setq gtd-project-file "~/org/historical/projects.gtd"
        gtd-inbox-file "~/org/historical/inbox.gtd")
  
  (setq org-agenda-files (list gtd-project-file gtd-inbox-file))
  
  (defun get-archive-files-by-year (&optional year)
    (let ((year (or year "")))
      (file-expand-wildcards (format "~/org/historical/archive/%s*.org" year))))
  
  (defun get-current-archive-file-location ()
    (format
     "~/org/historical/archive/%s%s.org::"
     (format-time-string "%Y")
     (if (<= (string-to-number (format-time-string "%m")) 6) "a" "b")))
  
  (defun get-current-journal-file ()
    (format
     "~/org/self/journal/j%s%s.org"
     (format-time-string "%Y")
     (if (<= (string-to-number (format-time-string "%m")) 6) "a" "b")))
  
  (defun get-gtd-files-by-year (&optional year)
    (append org-agenda-files
            (get-archive-files-by-year year)))
  
  (defun my/set-archive-location (&rest _)
    "设置 org-archive-location 为当前存档文件的位置。"
    (setq org-archive-location (get-current-archive-file-location)))
  
  ;; defalult (time file olpath category todo itags)
  (setq org-archive-save-context-info '(time))
  (advice-add 'org-archive-subtree :before #'my/set-archive-location)
  ;; agenda-archive-gtd-files ends here
  :config
  ;; [[file:~/org/logical/orgmode_workflow.org::todo-list][todo-list]]
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d@/!)" "CANCEL(c@/!)")))
  
  ;; TODO color
  (setq org-todo-keyword-faces
     '(
      ("TODO" .      (:foreground "orange" :weight bold))
      ("NEXT" .      (:foreground "yellow" :weight bold))
      ("DONE" .      (:foreground "green" :weight bold))
      ("CANCEL" .     (:foreground "gray40"))
  ))
  
  (setq org-log-into-drawer t) ;; add logbook
  (setq org-log-done 'time) ;; add CLOSED: timestamp when task done
  
  (setq org-tag-alist '( ("noexport" . ?n)))
  ;; todo-list ends here
  
  ;; [[file:~/org/logical/orgmode_workflow.org::main-agenda][main-agenda]]
  (setq org-agenda-block-separator nil)
  (setq org-agenda-start-with-log-mode t) ;; show log
  
  (setq org-agenda-todo-view
        `(" " "Agenda"
          ((agenda ""
                   ((org-agenda-span 'day)
                    (org-agenda-start-with-log-mode t)
                    (org-agenda-log-mode-items '(closed clock state))
                    (org-deadline-warning-days 14)))
           (todo "TODO|NEXT"
                 ((org-agenda-overriding-header "GO")
                  (org-agenda-sorting-strategy '(priority-down effort-up))
                  (org-agenda-files '(,gtd-project-file))
                  (org-agenda-skip-function #'org-agenda-skip-all-siblings-but-first)
                  ))
           (search "^* \\.*"
                 ((org-agenda-overriding-header "Inbox Processing")
                  (org-agenda-files '(,gtd-inbox-file))))
           nil)))
  
  (defun org-agenda-skip-all-siblings-but-first ()
    "Skip all but the first non-done entry."
    (let (should-skip-entry)
      (unless (org-current-is-todo-or-next)
        (setq should-skip-entry t))
      (save-excursion
        (while (and (not should-skip-entry) (org-goto-sibling t))
          (when (org-current-is-todo-or-next)
            (setq should-skip-entry t))))
      (when should-skip-entry
        (or (outline-next-heading)
            (goto-char (point-max))))))
  
  (defun org-current-is-todo-or-next ()
    (or (string= "TODO" (org-get-todo-state))
        (string= "NEXT" (org-get-todo-state))))
  
  (setq org-agenda-prefix-format
        '((agenda . "%?-8t%-3e% s")
          (todo . "%-6:c %-6e")
          (tags . "%-12:c")
          (search . "%-12:c")))
  
  (add-to-list 'org-agenda-custom-commands `,org-agenda-todo-view)
  ;; main-agenda ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::clocktable-db-block][clocktable-db-block]]
  (defun my/update-clocktable-if-appropriate ()
    "Update clocktable if the point is in a paragraph within a clocktable block."
    (let ((element-type (org-element-type (org-element-context))))
      ;;(prin1 element-type)
      (when (and
             (or (eq element-type 'paragraph)
                 (eq element-type 'table-row))
             (save-excursion
               (let ((current-point (point))
                     (begin-found (search-backward "#+BEGIN: clocktable" nil t)))
                 (if begin-found
                     (progn
                       ;; Reset position for the next search
                       (goto-char current-point)
                       (let ((end-found (search-forward "#+END: clocktable" nil t)))
                         (and end-found
                              (<= begin-found current-point)
                              (>= end-found current-point))))
                   nil))))
        (org-dblock-update)
        t)))  ; Return non-nil to indicate the hook has done something.
  
  (add-hook 'org-ctrl-c-ctrl-c-hook 'my/update-clocktable-if-appropriate)
  ;; clocktable-db-block ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::org-clock-agenda][org-clock-agenda]]
  (use-package org-clock
    :ensure nil
    ;; :hook (org-clock-in-prepare . my/org-mode-ask-effort )
    :custom
    (org-clock-continuously nil)
    (org-clock-in-switch-to-state "NEXT")
    (org-clock-out-remove-zero-time-clocks t)
    (org-clock-display-default-range 'untilnow) ;; show statistic in all range
    (org-clock-persist t)
    (org-log-note-clock-out nil) ;; add log when clockout
    ;; (org-clock-persist-file (expand-file-name (format "%s/emacs/org-clock-save.el" xdg-cache)))
    (org-clock-persist-query-resume nil)
    ;; (org-clock-report-include-clocking-task t)
    (org-show-notification-timeout 10)
    :config
    (defun org-clock-out-if-done ()
      "Clock out when the task is marked DONE"
      (when (and (string= org-state "DONE")
                 (equal (marker-buffer org-clock-marker) (current-buffer))
                 (< (point) org-clock-marker)
                 (> (save-excursion (outline-next-heading) (point))
                    org-clock-marker)
                 (not (string= org-last-state org-state)))
        (org-clock-out)))
  
      (setq my/org-clock-effort 51)
      
      (defun set-org-clock-effort-when-nil ()
        (setq org-clock-effort my/org-clock-effort)
        (org-clock-update-mode-line))
  
    (add-hook 'org-clock-in-hook #'set-org-clock-effort-when-nil)
    (add-hook 'org-after-todo-state-change-hook 'org-clock-out-if-done)
  
    (defun clock-in-focus-notify ()
      (let ((current-focus-time
             (/ (float-time
                 (time-subtract (current-time) org-clock-start-time))
                60)))
        (when (>= current-focus-time my/org-clock-effort)
          (start-process-shell-command
           ""
           nil
           (my/read-org-block-by-name "~/org/historical/projects.gtd" "timeout")))
        (org-notify (if (org-clock-is-active)
                        (string-trim
                         (substring-no-properties
                          (org-clock-get-clock-string)))
                      ""))))
  
    (setq my/clock-in-focus-notify-gap (* 60 9))
  
    (defun clock-in-focus-timer-start ()
      "设置一个计时器，每 my/clock-in-focus-notify-gap 触发一次 clock-in-focus-notify"
      (setq clock-in-focus-timer
            (run-at-time
             my/clock-in-focus-notify-gap
             my/clock-in-focus-notify-gap
             #'clock-in-focus-notify)))
  
    (defun clock-in-focus-timer-stop ()
      (when (boundp 'clock-in-focus-timer)
        (cancel-timer clock-in-focus-timer)))
  
    (add-hook 'org-clock-in-hook #'clock-in-focus-timer-start)
    (add-hook 'org-clock-out-hook #'clock-in-focus-timer-stop)
  
    (defun clock-out-idle-notify ()
      (setq clock-out-idle-time-duration (+ 10 clock-out-idle-time-duration))
      (org-notify (format "%d minutes idle" clock-out-idle-time-duration)))
  
    (defun clock-out-idle-timer-start ()
      "设置一个计时器，每 600 秒（10分钟）触发一次 clock-out-idle-notify,
       用 clock-out-idle-time-duration 全局变量大致记录 timer 已经运行的时间"
  
      (setq clock-out-idle-time-duration 0)
      (setq clock-out-idle-timer (run-at-time 600 600 #'clock-out-idle-notify)))
  
    (defun clock-out-idle-timer-stop ()
      (when (boundp 'clock-out-idle-timer)
        (cancel-timer clock-out-idle-timer)))
  
    (add-hook 'org-clock-out-hook #'clock-out-idle-timer-start)
    (add-hook 'org-clock-in-hook #'clock-out-idle-timer-stop)
    )
  ;; org-clock-agenda ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::agenda-keybinding][agenda-keybinding]]
  (defun my/org-agenda-clock-in-and-refresh ()
    (interactive)
    (org-agenda-clock-in) (org-agenda-redo) (org-agenda-goto))
  
  (defun my/org-agenda-clock-out-and-refresh ()
    (interactive)
    (org-agenda-clock-out) (org-agenda-redo) (org-agenda-goto))
  
  (defun my/org-agenda-done ()
    (interactive)
    (org-agenda-todo "DONE") (org-agenda-redo) (org-agenda-goto))
  
  (defun org-agenda--jump-to-now ()
    "Search for the keyword 'now' in the current buffer and jump to it."
    (goto-char (point-min))  ; 从 buffer 的开头开始搜索
    (re-search-forward "now" nil t))  ; 搜索 'now' 关键词
  
  (defun org-agenda-clockreport-mode-enhenced ()
    (interactive)
    (if org-agenda-clockreport-mode
        (progn
          (org-agenda-clockreport-mode)
          (org-agenda--jump-to-now)
          (beginning-of-line))
      (progn
        (org-agenda-clockreport-mode)
        (re-search-forward "Time" nil t)
        (next-line 2))))
  
  (general-define-key
   :keymaps 'org-agenda-mode-map
   :states 'motion ;; agenda 下用 motion 代替 normal state
   "i" 'my/org-agenda-clock-in-and-refresh
   "o" 'my/org-agenda-clock-out-and-refresh
   "d" 'my/org-agenda-done
   "a" 'org-agenda-columns
   "R" 'org-agenda-clockreport-mode-enhenced
   )
  ;; agenda-keybinding ends here
  ;; [[file:~/org/logical/orgmode_workflow.org::gtd-oriented-tab][gtd-oriented-tab]]
  (defun create-or-switch-to-tab (tab-name)
    "Create or switch to a tab with the given TAB-NAME."
    (let ((tab-exists (tab-bar--tab-index-by-name tab-name)))
      (if tab-exists
          (tab-bar-switch-to-tab tab-name)
        (tab-new)
        (tab-rename tab-name))))
    (setq org-agenda-window-setup 'only-window)
  
  (defun gtd-setup-window-layout ()
    "Sets up a window layout with one window on the left and two windows stacked vertically on the right."
    (interactive)
    (progn
      (delete-other-windows)
      ;; 打开 agenda 跳到 clock 上
      (org-agenda "" " ")
      (split-window-horizontally) ;; 切分左右窗口
      (split-window-vertically)  ;; 在左侧 agenda 切分上下窗口
      (select-window (next-window)) ;; 在左侧下方窗口打开 entry 文件
      (find-file "~/org/historical/entry.org")
      ;; 跳转到右侧窗口打开项目文件, 跳转到最近 clock 的任务
      (select-window (next-window))
      (ignore-errors
        (org-clock-goto))
      (let ((target-file gtd-project-file))
        (unless (equal (buffer-file-name) (expand-file-name target-file))
          (switch-to-buffer (find-file target-file))))
      (split-window-vertically) ;; 右侧窗口继续切分出上下
      (select-window (next-window))
      (switch-to-buffer
       (find-file (get-current-journal-file)))))
  
  (defun gtd-oriented-tab-switch (gtd-tab-name)
    "if current tab is gtd-tab-name, execute other-window, else goto gtd-tab"
    (let ((current-tab (cdr (assq 'name (tab-bar--current-tab)))))
      (if (equal current-tab "gtds")
          (tab-bar-switch-to-recent-tab)
        (progn (create-or-switch-to-tab "gtds")
                 (gtd-setup-window-layout)))
      (setq last-switch-action "tab-switch")))
  (bind-key (kbd "s-<f10>") (lambda () (interactive) (gtd-oriented-tab-switch "gtds")))
  ;; gtd-oriented-tab ends here
  )
;; # org-agenda ends here

;; # [[file:~/org/logical/org_babel.org::org-babel][org-babel]]
(use-package jupyter
  :defer 2
  :after org
  :init
  ;; [[file:~/org/logical/org_babel.org::ob-templates][ob-templates]]
  (setq org-structure-template-alist
        '(
          ("j" . "src jupyter-python")
          ("r" . "src jupyter-racket")
          ("a" . "export ascii")
          ("cc" . "src C")
          ("ct" . "center")
          ("on" . "src org :noweb yes")
          ("E" . "export")
          ("l" . "export latex")
          ("v" . "verse"))
        )
  ;; ob-templates ends here
  :general
  (:keymaps 'org-mode-map
            "s-j s-j" 'jupyter-change-session
            )
  :config
  ;; don't ask when c-c c-c
  ;; show pictures in results, otherwise only print image path
  ;; (add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append)
  ;; [[file:~/org/logical/org_babel.org::global][global]]
  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images 'append)
  (setq org-src-fontify-natively t
        org-fontify-quote-and-verse-blocks t
        evil-indent-convert-tabs nil
        org-src-preserve-indentation nil
        org-edit-src-content-indentation 0
        org-export-use-babel t
        org-confirm-babel-evaluate nil)
  
  (setq org-babel-default-header-args
        '((:session . "none")
          (:async . "yes")
          (:results . "replace")
          (:exports . "both")
          (:cache . "no")
          (:noweb . "no")
          (:hlines . "no")
          (:tangle . "no")))
  ;; global ends here
  ;; [[file:~/org/logical/org_babel.org::load-language][load-language]]
  (org-babel-do-load-languages
      'org-babel-load-languages
      '(
      (emacs-lisp . t)
      (shell . t)
      (org . t)
      (scheme . t)
      (python . t)
      (makefile . t)
      (dot . t)
      (C, t)
      (js . t)
      (jupyter . t) ;; last
      ))
  ;; load-language ends here
  ;; [[file:~/org/logical/org_babel.org::ob-org][ob-org]]
  (setq org-babel-default-header-args:org '((:exports . "none")
                                            (:noweb . "yes")))
  ;; ob-org ends here
  ;; [[file:~/org/logical/org_babel.org::block-fontface][block-fontface]]
  (defun org-fontify-meta-lines-and-blocks-1 (limit)
    "Fontify #+ lines and blocks."
    (let ((case-fold-search t))
      (when (re-search-forward
  	       (rx bol (group (zero-or-more (any " \t")) "#"
  			              (group (group (or (seq "+" (one-or-more (any "a-zA-Z")) (optional ":"))
  					                        (any " \t")
  					                        eol))
  				                 (optional (group "_" (group (one-or-more (any "a-zA-Z"))))))
  			              (zero-or-more (any " \t"))
  			              (group (group (zero-or-more (not (any " \t\n"))))
  				                 (zero-or-more (any " \t"))
  				                 (group (zero-or-more any)))))
  	       limit t)
        (let ((beg (match-beginning 0))
  	        (end-of-beginline (match-end 0))
  	        ;; Including \n at end of #+begin line will include \n
  	        ;; after the end of block content.
  	        (block-start (match-end 0))
  	        (block-end nil)
  	        (lang (match-string 7)) ; The language, if it is a source block.
  	        (bol-after-beginline (line-beginning-position 2))
  	        (dc1 (downcase (match-string 2)))
  	        (dc3 (downcase (match-string 3)))
  	        (whole-blockline org-fontify-whole-block-delimiter-line)
  	        beg-of-endline end-of-endline nl-before-endline quoting block-type)
  	    (cond
  	     ((and (match-end 4) (equal dc3 "+begin"))
  	      ;; Truly a block
  	      (setq block-type (downcase (match-string 5))
  		        ;; Src, example, export, maybe more.
  		        quoting (member block-type org-protecting-blocks))
  	      (when (re-search-forward
  		         (rx-to-string `(group bol (or (seq (one-or-more "*") space)
  					                           (seq (zero-or-more (any " \t"))
  						                            "#+end"
  						                            ,(match-string 4)
  						                            word-end
  						                            (zero-or-more any)))))
  		         ;; We look further than LIMIT on purpose.
  		         nil t)
  	        ;; We do have a matching #+end line.
  	        (setq beg-of-endline (match-beginning 0)
  		          end-of-endline (match-end 0)
  		          nl-before-endline (1- (match-beginning 0)))
  	        (setq block-end (match-beginning 0)) ; Include the final newline.
  	        (when quoting
  	          (org-remove-flyspell-overlays-in bol-after-beginline nl-before-endline)
  	          (remove-text-properties beg end-of-endline
  				                      '(display t invisible t intangible t)))
  	        (add-text-properties
  	         beg end-of-endline '(font-lock-fontified t font-lock-multiline t))
  	        (org-remove-flyspell-overlays-in beg bol-after-beginline)
  	        (org-remove-flyspell-overlays-in nl-before-endline end-of-endline)
  	        (cond
  	         ((and lang (not (string= lang "")) org-src-fontify-natively)
  	          (org-src-font-lock-fontify-block lang block-start block-end)
  	          (add-text-properties bol-after-beginline block-end '(src-block t)))
  	         (quoting
  	          (add-text-properties
  	           bol-after-beginline beg-of-endline
  	           (list 'face
  		             (list :inherit
  			               (let ((face-name
  				                  (intern (format "org-block-%s" lang))))
  			                 (append (and (facep face-name) (list face-name))
  				                     '(org-block)))))))
  	         ((not org-fontify-quote-and-verse-blocks))
  	         ((string= block-type "quote")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-quote t))
  	         ((string= block-type "comment")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-quote t))
  	         ((string= block-type "dialogue")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-quote t))
  	         ((string= block-type "details")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-verse t))
               ;; 不能有数字和-
  	         ((string= block-type "reply")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-quote t))
  	         ((string= block-type "gpt")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-quote t))
  	         ((string= block-type "verse")
  	          (add-face-text-property
  	           bol-after-beginline beg-of-endline 'org-verse t)))
  	        ;; Fontify the #+begin and #+end lines of the blocks
  	        (add-text-properties
  	         beg (if whole-blockline bol-after-beginline end-of-beginline)
  	         '(face org-block-begin-line))
  	        (unless (eq (char-after beg-of-endline) ?*)
  	          (add-text-properties
  	           beg-of-endline
  	           (if whole-blockline
  		           (let ((beg-of-next-line (1+ end-of-endline)))
  		             (min (point-max) beg-of-next-line))
  		         (min (point-max) end-of-endline))
  	           '(face org-block-end-line)))
  	        t))
  	     ((member dc1 '("+title:" "+author:" "+email:" "+date:"))
  	      (org-remove-flyspell-overlays-in
  	       (match-beginning 0)
  	       (if (equal "+title:" dc1) (match-end 2) (match-end 0)))
  	      (add-text-properties
  	       beg (match-end 3)
  	       (if (member (intern (substring dc1 1 -1)) org-hidden-keywords)
  	           '(font-lock-fontified t invisible t)
  	         '(font-lock-fontified t face org-document-info-keyword)))
  	      (add-text-properties
  	       (match-beginning 6) (min (point-max) (1+ (match-end 6)))
  	       (if (string-equal dc1 "+title:")
  	           '(font-lock-fontified t face org-document-title)
  	         '(font-lock-fontified t face org-document-info))))
  	     ((string-prefix-p "+caption" dc1)
  	      (org-remove-flyspell-overlays-in (match-end 2) (match-end 0))
  	      (remove-text-properties (match-beginning 0) (match-end 0)
  				                  '(display t invisible t intangible t))
  	      ;; Handle short captions
  	      (save-excursion
  	        (beginning-of-line)
  	        (looking-at (rx (group (zero-or-more (any " \t"))
  				                   "#+caption"
  				                   (optional "[" (zero-or-more any) "]")
  				                   ":")
  			                (zero-or-more (any " \t")))))
  	      (add-text-properties (line-beginning-position) (match-end 1)
  			                   '(font-lock-fontified t face org-meta-line))
  	      (add-text-properties (match-end 0) (line-end-position)
  			                   '(font-lock-fontified t face org-block))
  	      t)
  	     ((member dc3 '(" " ""))
  	      ;; Just a comment, the plus was not there
  	      (org-remove-flyspell-overlays-in beg (match-end 0))
  	      (add-text-properties
  	       beg (match-end 0)
  	       '(font-lock-fontified t face font-lock-comment-face)))
  	     (t ;; Just any other in-buffer setting, but not indented
  	      (org-remove-flyspell-overlays-in (match-beginning 0) (match-end 0))
  	      (remove-text-properties (match-beginning 0) (match-end 0)
  				                  '(display t invisible t intangible t))
  	      (add-text-properties beg (match-end 0)
  			                   '(font-lock-fontified t face org-meta-line))
  	      t))))))
  ;; block-fontface ends here
  ;; [[file:~/org/logical/org_babel.org::jupyter-python-args][jupyter-python-args]]
  (setq-default org-babel-default-header-args:jupyter-python
                '((:kernel . "zshot")
                  (:eval . "never-export")
                  (:session . "py")
                  ;; (:session . "/tmp/kernel.json")
                  ))
  
  (org-babel-jupyter-override-src-block "python")
  ;; jupyter-python-args ends here
  ;; [[file:~/org/logical/org_babel.org::kernel-name-modeline][kernel-name-modeline]]
  (setq jupyter-current-buffer-kernel "zshot")
  (setq mode-line-misc-info
      '((t (concat "{" jupyter-current-buffer-kernel "}"))
       (pyvenv-mode pyvenv-mode-line-indicator)
       ("" so-long-mode-line-info)))
  
  (make-variable-buffer-local 'org-babel-default-header-args:python)
  ;; kernel-name-modeline ends here
  ;; [[file:~/org/logical/org_babel.org::jupyter-change-session][jupyter-change-session]]
  (defun jupyter-change-session ()
    (interactive)
    (let* ((jupyter-kernel-alist
            '(
              ("129" . "/ssh:129:/tmp/kernel.json")
              ("me" . "/ssh:me:/tmp/kernel.json")
              ("local" . "/tmp/kernel.json")
              ("zshot" . "zshot")
              ("usr" . "usr")
              ("pure" . "pure")))
           (kernel-list (mapcar #'car jupyter-kernel-alist))
           (kernel (completing-read "Select kernels: " kernel-list))
           (session (cdr (assoc kernel jupyter-kernel-alist))))
      (setq-local jupyter-current-buffer-kernel kernel)
      (setq-local org-babel-default-header-args:python
                  `((:eval . "never-export")
                    (:kernel . ,kernel)
                    (:session . ,session)))))
  ;; jupyter-change-session ends here
  ;; [[file:~/org/logical/org_babel.org::ob-jupyter-racket][ob-jupyter-racket]]
  (use-package racket-mode
    :config
    (setq org-babel-default-header-args:jupyter-racket
          '((:session . "jrack")
            (:display . "plain")
            (:kernel . "racket")))
  
    (org-babel-jupyter-override-src-block "racket")
  )
  ;; ob-jupyter-racket ends here
  ;; [[file:~/org/logical/org_babel.org::ob-jupyter-deno][ob-jupyter-deno]]
  (use-package typescript-mode
    :config
    (setq org-babel-default-header-args:jupyter-typescript
        '((:session . "deno-ts")
          (:display . "plain")
          (:kernel . "deno")))
  
    (org-babel-jupyter-override-src-block "typescript")
  )
  ;; ob-jupyter-deno ends here
  ;; [[file:~/org/logical/org_babel.org::tangle-block][tangle-block]]
  (defun tangle-current-block()
    (interactive)
    (let ((current-prefix-arg '(4)))
      (call-interactively 'org-babel-tangle)))
  
  (defun my/get-org-heading-id ()
    "Get the Org ID of the current heading."
    (save-excursion
      (org-back-to-heading t)
      (org-id-get)))
  
  (defun my/jump-to-tangled-target-block-by-id ()
    "Jump to the tangle target block in the target files."
    (interactive)
    (let ((id (my/get-org-heading-id))
          (files '("~/.wemacs/init.el" "~/metaesc/.config/i3/config")))
      (unless id
        (error "No Org ID found for the current heading"))
      (catch 'found
        (dolist (file files)
          (let ((buffer (find-file-noselect (expand-file-name file))))
            (with-current-buffer buffer
              (message (concat "search " file))
              (goto-char (point-min))
              (when (re-search-forward (concat ";; .*\\[\\[id:" id "\\]\\[") nil t)
                (switch-to-buffer buffer)
                (goto-char (point-min))
                (re-search-forward (concat ";; .*\\[\\[id:" id "\\]\\[") nil t)
                (throw 'found t)))))
        (error "ID not found in target files"))))
  
  (defun my/get-org-heading-name ()
    "Get the name of the current Org heading."
    (save-excursion
      (org-back-to-heading t)
      (let ((heading (org-get-heading t t t t)))
        ;; 提取纯文本标题部分，不包括 TODO 关键字、优先级和标签。
        (concat "*" (org-element-property :raw-value (org-element-at-point))))))
  
  (defun my/get-org-src-block-name ()
    "Get the name of the current Org source block."
    (save-excursion
      (unless (org-babel-where-is-src-block-head)
        (error "Not in a source block"))
      (org-babel-get-src-block-info 'light)
      (nth 4 (org-babel-get-src-block-info 'light))))
  
  (defun my/jump-to-tangled-target-block-by-name ()
    "Jump to the tangle target block by its name in the target files."
    (interactive)
    (let* ((name (or (my/get-org-src-block-name) (my/get-org-heading-name)))
           (file-path (abbreviate-file-name (or (buffer-file-name) "")))
           (search-key (concat file-path "::" name))
           (files '("~/.wemacs/init.el" "~/metaesc/.config/i3/config")))
      (unless name
        (error "No name found for the current source block or heading"))
      (catch 'found
        (dolist (file files)
          (let* ((expanded-file-name (expand-file-name file))
                 (buffer
                  (or (find-buffer-visiting expanded-file-name)
                      (find-file-noselect expanded-file-name))))
            (with-current-buffer buffer
              (goto-char (point-min))
              (when (re-search-forward (regexp-quote search-key) nil t)
                (switch-to-buffer-other-window buffer)
                (goto-char (point-min))
                (re-search-forward (regexp-quote search-key) nil t)
                (throw 'found t)))))
        (error "Name not found in target files"))))
  
  (defun jump-between-tangled-src-and-org-block ()
    "Jump to the corresponding block depending on the current mode."
    (interactive)
    (cond
     ((derived-mode-p 'org-mode)
      (my/jump-to-tangled-target-block-by-name))
     ((or (derived-mode-p 'prog-mode) (derived-mode-p 'conf-space-mode))
      (org-babel-tangle-jump-to-org))
     (t
      (message "Not in Org mode or a programming mode."))))
  ;; tangle-block ends here
  ;; [[file:~/org/logical/org_babel.org::babel-results-ansi-color][babel-results-ansi-color]]
  (defun ek/babel-ansi ()
    (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
      (save-excursion
        (goto-char beg)
        (when (looking-at org-babel-result-regexp)
          (let ((end (org-babel-result-end))
                (ansi-color-context-region nil))
            (ansi-color-apply-on-region beg end))))))
  (add-hook 'org-babel-after-execute-hook 'ek/babel-ansi)
  ;; babel-results-ansi-color ends here
  )
;; # org-babel ends here

;; # [[file:~/org/logical/org_note_taking.org::org-notes][org-notes]]
;; [[file:~/org/logical/org_note_taking.org::pdf-tools][pdf-tools]]
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-tools-install)
  :custom
  (pdf-annot-activate-created-annotations t "automatically annotate highlights")
  :config
  (setq mouse-wheel-follow-mouse t)
  (setq pdf-view-resize-factor 1.10)
  (setq-default pdf-view-display-size 'fit-width)
  (setq image-cache-eviction-delay 30) ; clear image cache after 30 sec, origin 300
  ;; (pdf-tools-install)

  (general-define-key
   :keymaps 'pdf-view-mode-map
   :states '(normal)
   "C-c C-g"  'pdf-sync-forward-search
   "o" 'pdf-history-backward
   "C-o" 'pdf-history-backward
   "C-t" 'pdf-history-backward
   "i" 'pdf-history-forward
   "C-i" 'pdf-history-forward
   "H" '(lambda () (interactive) (image-backward-hscroll 10))
   "L" '(lambda () (interactive) (image-forward-hscroll 10))
   "O" 'pdf-outline
   "C-c o" 'pdf-outline ;; same as outline in org/epub
   "d" 'pdf-view-scroll-up-or-next-page
   "b" 'pdf-view-scroll-down-or-previous-page
   "u" 'pdf-view-scroll-down-or-previous-page
   "gp" 'pdf-view-goto-page
   "C-f" 'pdf-view-next-page
   "C-b" 'pdf-view-previous-page
   "/" 'pdf-occur
   "C-s" 'isearch-forward
   )

  (general-define-key
   :keymaps 'pdf-occur-buffer-mode-map
   "M-RET" 'pdf-occur-view-occurrence
   )
  )

(use-package org-pdftools
  :hook (org-mode . org-pdftools-setup-link))
;; pdf-tools ends here
;; [[file:~/org/logical/org_note_taking.org::nov][nov]]
(use-package nov
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (defun my-nov-font-setup ()
    (face-remap-add-relative 'variable-pitch :height 1.25))
  (add-hook 'nov-mode-hook 'my-nov-font-setup)
  (setq nov-text-width 80)
  (add-hook 'nov-mode-hook 'visual-line-mode)
  (add-hook 'nov-mode-hook 'visual-fill-column-mode)

  (defun nov-scroll-up-half (arg)
    (interactive "P")
    (cond
     ((= (point) (point-max)) (nov-next-document))
     ((>= (window-end) (point-max)) (goto-char (point-max)))
     (t (scroll-up-line 15))))

  (defun nov-scroll-down-half (arg)
    (interactive "P")
    (cond
     ((= (point) (point-min)) 
      (nov-previous-document)
      (goto-char (point-max)))
     ((and (<= (window-start) (point-min))
           (> nov-documents-index 0))
      (goto-char (point-min)))
     (t (scroll-down-line 15))))

  (general-define-key
   :keymaps 'nov-mode-map
   :states '(normal)
   "C-c o" 'nov-goto-toc ;; same as outline in org/pdf
   "O" 'nov-goto-toc
   "o" 'nov-history-back
   "i" 'nov-history-forward
   "d" 'nov-scroll-up-half
   "u" 'nov-scroll-down-half)
  )
;; nov ends here
;; [[file:~/org/logical/org_note_taking.org::download][download]]
(use-package org-download
  :after org
  :defer nil
  :bind (:map org-mode-map
              ("C-M-y" . org-download-screenshot))
  :custom
  (org-download-method 'my-org-download-method)
  (org-download-annotate-function (lambda (_link) ""))
  (org-download-image-dir "imgs")
  (org-download-heading-lvl nil)
  (org-download-timestamp "%Y%m%d-%H%M%S_")
  (org-download-image-attr-list
      '("#+ATTR_HTML: :width 600 :align center"))
  :config
  (org-download-enable)
 )
;; download ends here
;; [[file:~/org/logical/org_note_taking.org::org-imagine][org-imagine]]
(use-package org-imagine
  :load-path "site-lisp/org-imagine/"
  :config
  (setq org-imagine-cache-dir "./.org-imagine"
        org-imagine-is-overwrite 1))
;; org-imagine ends here
;; [[file:~/org/logical/org_note_taking.org::org-latex][org-latex]]
(use-package org
  :ensure nil
  :custom
  (org-preview-latex-image-directory "/tmp/ltximg/")
  :config
  (setq org-latex-pdf-process '(
      "xelatex -interaction nonstopmode %f"
      "xelatex -interaction nonstopmode %f"))

  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
  (setq org-startup-with-latex-preview nil)
  (define-key org-mode-map (kbd "s-i") 'org-latex-preview) ;default C-c C-x l
  )

(use-package org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))
;; org-latex ends here
;; [[file:~/org/logical/org_note_taking.org::yasnippet-setting][yasnippet-setting]]
(use-package yasnippet
  :diminish yas-minor-mode
  :hook ((prog-mode LaTeX-mode org-mode markdown-mode) . yas-minor-mode)
  :init
  (use-package yasnippet-snippets)
  (setq yas-snippet-dirs '("~/.wemacs/snippets"))
  :general
  (defun my/insert-time ()
    (interactive)
    (insert (format-time-string "=%H:%M= ")) (evil-insert-state))

  (defun my/insert-now-date ()
    (interactive)
    (insert (format-time-string "[%Y-%m-%d %a %H:%M] ")) (evil-insert-state))

  (general-define-key
   :keymaps 'general-override-mode-map
   :states '(insert normal)
   "s-r s-w" 'my/insert-now-date
   "s-r s-e" 'my/insert-time
   "s-r s-s" 'yas-insert-snippet)
  )
;; yasnippet-setting ends here
;; [[file:~/org/logical/org_note_taking.org::ass-setting][ass-setting]]
(use-package aas
  :hook (LaTeX-mode . aas-activate-for-major-mode)
  :hook (org-mode . aas-activate-for-major-mode))

(setq org-format-latex-options
      '(:foreground default :background default :scale 1.5 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
                    ("begin" "$1" "$$" "\\(" "\\[")))

(use-package laas
  :hook (org-mode . laas-mode)
  :config
  ;; 自动插入空格
  (setq laas-enable-auto-space t)

  (aas-set-snippets
      'laas-mode
    ;; 只在 org latex 片段中展开
    :cond #'org-inside-LaTeX-fragment-p
    ;; 内积
    "<>" (lambda () (interactive)
           (yas-expand-snippet "\\langle $1\\rangle$0"))
    "`s" "^{\\star }"
    ;; 还可以绑定函数，用 yasnippet 展开
    "^" (lambda () (interactive)
          (yas-expand-snippet "^{$1}$0"))
    "_" (lambda () (interactive)
          (yas-expand-snippet "_{$1}$0"))
    "Sum" (lambda () (interactive)
            (yas-expand-snippet "\\sum_{$1}^{$2}$0"))
    "Int" (lambda () (interactive)
            (yas-expand-snippet "\\int_{$1}^{$2}$0"))
    "Prod" (lambda () (interactive)
             (yas-expand-snippet "\\prod_{$1}^{$2}$0"))
    "Sqrt" (lambda () (interactive)
             (yas-expand-snippet "\\sqrt[]{$1}"))
    "Gam" (lambda () (interactive)
            (yas-expand-snippet "\\Gamma($1)$0"))
    ;; 这是 laas 中定义的用于包裹式 latex 代码的函数，实现 \bm{a}
    :cond #'laas-object-on-left-condition
    "'B" (lambda () (interactive) (laas-wrap-previous-object "mathbb"))
    ",b" (lambda () (interactive) (laas-wrap-previous-object "boldsymbol"))
    ".d" (lambda () (interactive) (laas-wrap-previous-object "bm"))))
;; ass-setting ends here
;; [[file:~/org/logical/org_note_taking.org::org-roam][org-roam]]
(use-package org-roam
  :init
  (setq org-roam-directory "~/org/"
        org-id-link-to-org-use-id t
        org-roam-v2-ack t)
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "* ${title}\n :PROPERTIES:\n :ID: %(org-id-new)\n :#+CREATED: %U\n :END:\n%?\n"
           :target (file+olp "~/org/historical/entry.org" (""))
           :unnarrowed t)))
  :general
  (:keymaps 'normal 
            "s-r s-r" 'org-roam-buffer-toggle
            "s-r f"  'org-roam-find-file
            "s-r g"  'org-roam-node-find ;; graph node find
            )
  (:keymaps 'org-mode-map
            :states 'insert
            "s-r f" 'org-roam-insert-file
            "s-r g"  'org-roam-node-insert
            )
  :config
  (org-roam-db-autosync-mode)
  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:16}" 'face 'org-tag)))

  (defun org-roam-find-file ()
    (interactive)
    (org-roam-node-find nil nil (lambda (node)
                                  (= 0 (org-roam-node-level node)))))
  
  (defun org-roam-insert-file ()
    (interactive)
    (org-roam-node-insert (lambda (node)
                            (= 0 (org-roam-node-level node))))))
  
;; org-roam ends here
;; [[file:~/org/logical/org_note_taking.org::roam-ui][roam-ui]]
(use-package org-roam-ui
  :after org-roam
  :commands org-roam-ui-mode
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save nil
        org-roam-ui-open-on-start t)
  (add-to-list 'desktop-minor-mode-table
               '(org-roam-ui-mode nil))
  (add-to-list 'desktop-minor-mode-table
               '(org-roam-ui-follow-mode nil))
  )
;; roam-ui ends here
;; [[file:~/org/logical/org_note_taking.org::org-cite][org-cite]]
(use-package citar
  :bind (:map org-mode-map
              ("C-c r" . org-cite-insert))
  :custom
  (org-cite-global-bibliography '("~/org/lib/zotero.bib" "~/org/lib/manual.bib"))
  (citar-bibliography org-cite-global-bibliography)
  (org-cite-follow-processor 'citar) ;; open-at-point -> citar-at-point-function
  (org-cite-activate-processor 'citar)
  (citar-at-point-function 'embark-act) ;; -> citar-at-point-function -> citar-embark
  :hook
  (LaTeX-mode . citar-capf-setup)
  (org-mode . citar-capf-setup)
  :config 
  (setq citar-org-roam-capture-template-key "d"))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package citar-embark
  :after citar embark
  :no-require
  :config (citar-embark-mode))

(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (citar-org-roam-mode +1)) ;; this will setup roamdb

(defun my/open-roam-notes-advice (&rest _)
  (unless org-roam-db-autosync-mode
    (org-roam-db-autosync-mode 1)))

;; 确保在执行 org-citar-open-notes 前加载 org-roam, 这样才能使用 roamdb 查笔记
(advice-add 'citar-open-notes :before #'my/open-roam-notes-advice)

(defun my/org-open-at-point-cite-first ()
  "Check if `thing-at-point` contains `cite:` and call `org-cite-follow` if it does.
If found, copy the citation to a new temporary Org buffer and call `org-cite-follow`."
  (let ((tap-email (thing-at-point 'email)))
    (if (and tap-email (string-match "cite:" tap-email))
        (let ((temp-buffer (generate-new-buffer "*temp-org-citation-buffer*")))
          (with-current-buffer temp-buffer
            (org-mode)
            (insert (format "[%s]" tap-email))
            (goto-char (point-min))
            (let ((context (org-element-context)))
              (org-cite-follow context nil)))
          (kill-buffer temp-buffer)
          t)
      nil)))

(defun my/org-open-at-point-advice (orig-fun &rest args)
  "Advice to call `my/org-open-at-point-cite-first` before executing `org-open-at-point-global`."
  (unless (my/org-open-at-point-cite-first)
    (apply orig-fun args)))

(advice-add 'org-open-at-point-global :around #'my/org-open-at-point-advice)
;; org-cite ends here
;; # org-notes ends here

  ;; # [[file:~/org/logical/rss.org::elfeed-org][elfeed-org]]
  (use-package elfeed
      :defer t
    )
  
    (use-package elfeed-org ;;after
      :after elfeed
      :config
      (elfeed-org)
      (setq rmh-elfeed-org-files '("~/org/logical/rss.org"))
    )
  
  (setq elfeed-curl-extra-arguments '("--proxy" "socks5://127.0.0.1:1089"))
  ;; # elfeed-org ends here
;; org-mode environment:1 ends here

;; [[file:~/org/design/wemacs.org::*latex 环境][latex 环境:1]]
;; # [[file:~/org/logical/latex_ecosystem.org::auctex][auctex]]
;; from https://nasseralkmim.github.io/notes/2016/08/21/my-latex-environment/
(use-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (rainbow-delimiters-mode)
             ;; (company-mode) ;; conflict with cdlatex
              (smartparens-mode)
              (turn-on-reftex)
              (setq reftex-plug-into-AUCTeX t)
              (reftex-isearch-minor-mode)
              (setq TeX-PDF-mode t)
              (setq TeX-source-correlate-method 'synctex)
              (TeX-source-correlate-mode t)
              (setq TeX-source-correlate-start-server t)
              ;; use XeLaTeX to compile
              (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))
              (add-to-list 'TeX-command-list '("pdfLaTeX" "%`pdflatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))
              (setq TeX-command-default "XeLaTeX")


  ;; Update PDF buffers after successful LaTeX runs
  (add-hook 'TeX-after-TeX-LaTeX-command-finished-hook
            #'TeX-revert-document-buffer)

  ;; to use pdfview with auctex
  (add-hook 'LaTeX-mode-hook 'pdf-tools-install)

  ;; to use pdfview with auctex
  (setq TeX-view-program-selection '((output-pdf "pdf-tools"))
        TeX-source-correlate-start-server t)
  (setq TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view"))))))
;; # auctex ends here
;; # [[file:~/org/logical/latex_ecosystem.org::cdlatex][cdlatex]]
(use-package cdlatex
:config
(add-hook 'LaTeX-mode-hook 'turn-on-cdlatex)
;; (add-hook 'org-mode-hook 'turn-on-org-cdlatex)
)
;; # cdlatex ends here
;; # [[file:~/org/logical/latex_ecosystem.org::evil-tex][evil-tex]]
(use-package evil-tex
  :hook evil-tex-mode
  :config
  (define-key evil-tex-mode-map (kbd "M-.") #'evil-tex-brace-movement)
  )
;; # evil-tex ends here
;; # [[file:~/org/logical/latex_ecosystem.org::reftex][reftex]]
  (use-package reftex
    :ensure nil
    :defer t
    :config
    (setq reftex-cite-prompt-optional-args t)) ; Prompt for empty optional arguments in cite
;; # reftex ends here
;; # [[file:~/org/logical/latex_ecosystem.org::phrases][phrases]]
(use-package academic-phrases
  :commands academic-phrases
  )
;; # phrases ends here
;; latex 环境:1 ends here

;; [[file:~/org/design/wemacs.org::*gif showcast 等录制][gif showcast 等录制:1]]
(use-package gif-screencast
  :config
  (general-define-key
   :keymaps 'general-override-mode-map
   "C-c x" 'gif-screencast-start-or-stop))
;; gif showcast 等录制:1 ends here

;; [[file:~/org/design/wemacs.org::*阅读代码工具][阅读代码工具:2]]
(general-define-key
 :keymaps '(prog-mode-map)
 :states 'normal
 ;; "gd" 'evil-goto-definition
 "gr" 'xref-find-references ;go ref
 "gb" 'xref-pop-marker-stack ;goback
 )
;; 阅读代码工具:2 ends here

;; [[file:~/org/design/wemacs.org::*dumpjump][dumpjump:1]]
(use-package dumb-jump
  :bind ("C-]" . dumb-jump-go)
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))
;; dumpjump:1 ends here

;; [[file:~/org/design/wemacs.org::*缩进格式][缩进格式:1]]
(setq-default indent-tabs-mode nil)
(setq-default indent-line-function 'insert-tab)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default js-switch-indent-offset 4)
(c-set-offset 'comment-intro 0)
(c-set-offset 'innamespace 0)
(c-set-offset 'case-label '+)
(c-set-offset 'access-label 0)
(c-set-offset (quote cpp-macro) 0 nil)
(defun smart-electric-indent-mode ()
  "Disable 'electric-indent-mode in certain buffers and enable otherwise."
  (cond ((and (eq electric-indent-mode t)
              (member major-mode '(erc-mode text-mode)))
         (electric-indent-mode 0))
        ((eq electric-indent-mode nil) (electric-indent-mode 1))))
(add-hook 'post-command-hook #'smart-electric-indent-mode)
;; 缩进格式:1 ends here

;; [[file:~/org/design/wemacs.org::*缩进与空格][缩进与空格:1]]
(use-package aggressive-indent
:config
(add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
)
;; 缩进与空格:1 ends here

;; [[file:~/org/design/wemacs.org::*自动缩进][自动缩进:1]]
(use-package format-all
  :bind ("C-c f f" . format-all-buffer))
;; 自动缩进:1 ends here

;; [[file:~/org/design/wemacs.org::*快速运行程序][快速运行程序:1]]
(use-package quickrun
  :bind
  (("<f5>" . quickrun))
)
;; 快速运行程序:1 ends here

;; [[file:~/org/design/wemacs.org::*shell mode hook][shell mode hook:1]]
(add-to-list 'auto-mode-alist '("\\.sh\\'" . shell-script-mode))
;; shell mode hook:1 ends here

;; [[file:~/org/design/wemacs.org::*python 编程环境特定配置][python 编程环境特定配置:1]]
;; # [[file:~/org/logical/elpy.org::elpy-python-mode][elpy-python-mode]]
(use-package python-mode
  :ensure nil
  :init
  ;; [[file:~/org/logical/elpy.org::python-shell][python-shell]]
  (setq python-shell-interpreter "python"
        python-shell-interpreter-args "-i")
  ;; python-shell ends here
  ;; [[file:~/org/logical/elpy.org::jupyter-setup][jupyter-setup]]
  (add-hook 'python-shell-first-prompt-hook
            #'jupyter-python-shell-send-setup-code)
  
  (defun jupyter-python-shell-send-setup-code ()
    "Send all autorelaod code for jupyter shell."
    (when (equal python-shell-interpreter "jupyter")
      (let ((process (python-shell-get-process)))
        (python-shell-send-string "%load_ext autoreload" process)
        (python-shell-send-string "%autoreload 2" process))))
  ;; jupyter-setup ends here
  (setq python-indent-offset 4
        python-indent 4
        evil-indent-convert-tabs t
        indent-tabs-mode nil)
  
  :mode ("\\.py\\'" . python-mode)
  )
;; # elpy-python-mode ends here
;; # [[file:~/org/logical/elpy.org::elpy][elpy]]
(use-package elpy
  :init
  (advice-add 'python-mode :before 'elpy-enable)
  ;; :hook
  ;; (python-mode . elpy-enable)
  :commands python-mode 

  :config
  (setq elpy-eldoc-show-current-function nil) ;defalut t
  (setq elpy-rpc-backend "jedi")
  ;; [[file:~/org/logical/elpy.org::elpy-modules][elpy-modules]]
  (setq elpy-modules 
        '(elpy-module-sane-defaults elpy-module-company elpy-module-eldoc elpy-module-flymake elpy-module-highlight-indentation elpy-module-pyvenv elpy-module-yasnippet)
        )
  ;; elpy-modules ends here
  ;; [[file:~/org/logical/elpy.org::folding][folding]]
  (defun cycle-elpy-folding ()
    (interactive)
    (if (and (boundp 'elpy-all-folding) (= 1 elpy-all-folding))
        (setq elpy-all-folding 0)
      (setq elpy-all-folding 1)
      )
    (if (= 1 elpy-all-folding)
        (elpy-folding-hide-leafs)
      (hs-show-all)))
  ;; folding ends here
  ;; [[file:~/org/logical/elpy.org::pyvenv][pyvenv]]
  (setenv "WORKON_HOME" "/home/pipz/miniconda3/envs")
  (pyvenv-mode 1)
  (defalias 'conda-activate-elpy 'pyvenv-workon)
  (setq pyvenv-default-virtual-env-name "usr")
  (general-define-key
   :keymaps 'python-mode-map
   "s-j s-j" 'conda-activate-elpy
   )
  
  (setq elpy-rpc-python-command "python3")
  (setq elpy-rpc-virtualenv-path 'current)
  ;; pyvenv ends here
  ;; [[file:~/org/logical/elpy.org::elpy-checker][elpy-checker]]
  (setq elpy-syntax-check-command "flake8")
  ;; elpy-checker ends here
  
  ;; [[file:~/org/logical/elpy.org::elpy-test][elpy-test]]
    (setq elpy-test-discover-runner-command '("python3" "-m" "unittest"))
    (global-set-key (kbd "<f3>") 'recompile)
  ;; elpy-test ends here
  ;; [[file:~/org/logical/elpy.org::send-region-or-statement][send-region-or-statement]]
  (defun elpy-shell-send-region-or-statement-and-step (&optional arg)
    "Send the active region or the buffer to the Python shell and step.
  
  If there is an active region, send that. Otherwise, send the statement.
  ."
    (interactive "P")
    (if (use-region-p)
        (elpy-shell-send-region-or-buffer-and-step)
        (elpy-shell-send-statement-and-step)))
  ;; send-region-or-statement ends here
  ;; [[file:~/org/logical/elpy.org::jupyter-shell][jupyter-shell]]
  (setq python-shell-interpreter "jupyter"
        python-shell-interpreter-args "console --simple-prompt"
        python-shell-prompt-detect-failure-warning nil)
  (setq python-shell-completion-native-enable nil)
  ;; (setq python-shell-setup-codes '("\\%load_ext autoreload\n" "%autoreload 2"))
  (setq python-shell-setup-codes 'nil)
  ;; jupyter-shell ends here
  ;; [[file:~/org/logical/elpy.org::shell-send-binding][shell-send-binding]]
  (general-define-key
   :keymaps 'python-mode-map
   :states '(normal insert visual)
   "C-c C-c" 'elpy-shell-send-region-or-statement-and-step)
  (general-define-key
   :keymaps 'comint-mode-map
   :states '(normal insert)
   "RET" 'comint-send-input
   "C-j" 'comint-next-input
   "C-k" 'comint-previous-input)
  ;; shell-send-binding ends here
  ;; [[file:~/org/logical/elpy.org::elpy-project-shell][elpy-project-shell]]
  (advice-add 'elpy-shell-switch-to-shell :before (lambda () 
                                                    (elpy-shell-set-local-shell (elpy-project-root))))
  
  (advice-add 'python-shell-send-string :before (lambda (STRING &optional PROCESS MSG) 
                                                  (elpy-shell-set-local-shell (elpy-project-root))))
  
  (setq elpy-shell-display-buffer-after-send t ;;
        elpy-shell-echo-output nil) ;; don't show output in echo
  ;; elpy-project-shell ends here
  ;; [[file:~/org/logical/elpy.org::elpy-reformat][elpy-reformat]]
  (general-define-key
   :keymaps 'python-mode-map
   "M-d" 'elpy-multiedit-python-symbol-at-point
   "C-c b" 'elpy-format-code
   )
  ;; elpy-reformat ends here
)
;; # elpy ends here
;; python 编程环境特定配置:1 ends here

;; [[file:~/org/design/wemacs.org::*scheme env][scheme env:1]]
(use-package info
  :init
  (add-to-list 'Info-directory-list "/data/resource/readings/manual/sicp")
  :config
  (general-define-key
   :keymaps 'Info-mode-map
   :states '(normal)
   "d"  'Info-scroll-up
   "u"  'Info-scroll-down
   "O"  'Info-top-node
   )
  )
;; scheme env:1 ends here

;; [[file:~/org/design/wemacs.org::*scheme env][scheme env:2]]
(use-package geiser-mit
  :config
  (setq geiser-active-implementations '(mit)) 
  (setq geiser-repl-skip-version-check-p 't)
  )
;; scheme env:2 ends here

;; [[file:~/org/design/wemacs.org::*scheme env][scheme env:3]]
(use-package paredit
  :diminish paredit-mode
  :config
  (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
  ;; enable in the *scratch* buffer
  (add-hook 'scheme-mode-hook #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'paredit-mode)
  (add-hook 'ielm-mode-hook #'paredit-mode)
  (add-hook 'lisp-mode-hook #'paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'paredit-mode)
  )
;; scheme env:3 ends here

;; [[file:~/org/design/wemacs.org::*yaml][yaml:1]]
(use-package yaml-mode
  :mode ("\\.yaml$" . yaml-mode)
  )
;; yaml:1 ends here

;; [[file:~/org/design/wemacs.org::*solidity][solidity:1]]
(use-package solidity-mode
  :mode ("\\.sol" . solidity-mode)
  )
;; solidity:1 ends here

;; [[file:~/org/design/wemacs.org::*web-mode][web-mode:1]]
(use-package web-mode
  :mode ("\\.html$" . web-mode)
  :hook ((web-mode . smartparens-mode)
         (web-mode . my-web-mode-hook))
  :config
  (setq web-mode-markup-indent-offset 2)  ; web-mode, html tag in html fil
  (setq web-mode-css-indent-offset 2)     ; web-mode, css in html file
  (setq web-mode-code-indent-offset 2)    ; web-mode, js code in html file
  (setq js-indent-level 2)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-expanding t)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-current-column-highlight t)
  (setq web-mode-enable-current-element-highlight t) ; like paren-mode

  (defun my-web-mode-hook ()
    (set (make-local-variable 'company-backends) '(company-css company-web-html company-yasnippet company-files))
    )
  )
;; web-mode:1 ends here

;; [[file:~/org/design/wemacs.org::*basic][basic:1]]
(use-package term
  :ensure nil
  :defer
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args
  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^ >_*"))
;; basic:1 ends here

;; [[file:~/org/design/wemacs.org::*better term-mode colors][better term-mode colors:1]]
(use-package eterm-256color
  :hook (term-mode . 'eterm-256color-mode)
)
;; better term-mode colors:1 ends here

;; [[file:~/org/design/wemacs.org::init-eaf][init-eaf]]
(use-package eaf
  ;; :load-path "~/.wemacs/site-lisp/eaf"
  :commands eaf-open-mindmap
  :load-path "site-lisp/emacs-application-framework/"
  :config
  ;; # [[file:~/org/logical/eaf.org::mindmap][mindmap]]
  (require 'eaf-mindmap)
  ;; # mindmap ends here

  (evil-set-initial-state 'eaf-mode 'emacs)
  (add-to-list 'evil-insert-state-modes 'eaf-edit-mode)

  (defun eaf-insert-or-comma ()
    (interactive)
    (if eaf-buffer-input-focus
        (eaf-py-proxy-insert_or_zoom_in)
      (main-hydra/body)))

  (defun eaf-insert-or-space ()
    (interactive)
    (if eaf-buffer-input-focus
        (eaf-py-proxy-insert_or_zoom_in)
      ;; (ivy-switch-buffer-tab-win)
      (ivy-switch-buffer)))

  (defun eaf-insert-or-q ()
    (interactive)
    (if eaf-buffer-input-focus
        (eaf-py-proxy-insert_or_zoom_in)
      ;; (switch-back-buffer-or-view)
      (my/switch-back)))

  ;; browser binding
  ;; (eaf-bind-key insert_or_scroll_left "l" eaf-browser-keybinding)
  ;; (eaf-bind-key insert_or_scroll_right "h" eaf-browser-keybinding)
  ;; (eaf-bind-key clear_focus "<escape>" eaf-browser-keybinding)
  ;; (eaf-bind-key atomic_edit "M-o" eaf-browser-keybinding)
  ;; (eaf-bind-key eaf-insert-or-comma "," eaf-browser-keybinding)
  ;; (eaf-bind-key eaf-insert-or-space "SPC" eaf-browser-keybinding)
  ;; (eaf-bind-key eaf-insert-or-q "q" eaf-browser-keybinding)

  ;; mindmap binding
  (eaf-bind-key insert_or_remove_node "x" eaf-mindmap-keybinding)
  (eaf-bind-key jump_to_keywords "RET" eaf-mindmap-keybinding)
  (eaf-bind-key jump_to_keywords "M-RET" eaf-mindmap-keybinding)
  (eaf-bind-key add_brother_node "TAB" eaf-mindmap-keybinding)
  (eaf-bind-key insert_or_update_node_topic "i" eaf-mindmap-keybinding)
  (eaf-bind-key insert_or_update_node_topic "a" eaf-mindmap-keybinding)
  (eaf-bind-key update_node_topic "M-i" eaf-mindmap-keybinding)
  (eaf-bind-key update_node_topic "M-DEL" eaf-mindmap-keybinding)
  (eaf-bind-key add_sub_node "o" eaf-mindmap-keybinding)
  (eaf-bind-key eaf-insert-or-space "SPC" eaf-mindmap-keybinding)
  (eaf-bind-key eaf-insert-or-comma "," eaf-mindmap-keybinding)
  (eaf-bind-key eaf-insert-or-q "q" eaf-mindmap-keybinding)
  (eaf-bind-key insert_or_copy_node_topic "y" eaf-mindmap-keybinding)
  (eaf-bind-key insert_or_paste_node_topic "p" eaf-mindmap-keybinding)
  (eaf-bind-key insert_or_save_file "W" eaf-mindmap-keybinding)
  (eaf-bind-key windmove-down "M-j" eaf-mindmap-keybinding)
  (eaf-bind-key windmove-up "M-k" eaf-mindmap-keybinding)
  (eaf-bind-key windmove-left "M-h" eaf-mindmap-keybinding)
  (eaf-bind-key windmove-right "M-l" eaf-mindmap-keybinding)

  (defun my/open-mindmap ()
    "Open mindmap in a new window if there is only one window, or in other window if multiple windows are present."
    (interactive)
    (let ((current-buffer (current-buffer)))
      (if (= (length (window-list)) 1)
          (progn
            (split-window-right) ;; Split window right and move to new window
            (other-window 1))
        (other-window 1))   ;; Just move to other window if more than one window present
      (set-window-buffer nil current-buffer) ;; Set the buffer of new/other window to current buffer
      (eaf-open-mindmap buffer-file-name))) ;; Open mindmap of the current buffer

  ;; redefine this function
  (defun eaf-open-this-buffer ()
    "Try to open the current buffer using EAF, if possible."
    (interactive)
    (cond ((eaf--buffer-file-p)  (eaf-open buffer-file-name))
          ((or (eq major-mode 'org-mode)
               (eq major-mode 'markdown-mode))
           (my/open-mindmap))
          (t (user-error "[EAF] Current buffer is not supported by EAF!"))))
  )
;; init-eaf ends here
(put 'list-timers 'disabled nil)
