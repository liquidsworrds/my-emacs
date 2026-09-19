;;; init.el --- Emacs config -*- lexical-binding: t -*-

(fringe-mode nil)
(menu-bar-mode 0)
(tool-bar-mode 0)
(show-paren-mode 1)
(scroll-bar-mode 0)
(blink-cursor-mode 0)
(column-number-mode 1)
(global-subword-mode 1)

(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'text-mode-hook #'hl-line-mode)

;; Window Split
(setq split-height-threshold nil) ;; prefer vertical splits
(setq split-width-threshold 80)

(recentf-mode 1)
(save-place-mode 1)

(setq auto-save-default nil)
(setq make-backup-files nil)

(defalias 'yes-or-no-p 'y-or-n-p)

(define-key key-translation-map (kbd "C-SPC") (kbd "C-x"))

;; Default Font
(set-face-attribute 'default nil :font "Fira Code Retina" :height 150)

;; (set-frame-parameter 'fullscreen 'fullboth)

;; Line number
(defun my/set-line-numbers()
  "Set line number."
  (interactive)
  (setq-local display-line-numbers-type 'relative)
  (display-line-numbers-mode 1))

(add-hook 'prog-mode-hook 'my/set-line-numbers)

;; C settings
(setq c-basic-style "stroustrup")
(setq c-basic-indent 4)
(setq c-basic-offset 4)

;; Debugging
(setq gdb-enable-debug t)
(setq gdb-many-windows t)
(setq gdb-show-main t)

;; Color Column
(setq-default fill-colum 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

;; Text Wrapping
(add-hook 'text-mode-hook 'auto-fill-mode)

;; Autopair
(electric-pair-mode 1)

;; Auto refresh buffers when there is a change
(global-auto-revert-mode 1)

(setq inhibit-startup-message t)
(setq inhibit-startup-screen nil)

(defun my/reset-variable(symbl)
  "Reset symbl to its standard value."
  (set symbl (eval (car (get symbl 'standard-value)))))

(setq read-extended-command-predicate #'command-completion-default-include-p)

;; Get rid of prompt to confirm killing a buffer with a live process
(setq kill-buffer-query-functions
  (remq 'process-kill-buffer-query-function
         kill-buffer-query-functions))

(setq use-dialog-box nil)
(setq global-auto-revert-non-file-buffers t)
(setq bidi-inhibit-bpa t)
(setq redisplay-skip-fontification-on-input t)
(setq read-process-output-max (* 4 1024 1024))
(setq kill-do-not-save-duplicates t)
(setq help-window-select t)

(add-hook 'calendar-today-visible-hook 'calendar-mark-today)
(add-hook 'calendar-today-visible-hook 'calendar-mark-holidays)

(modify-all-frames-parameters '((right-divider-width . 6)))

(global-set-key (kbd "C-x C-b") 'ibuffer)

(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")

;; Stops the need for double escaping regex
(setq reb-re-syntax 'string)

(setq custom-file (locate-user-emacs-file ".custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;; (setq backup-directory-alist '((".", "~/.emacs_saves")))
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq indent-line-function 'insert-tab)
(setq tab-always-indent 'complete)
(setq tab-always-indent t)

;; Compile
(setq compilation-scroll-output 'first-error)
(global-set-key (kbd "<f9>") 'recompile)
(setq compilation-finish-functions
      (list (lambda (buf status)
              (when (string-match-p "finished" status)
                (run-at-time 1 nil #'delete-windows-on buf)))))

(defun display-startup-echo-area-message ()
  "Don't display \"For more information about GNU Emacs and the GNU system, type C-h C-a\" message in the minibuffer during startup"
  (message ""))

;; Startup debug use-package stats
(setq use-package-compute-statistics t)
(setq use-package-verbose t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(use-package evil
  :ensure t
  :custom ((evil-undo-system 'undo-redo)
           (evil-want-keybinding nil)
           (evil-shift-width 2))
  :config
  (evil-set-initial-state 'calfw-calendar-mode 'emacs)
  (evil-define-key 'normal 'global(kbd "S-SPC") 'evil-scroll-up)
  :init
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :init
  (evil-collection-init))

;; Themes
;; (add-hook 'emacs-startup-hook
;;           (lambda() (load-theme 'ef-maris-dark t)))

(load-theme 'modus-vivendi t)
(use-package ef-themes
  :ensure t
  :custom
  (modus-themes-to-toggle '(ef-dark ef-light)))

;; (use-package tokyo-night
;;   :ensure t)

(global-set-key (kbd "<f5>") 'ef-themes-toggle)

(use-package mood-line
  :ensure t
  :defer t
  :custom
  (mood-line-glyph-alist mood-line-glyphs-fira-code)
  (setq mood-line-glyph-alist mood-line-glyphs-unicode)
  :init
  (mood-line-mode))

;; LSP
(use-package lsp-mode
  :ensure t
  :defer t
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-diagnostics-provider :flycheck)
  (setq lsp-enable-on-type-formatting nil)
  :custom
  (lsp-warn-no-matched-clients nil)
  (lsp-completion-provider :none)
  :hook ((prog-mode-hook . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands
  (lsp lsp-deferred))

;; Breadcrumb icons require treemacs and lsp-treemacs for some reason

(use-package lsp-ui
  :ensure t
  :defer t
  :custom
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-delay 1)
  (lsp-ui-sideline-update-mode 'line)
  :after lsp-mode)

;; Godot
(use-package gdscript-mode
  :ensure t
  :mode "\\.gd\\'")

(add-to-list 'major-mode-remap-alist
             '(gdscript-mode . gdscript-ts-mode))

(defun lsp--gdscript-ignore-errors (original-function &rest args)
  "Ignore the error message resulting from Godot not replying to the `JSONRPC' request."
  (if (string-equal major-mode "gdscript-ts-mode")
      (let ((json-data (nth 0 args)))
        (if (and (string= (gethash "jsonrpc" json-data "") "2.0")
                 (not (gethash "id" json-data nil))
                 (not (gethash "method" json-data nil)))
            nil ; (message "Method not found")
          (apply original-function args)))
    (apply original-function args)))
;; Runs the function `lsp--gdscript-ignore-errors` around `lsp--get-message-type` to suppress unknown notification errors.
(advice-add #'lsp--get-message-type :around #'lsp--gdscript-ignore-errors)

(use-package flycheck
  :ensure t
  :defer t
  :after lsp-mode
  :custom
  (flycheck-display-errors-delay 0.9))

(use-package which-key
  :ensure t
  :defer 2
  :custom
  (which-key-idle-delay 2)
  :config
  (which-key-mode))

(use-package nerd-icons-corfu
  :ensure t
  :defer t
  :after corfu)

(use-package corfu
  :ensure t
  :defer t
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu--preview-current nil)
  (corfu-popupinfo-mode nil)
  (corfu-on-exact-match 'insert)
  (corfu-quit-no-match 'separator)
  ;;(corfu-echo-documentation 0.25)
  (corfu-margin-formatters '(nerd-icons-corfu-formatter))
  :bind
  (:map corfu-map
        ("M-TAB" . corfu-expand)
        ("C-n"   . corfu-next)
        ("C-p"   . corfu-previous)
        ("RET"   . nil)
        ("M-RET" . insert)
        ("M-d"   . corfu-info-documentation)
        ("M-l"   . corfu-info-location))
  :config
  ;;(setq corfu-popupinfo-delay '(1.25 . 0.5))
  :hook
  (after-init  . corfu-mode)
  (prog-mode   . corfu-mode)
  (shell-mode  . corfu-mode)
  (eshell-mode . corfu-mode))

(use-package cape
  :ensure t
  :defer
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package yasnippet
  :ensure t
  :config
  (yas-reload-all)
  :hook
  (prog-mode . yas-minor-mode))

(use-package yasnippet-snippets
  :ensure t)

(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  (vertico-reverse-mode t)
  :init (vertico-mode))

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless partial-completion basic))
  (completion-category-defaults nil)
  (completion-category-overrides nil))

(use-package consult
  :ensure t
  :bind
  ("C-x b" . consult-buffer)
  ("M-s g" . consult-grep)
  ("M-s f" . consult-find)
  ("M-s l" . consult-line))

(use-package helpful
  :ensure t
  :bind
  ("C-h f" . helpful-callable)
  ("C-h v" . helpful-variable)
  ("C-h k" . helpful-key)
  ("C-h x" . helpful-command))

(use-package savehist
  :ensure t
  :init (savehist-mode))

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package magit
  :ensure t
  :defer t
  :commands magit-status)

(use-package vterm
  :ensure t
  :bind (("C-x t" . vterm)
         (:map vterm-mode-map
               ("M-j" . scroll-up-command)
               ("M-k" . scroll-down-command)))
  :commands vterm)

(use-package expand-region
  :ensure t
  :bind (("C-=" . er/expand-region)
         ("C--" . er/contract-region)))

(use-package multiple-cursors
  :ensure t
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-c C->" . mc/mark-all-like-this)))

(use-package indent-bars
  :ensure t
  :hook (prog-mode-hook . indent-bars-mode)
  :custom
  (indent-bars-pattern ".")
  (indent-bars-pad-frac 0.25)
  (indent-bars-width-frac 0.25)
  (indent-bars-starting-column 0)
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-color '(highlight :face-bg t :blend 0.6)))

(use-package dired
  :ensure nil
  :hook
  (dired-mode . dired-omit-mode)
  (dired-mode . hl-line-mode)
  :commands (dired dired-jump)
  :bind ("C-x C-j" . dired-jump)
  :custom
  (dired-dwim-target t)
  (dired-isearch-filenames t)
  (dired-omit-files (rx (seq bol ".")))
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-lah --group-directories-first")
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file
    "." 'dired-omit-mode))

(use-package transpose-frame
  :ensure t
  :commands transpose-frame)

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

;; (use-package dashboard
;;   :ensure t
;;   :custom
;;   (dashboard-items nil)
;;   (dashboard-hide-cursor t)
;;   (dashboard-center-content t)
;;   (dashboard-footer-messages nil)
;;   (dashboard-vertically-center-content nil)
;;   (dashboard-startup-banner "/usr/share/emacs/30.2/etc/images/splash.svg")
;;   ;; (dashboard-startup-banner 'official)
;;   (dashboard-startupify-list
;;    '(dashboard-insert-banner
;;      dashboard-insert-newline
;;      dashboard-insert-banner-title
;;      dashboard-insert-newline
;;      dashboard-insert-init-info))
;;   :config
;;   (dashboard-setup-startup-hook))

;; Prettify
;; (use-package diminish
;;   :ensure t
;;   :config
;;   (diminish 'evil-collection-unimpaired-mode)
;;   (diminish 'yas-minor-mode))

(use-package rainbow-mode
  :ensure t
  :diminish
  :hook (prog-mode-hook . rainbow-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))

;; (use-package beacon
;;   :ensure t
;;   :defer t
;;   :config (beacon-mode))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-font-lock-level 4)
  (treesit-auto-install 'prompt)
  ;; (treesit-auto-add-to-auto-mode-alist 'all)
  :config
  (add-to-list 'treesit-auto-recipe-list
                (make-treesit-auto-recipe
                  :lang 'gdscript
                  :ts-mode 'gdscript-ts-mode
                  :remap 'gdscript-mode
                  :url "https://github.com/PrestonKnopp/tree-sitter-gdscript"
                  :ext "\\.gd\\'"))
  ;; (add-to-list 'treesit-auto-recipe-list my-gdscript-ts-auto-recipe)
  (global-treesit-auto-mode))

;; Org
(defun my/org-mode-setup()
  "Change list item decoration."
  (font-lock-add-keywords 'org-mode
    '(("^ *\\([-]\\) "
        (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Strikethrough and dim checked item in a list
  (defface org-checkbox-done-text
   '((t (:foreground "#71696A" :strike-through t)))
    "Face for the text part of a checked org-mode checkbox.")
  (font-lock-add-keywords
   'org-mode
   `(("^[ \t]*\\(?:[-+*]\\|[0-9]+[).]\\)[ \t]+\\(\\(?:\\[@\\(?:start:\\)?[0-9]+\\][ \t]*\\)?\\[\\(?:X\\|\\([0-9]+\\)/\\2\\)\\][^\n]*\n\\)"
       1 'org-checkbox-done-text prepend))
   'append)

  ;; Resize document title
  (set-face-attribute 'org-document-title nil :font "Source Sans Pro" :weight 'bold :height 1.8)

  ;; Resize org headings
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Source Sans Pro" :weight 'bold :height (cdr face)))

  ;; Checkbox Symbols
  (push '("[ ]" . "☐") prettify-symbols-alist)
  (push '("[X]" . "☑" ) prettify-symbols-alist)
  (push '("[-]" . "❍" ) prettify-symbols-alist)
  (set-face-attribute 'org-modern-symbol nil :family "Source Sans Pro")

  ;; Modes in org
  (org-indent-mode)
  (visual-line-mode)
  (variable-pitch-mode)
  (prettify-symbols-mode)

 (setq
  ;; Edit org settings
  org-auto-align-tags nil
  org-tags-column 0
  org-catch-invisible-edits 'show-and-error
  org-special-ctrl-a/e t
  org-insert-heading-respect-content t
 
  ;; Org styling, hide markup etc.
  org-hide-emphasis-markers t
  org-pretty-entities t
  org-agenda-tags-column 0
  org-ellipsis " ▾"

  org-log-done 'time
  org-log-into-drawer t
  org-agenda-start-with-log-mode t

  org-todo-keywords
  '((sequence "TODO" "DONE")))
  ;; '((sequence "TODO(t)" "READ(r)" "WATCH(w)"
  ;;             "|"
  ;;             "DONE(d)")))

  (custom-theme-set-faces
   'user

   '(variable-pitch ((t (:family "Source Sans Pro" :height 170 :weight regular))))
   '(fixed-pitch ((t ( :family "Fira Code Retina" :height 150))))

   '(org-block ((t (:inherit fixed-pitch))))
   '(org-code ((t (:inherit (shadow fixed-pitch)))))
   ;;'(org-done ((t (:strike-through t))))
   ;;'(org-headline-done ((t (:strike-through t))))
   ;;'(org-checkbox-statistics-done ((t (:inherit org-done ))))
   '(org-checkbox ((t (:inherit (font-lock-comment-face variable-pitch)))))
   '(org-document-info ((t (:foreground "dark orange"))))
   '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
   '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
   '(org-link ((t (:foreground "royal blue" :underline t))))
   '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-property-value ((t (:inherit fixed-pitch))) t)
   '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
   '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
   '(org-verbatim ((t (:inherit (shadow fixed-pitch)))))))

(use-package org
  :ensure nil
  :hook
  (org-mode . my/org-mode-setup))

(use-package org-appear
  :ensure t
  :after org
  :hook
  (org-mode . org-appear-mode))

(use-package org-modern
  :ensure t
  :hook
  (org-mode . org-modern-mode))

;; (use-package org-bullets
;;   :ensure t
;;   :custom
;;   (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●"))
;;   :hook
;;   (org-mode . org-bullets-mode))

;; Set visible fringes for olivetti on ef themes
;; (setq modus-themes-common-palette-overrides
;;       '((fringe bg-active)))
;; (custom-set-faces
;; '(olivetti-fringe ((t :background unspecified))))

(use-package olivetti
  :ensure t
  ;; :custom
  ;; (olivetti-style 'fancy) ;; Olivetti fringes
  :config
  (olivetti-set-width 80)
  :hook
  ((org-mode . olivetti-mode)
   (markdown-mode . olivetti-mode)))

(use-package calfw-org
  :ensure t
  :bind
  ("C-c c" . calfw-org-open-calendar))

(use-package project
  :custom
  (project-kill-buffers-display-buffer-list t)
  (project-mode-line t))

;; (use-package projectile
;;   :ensure t
;;   :bind-keymap
;;   ("C-c p" . projectile-command-map)
;;   :config
;;   (projectile-mode)
;;   :init
;;   (when (file-directory-p "~/proj/")
;;     (setq projectile-project-search-path '("~/proj/")))
;;   (setq projectile-switch-project-action #'projectile-dired))

(use-package ace-window
  :ensure t
  :bind
  ("M-o" . ace-window))

(use-package impatient-mode
  :ensure t
  :config
  (defun markdown-html (buffer)
    (princ (with-current-buffer buffer
      (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://ndossougbe.github.io/strapdown/dist/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
    (current-buffer))))

(message "Startup: %s"(emacs-init-time))
