;;; early-init.el --- Early initialization. -*- lexical-binding: t -*-

;; copy from: https://github.com/seagle0128/.emacs.d

;;; Commentary:
;;
;; Emacs 27 introduces early-init.el, which is run before init.el,
;; before package and UI initialization happens.
;;

;;; Code:

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum)

;; Package initialize occurs automatically, before `user-init-file' is
;; loaded, but after `early-init-file'. We handle package
;; initialization, so we must prevent Emacs from doing it early!
; (setq package-enable-at-startup nil)


;; Inhibit resizing frame
(setq frame-inhibit-implied-resize t)

;;Unset file-name-handler-alist
;; Every file opened and loaded by Emacs will run through this list to check for a proper handler for the file, but during startup, it won’t need any of them.
(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq site-run-file nil)

;; Faster to disable these here (before they've been initialized)
(if (eq system-type 'gnu/linux)
  (menu-bar-mode -1)
)

;; 取消工具栏， 左右边距, 放在 init 会加载包导致速度更慢
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
;; hide scroll bar
(push '(vertical-scroll-bars) default-frame-alist)
(when (featurep 'ns)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

(setq custom-file (concat user-emacs-directory "customizations.el"))
(when (file-exists-p custom-file) (load custom-file 't))

(setq native-comp-async-report-warnings-errors nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; early-init.el ends here
