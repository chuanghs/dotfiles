;;; -*- lexical-binding: t -*-
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("gnu" . "https://elpa.gnu.org/packages/
") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(package-selected-packages
   '(corfu-terminal haskell-mode org-roam org-roam-ui pyenv-mode
		    solarized-theme vulpea))
 '(tool-bar-mode nil)
 '(vulpea-db-sync-directories '("~/orgfiles/")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


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
(setq major-mode-remap-alist '((python-mode . python-ts-mode)))
;; install python3-pylsp from console
;; package-install corfu
(use-package eglot
  :ensure t
  :defer t
  :hook ((python-mode . eglot-ensure)
	 (python-ts-mode . eglot-ensure)
         (go-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               `(python-mode
                 . ,(eglot-alternatives '(("pyright-langserver" "--stdio")
                                          "jedi-language-server"
                                          "pylsp"))))
  :config
  (add-hook 'haskell-mode-hook 'eglot-ensure)  ; start eglot automatically in haskell projects
  :config
  (setq-default eglot-workspace-configuration
		'(:haskell (:plugin (:stan (:globalOn :json-false)) ; disable stan
				    :formattingProvider "fourmolu")))   ; use fourmolu instead of ormulu
  :custom
  (eglot-autoshutdown t)  ; shutdown language server after closing last file
  (eglot-confirm-server-initiated-edits nil)  ; allow edit without confirmation
  )

;(use-package python-black
;  :ensure t
;  :demand t
;  :after python
;  :hook ((python-mode . python-black-on-save-mode)))

(use-package pyenv-mode
  :ensure t
  :init
  (add-to-list 'exec-path "~/.pyenv/shims")
  (setenv "WORKON_HOME" "~/.pyenv/versions/")
  :config
  (pyenv-mode))

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
	("j" "Journal Entry" entry (file+datetree "~/orgfiles/journal.org") "* %U\n%?")));; enable vulpea for better org-mod
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)

(setq org-hide-emphasis-markers t)
(add-hook 'org-mode-hook 'visual-line-mode)

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
(setq org-roam-directory "~/orgfiles/note")
					;(setq find-file-visit-truename t)
(add-hook 'after-init-hooko 'org-roam-mode)
(setq org-roam-server-host "127.0.0.1"
      org-roam-server-port 9090
      org-roam-server-export-inline-images t
      org-roam-server-authenticate nil
      org-roam-server-network-label-truncate t
      org-roam-server-network-label-truncate-length 60
      org-roam-server-network-label-wrap-length 20)
(org-roam-db-autosync-mode)
(setq org-roam-node-display-template
      (concat "${title:*} "
	      (propertize "${tag:10}" 'face 'org-tag)))
(add-to-list 'display-buffer-alist
             '("\\*org-roam\\*"
               (display-buffer-in-direction)
               (direction . right)
               (window-width . 0.33)
               (window-height . fit-window-to-buffer)))
