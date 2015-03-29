(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/etc")

;; Set up package manager
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(setq package-enable-at-startup nil)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; Load local "packages"
(require 'unannoy)
(require 'imgur)
(require 'extras)
(require 'utility)

;; Some global keybindings
(global-set-key (kbd "C-S-j") 'join-line)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-x\C-k" 'compile)
(global-set-key [f5] (expose #'revert-buffer nil t))

;;; auto-mode-alist entries
(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))
(add-to-list 'auto-mode-alist '("\\.mom$" . nroff-mode))
(add-to-list 'auto-mode-alist '("[._]bash.*" . shell-script-mode))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("[Mm]akefile" . makefile-gmake-mode))

;;; Individual package configurations

(use-package dabbrev
  :config (setf dabbrev-case-fold-search nil))

(use-package impatient-mode
  :defer t
  :ensure t)

(use-package lua-mode
  :defer t
  :ensure t)

(use-package memoize
  :defer t
  :ensure t)

(use-package dired
  :config (add-hook 'dired-mode-hook #'toggle-truncate-lines))

(use-package message
  :defer t
  :config (define-key message-mode-map "C-c C-s" nil)) ; super annoying

(use-package notmuch
  :ensure t
  :bind ("C-x m" . notmuch)
  :functions notmuch-address-message-insinuate
  :config
  (progn
    (require 'email-setup)
    (require 'notmuch-address)
    (setf notmuch-command "notmuch-remote"
          message-send-mail-function 'smtpmail-send-it
          message-kill-buffer-on-exit t
          smtpmail-smtp-server "localhost"
          smtpmail-smtp-service 2525
          notmuch-address-command "addrlookup-remote"
          notmuch-fcc-dirs nil
          notmuch-search-oldest-first nil
          notmuch-archive-tags '("-inbox" "-unread" "+archive")
          hashcash-path (executable-find "hashcash"))
    (notmuch-address-message-insinuate)
    (custom-set-faces
     '(notmuch-search-subject ((t :foreground "#afa")))
     '(notmuch-search-date    ((t :foreground "#aaf")))
     '(notmuch-search-count   ((t :foreground "#777"))))
    (setq notmuch-hello-sections
          '(notmuch-hello-insert-header
            notmuch-hello-insert-saved-searches
            notmuch-hello-insert-search))))

(use-package elfeed
  :ensure t
  :bind ("C-x w" . elfeed)
  :config (require 'feed-setup))

(use-package lisp-mode
  :config
  (progn
    (defun ert-all ()
      (interactive)
      (ert t))
    (defun ielm-repl ()
      (interactive)
      (pop-to-buffer (get-buffer-create "*ielm*"))
      (ielm))
    (define-key emacs-lisp-mode-map "C-x r"   'ert-all)
    (define-key emacs-lisp-mode-map "C-c C-z" 'ielm-repl)
    (define-key emacs-lisp-mode-map "C-c C-k" 'eval-buffer*)
    (defalias 'lisp-interaction-mode 'emacs-lisp-mode)
    (font-lock-add-keywords
     'emacs-lisp-mode
     `((,(concat "(\\(\\(?:\\(?:\\sw\\|\\s_\\)+-\\)?"
                 "def\\(?:\\sw\\|\\s_\\)*\\)\\_>"
                 "\\s-*'?" "\\(\\(?:\\sw\\|\\s_\\)+\\)?")
        (1 'font-lock-keyword-face)
        (2 'font-lock-function-name-face nil t)))
     :low-priority)
    (font-lock-add-keywords
     'emacs-lisp-mode
     '(("(\\(use-package\\)\\_>\\s-*\\(\\(?:\\sw\\|\\s_\\)+\\)?"
        (1 'font-lock-keyword-face)
        (2 'font-lock-function-name-face nil t)))
     :low-priority)))

(use-package time
  :config
  (progn
    (setf display-time-default-load-average nil
          display-time-use-mail-icon t
          display-time-24hr-format t)
    (display-time-mode t)))

(use-package comint
  :config
  (progn
    (define-key comint-mode-map "<down>" 'comint-next-input)
    (define-key comint-mode-map "<up>" 'comint-previous-input)
    (define-key comint-mode-map "C-n" 'comint-next-input)
    (define-key comint-mode-map "C-p" 'comint-previous-input)
    (define-key comint-mode-map "C-r" 'comint-history-isearch-backward)
    (setf comint-prompt-read-only t
          comint-history-isearch t)))

(use-package tramp
  :defer t
  :config
  (setf tramp-persistency-file-name
        (concat temporary-file-directory "tramp-" (user-login-name))))

(use-package whitespace-cleanup
  :config (setq-default indent-tabs-mode nil))

(use-package diff-mode
  :defer t
  :config
  (progn
    (add-hook 'diff-mode-hook #'toggle-whitespace-cleanup)
    (add-hook 'diff-mode-hook #'read-only-mode)))

(use-package simple
  :defer t
  :config
  (progn
    ;; disable so I don't use it by accident
    (define-key visual-line-mode-map (kbd "M-q") (expose (lambda ())))
    (add-hook 'tabulated-list-mode-hook #'hl-line-mode)))

(use-package uniquify
  :config
  (setf uniquify-buffer-name-style 'post-forward-angle-brackets))

(use-package winner
  :config
  (progn
    (winner-mode 1)
    (windmove-default-keybindings)))

(use-package calc
  :defer t
  :config (setf calc-display-trail nil))

(use-package eshell
  :bind ([f1] . eshell-as)
  :config
  (add-hook 'eshell-mode-hook ; Bad, eshell, bad!
            (lambda () (define-key eshell-mode-map [f1] 'quit-window))))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :config
  (progn
    (setf vc-display-status nil)
    (add-hook 'git-commit-mode-hook
              (lambda () (when (looking-at "\n") (open-line 1))))
    (defadvice git-commit-commit (after delete-window activate)
      (delete-window))))

(use-package markdown-mode
  :ensure t
  :mode ("\\.md$" "\\.markdown$" "pentadactyl\\.[[:alnum:].]+\\.txt$")
  :config
  (progn
    (defun markdown-nobreak-p () nil)
    (setf sentence-end-double-space nil)))

(use-package simple-httpd
  :ensure t
  :defer t
  :functions httpd-send-header
  :config
  (progn
    (defservlet uptime "text/plain" ()
      (princ (emacs-uptime)))
    (defun httpd-here ()
      (interactive)
      (setf httpd-root default-directory))
    (defadvice httpd-start (after httpd-query-on-exit-flag activate)
      (let ((httpd-process (get-process "httpd")))
        (when httpd-process
          (set-process-query-on-exit-flag httpd-process nil))))))

(use-package jekyll
  :demand t
  :functions httpd-send-header
  :config
  (progn
    (setf jekyll-home "~/src/skeeto.github.com/")
    (when (file-exists-p jekyll-home)
      (require 'simple-httpd)
      (setf httpd-root (concat jekyll-home "_site"))
      (ignore-errors
        (httpd-start)
        (jekyll/start))
      (defservlet robots.txt text/plain ()
        (insert "User-agent: *\nDisallow: /\n")))))

(use-package js2-mode
  :ensure t
  :mode "\\.js$"
  :config
  (progn
    (add-hook 'js2-mode-hook (lambda () (setq mode-name "js2")))
    (setf js2-skip-preprocessor-directives t)
    (setq-default js2-additional-externs
                  '("$" "unsafeWindow" "localStorage" "jQuery"
                    "setTimeout" "setInterval" "location" "skewer"
                    "console" "phantom"))))

(use-package skewer-mode
  :ensure t
  :defer t
  :init (skewer-setup)
  :config
  (define-key skewer-mode-map (kbd "C-c $")
    (expose #'skewer-bower-load "jquery" "1.9.1")))

(use-package skewer-repl
  :defer t
  :config (define-key skewer-repl-mode-map (kbd "C-c C-z") #'quit-window))

(use-package clojure-mode
  :ensure t
  :mode "\\.cljs$")

(use-package cider
  :ensure t
  :defer t
  :config
  (progn
    (defadvice cider-popup-buffer-display (after cider-focus-errors activate)
      "Focus the error buffer after errors, like Emacs normally does."
      (select-window (get-buffer-window cider-error-buffer)))
    (defadvice cider-eval-last-sexp (after cider-flash-last activate)
      (flash-region (save-excursion (backward-sexp) (point)) (point)))
    (defadvice cider-eval-defun-at-point (after cider-flash-at activate)
      (apply #'flash-region (cider--region-for-defun-at-point)))))

(use-package ps-print
  :defer t
  :config (setf ps-print-header nil))

(use-package glsl-mode
  :ensure t
  :mode ("\\.fs$" "\\.vs$"))

(use-package erc
  :defer t
  :config
  (when (eq 0 (string-match "wello" (user-login-name)))
    (setf erc-nick "skeeto")))

(use-package cc-mode
  :defer t
  :config
  (progn
    (define-key java-mode-map (kbd "C-x I") #'add-java-import)
    (setcdr (assq 'c-basic-offset (cdr (assoc "k&r" c-style-alist))) 4)
    (add-to-list 'c-default-style '(c-mode . "k&r"))))

(use-package google-c-style
  :ensure t
  :defer t
  :init (add-hook 'c++-mode-hook #'google-set-c-style))

(use-package ielm
  :config
  (progn
    (define-key ielm-map (kbd "C-c C-z") #'quit-window)
    (defadvice ielm-eval-input (after ielm-paredit activate)
      "Begin each ielm prompt with a paredit pair."
      (paredit-open-round))))

(use-package paredit
  :ensure t
  :defer t
  :init
  (progn
    (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
    (add-hook 'lisp-mode-hook #'paredit-mode)
    (add-hook 'scheme-mode-hook #'paredit-mode)
    (add-hook 'ielm-mode-hook #'paredit-mode)
    (add-hook 'clojure-mode-hook #'paredit-mode)))

(use-package paren
  :config (show-paren-mode))

(use-package parenface
  :ensure t
  :config
  (progn
    (set-face-foreground 'parenface-paren-face "snow4")
    (set-face-foreground 'parenface-bracket-face "DarkGray")
    (set-face-foreground 'parenface-curly-face "DimGray")))

(use-package ido-vertical-mode
  :ensure t
  :config (ido-vertical-mode 1))

(use-package ido-ubiquitous
  :ensure t
  :config
  (progn
    (ido-mode 1)
    (ido-ubiquitous-mode)
    (setf ido-enable-flex-matching t
          ido-show-dot-for-dired t
          ido-save-directory-list-file nil
          ido-everywhere t
          ido-ubiquitous-enable-compatibility nil)))

(use-package smex
  :ensure t
  :init (smex-initialize)
  :bind ("M-x" . smex))

(use-package custom
  :config
  (progn
    (load-theme 'wombat t)
    (setf frame-background-mode 'dark)
    ;; Fix broken faces between Wombat, Magit, and Notmuch
    (custom-set-faces
     '(diff-added           ((t :foreground "green")))
     '(diff-removed         ((t :foreground "red")))
     '(highlight            ((t (:background "black"))))
     '(magit-item-highlight ((t :background "black")))
     '(hl-line              ((t :background "gray10"))))))

(use-package javadoc-lookup
  :ensure t
  :bind ("C-h j" . javadoc-lookup)
  :config
  (ignore-errors
    (javadoc-add-artifacts
     [org.lwjgl.lwjgl lwjgl "2.8.2"]
     [com.nullprogram native-guide "0.2"]
     [junit junit "4.10"]
     [org.projectlombok lombok "0.10.4"]
     [org.mockito mockito-all "1.9.0"]
     [com.beust jcommander "1.25"]
     [com.google.guava guava "12.0"]
     [org.jbox2d jbox2d-library "2.1.2.2"]
     [org.apache.commons commons-math3 "3.0"]
     [org.pcollections pcollections "2.1.2"]
     [org.xerial sqlite-jdbc "3.7.2"]
     [com.googlecode.lanterna lanterna "2.1.2"]
     [joda-time joda-time "2.1"]
     [org.apache.lucene lucene-core "3.3.0"])))

(use-package browse-url
  :defer t
  :config
  (when (executable-find "firefox")
    (setf browse-url-browser-function #'browse-url-firefox)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-e" . mc/edit-lines)
         ("C-<" . mc/mark-previous-like-this)
         ("C->" . mc/mark-next-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package graphviz-dot-mode
  :ensure t
  :defer t
  :config
  (setf graphviz-dot-indent-width 2
        graphviz-dot-auto-indent-on-semi nil))

(use-package uuid-simple
  :demand t
  :bind ("C-x !" . uuid-insert)
  :config (random (make-uuid)))

(use-package compile-bind
  :demand t
  :bind (("C-h g" . compile-bind-set-command)
         ("C-h G" . compile-bind-set-root-file))
  :config
  (progn
    (setf compilation-always-kill t
          compilation-scroll-output 'first-error)
    (compile-bind* (current-global-map)
                   ("C-x c" ""
                    "C-x r" 'run
                    "C-x t" 'test
                    "C-x C" 'clean))))

(use-package batch-mode
  :defer t)

(use-package yaml-mode
  :ensure t
  :config
  (add-hook 'yaml-mode-hook
            (lambda ()
              (setq-local paragraph-separate ".*>-$\\|[   ]*$")
              (setq-local paragraph-start paragraph-separate))))

(use-package help-mode
  :config
  (define-key help-mode-map "f" 'push-first-button))

;; Cygwin compatibility

(let ((cygwin-root "c:/cygwin64"))
  (when (file-directory-p cygwin-root)
    (setenv "PATH" (concat cygwin-root "/bin" ";" (getenv "PATH")))
    (push (concat cygwin-root "/bin") exec-path)
    (setf shell-file-name "bash.exe")
    ;; Translate paths for Cygwin Git
    (defadvice magit-expand-git-file-name
        (before magit-expand-git-file-name-cygwin activate)
      (save-match-data
        (when (string-match "^/cygdrive/\\([a-z]\\)/\\(.*\\)" filename)
          (let ((drive (match-string 1 filename))
                (path (match-string 2 filename)))
            (setf filename (concat drive ":/" path))))))))

;; Compile configuration
(byte-recompile-directory "~/.emacs.d/lisp/" 0)
(byte-recompile-directory "~/.emacs.d/etc/" 0)
(byte-recompile-file "~/.emacs.d/init.el" nil 0)

(provide 'init) ; make (require 'init) happy
