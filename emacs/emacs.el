;;; -*- lexical-binding: t -*-

;; for performance
(setq jit-lock-stealth-time 1.25)
(setq jit-lock-stealth-nice 0.5) ;; Seconds between font locking.
(setq jit-lock-chunk-size 4096)
(setq jit-lock-defer-time 0.25)

;; enforce utf-8
;; Force UTF-8 for everything
(set-language-environment "UTF-8")
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(eglot-confirm-server-edits nil nil nil "Customized with use-package eglot")
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("nongnu" . "https://elpa.nongnu.org/nongnu/")
     ("melpa" . "https://melpa.org/packages/")))
 '(package-selected-packages
   '(beancount corfu-terminal deadgrep eat gemini-cli haskell-mode
	       markdown-preview-mode org-roam org-roam-ui popup
	       solarized-theme vulpea))
 '(package-vc-selected-packages
   '((gemini-cli :url "https://github.com/linchen2chris/gemini-cli.el")))
 '(tool-bar-mode nil)
 '(vulpea-db-sync-directories '("~/orgfiles/")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Menlo" :foundry "nil" :slant normal :weight regular :height 140 :width normal)))))


(load-theme 'solarized-dark t)
 (menu-bar-mode -1)
 (tool-bar-mode -1)
 (scroll-bar-mode -1)
 (column-number-mode)
 (show-paren-mode)
 (global-hl-line-mode)
 (winner-mode t)


;; Faster startup
(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook #'(lambda()
			       (setq gc-cons-threshold 800000)))


(setq user-full-name "Zombie Chuang" user-mail-address "chuanghs@gmail.com")


;; Try setup python
;; check tree-sitter exist in emacs
;; M-: (treesit-available-p) RET should be t
;; install python languar grammer
;; M-x treesit-install-language-grammer RET type python
;(setq major-mode-remap-alist '((python-mode . python-ts-mode)))
;; install python3-pylsp from console
;; package-install corfu
;(use-package eglot
;  :ensure t
;  :defer t
;  :hook ((python-mode . eglot-ensure)
;	 (python-ts-mode . eglot-ensure)
;         (go-mode . eglot-ensure))
;  :config
;  (add-to-list 'eglot-server-programs
;               `(python-mode
;                 . ,(eglot-alternatives '(("pyright-langserver" "--stdio")
;                                          "jedi-language-server"
;                                          "pylsp"))))
;  :config
;  (add-hook 'haskell-mode-hook 'eglot-ensure)  ; start eglot automatically in haskell projects
;  :config
;  (setq-default eglot-workspace-configuration
;		'(:haskell (:plugin (:stan (:globalOn :json-false)) ; disable stan
;				    :formattingProvider "fourmolu")))   ; use fourmolu instead of ormulu
;  :custom
;  (eglot-autoshutdown t)  ; shutdown language server after closing last file
;  (eglot-confirm-server-initiated-edits nil)  ; allow edit without confirmation
;  )

;(use-package python-black
;  :ensure t
;  :demand t
;  :after python
;  :hook ((python-mode . python-black-on-save-mode)))

;(use-package pyenv-mode
;  :ensure t
;  :init
;  (add-to-list 'exec-path "~/.pyenv/shims")
;  (setenv "WORKON_HOME" "~/.pyenv/versions/")
;  :config
;  (pyenv-mode))

;(use-package pyconf
;  :ensure t)

;(defalias 'workon 'pyvenv-workon)

;; Completion UI
(global-corfu-mode)
(setq tab-always-indent 'complete)

;; Setup Org-Mode (capture template and actions)
(setq org-agenda-files '("~/orgfiles/journal.org" "~/orgfiles/projects"))
(setq org-log-done 'time)
(setq org-return-follows-link t)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)
(setq org-capture-templates
      '(("t" "Tasks" entry (file+headline "~/orgfiles/journal.org" "Inbox") "* TODO %?\n %U")
	("j" "Journal Entry" entry (file+olp+datetree "~/orgfiles/journal.org") "* %U\n%?")));; enable vulpea for better org-mod
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)

(setq org-hide-emphasis-markers t)
;(add-hook 'org-mode-hook 'visual-line-mode)

;; enable vulpea for better org-mode, vulpea is org-mode's database layer
(use-package vulpea)

;; build database, 1st time only
;; (vulpea-db-sync-full-scan)
;; enable auto-sync
(vulpea-db-autosync-mode +1)
;;
;; M-x vulpea-find - find and open notes
;; M-x vulpea-insert - insert link to a note
;; NEXT STEP: introduce org-roam for personal knowledge management ?


;; setup roam
(use-package deadgrep)
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-directory (file-truename "~/orgfiles/note"))
  :config
  ;; 啟動模式與同步
  (org-roam-db-autosync-mode 1)
  ;; utf-8 node name
  (setq org-roam-capture-templates
	'(("d" "default" plain "%?"
           :if-new (file-head "node/%<%Y%m%d%H%M%S>-${slug}.org" 
                              "#+title: ${title}\n#+created: %U\n")
           :unnarrowed t)))  
  ;; 節點顯示模板
  (setq org-roam-node-display-template
        (concat "${title:*} "
                (propertize "${tag:10}" 'face 'org-tag)))

  ;; 視窗佈局設定
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.33)
                 (window-height . fit-window-to-buffer)))
  (defun org-roam-deadgrep (arg)
    (interactive "MSearch term: ")
    (deadgrep arg org-roam-directory))
  :bind (("C-c n f" . org-roam-node-find)
           ("C-c n r" . org-roam-node-random)		    
           ("C-c n c" . org-roam-capture)
           ("C-c n g" . org-roam-graph)
	   ("C-c n s" . org-roam-deadgrep)
	   ("C-c n y" . org-roam-copy-node)
           (:map org-mode-map
                 (

		  ("C-c n i" . org-roam-node-insert)
		  ("C-c n I" . org-roam-node-insert-immediate)
                  ("C-c n o" . org-id-get-create)
                  ("C-c n t" . org-roam-tag-add)
                  ("C-c n a" . org-roam-alias-add)
		  ("C-c n l" . org-roam-buffer-toggle)	   
		  ))))

;; enable gemini-cli
;; for eat terminal backend:
(use-package eat :ensure t)

;; for vterm terminal backend:
;(use-package vterm :ensure t)
;; for slash commands popup
;(use-package popup :ensure t)
;; install gemini-cli.el
;(use-package gemini-cli :ensure t
;  :vc (:url "https://github.com/linchen2chris/gemini-cli.el" :rev :newest)
;  :config (gemini-cli-mode)
;  :bind-keymap ("C-c c" . gemini-cli-command-map)) ;; or your preferred key

; beancount mode
(use-package beancount
  :ensure t
  :mode ("\\.beancount\\'" . beancount-mode)
  :hook
  ((beancount-mode . (lambda () (setq-local electric-indent-chars nil)))
   (beancount-mode . outline-minor-mode)
   (beancount-mode . flymake-bean-check-enable))
  :bind (:map beancount-mode-map
              ("C-c C-n" . outline-next-visible-heading)
              ("C-c C-p" . outline-previous-visible-heading)))
