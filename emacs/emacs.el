;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(solarized-theme)))
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


;; FAster startup
(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook #'(lambda()
			       (setq gc-cons-threshold 800000)))


(setq user-full-name "Zombie Chuang" user-mail-address "chuanghs@gmail.com")


;; Try setup python
;(elpy-enable)
;(setq elpy-rpc-python-command "python3")
;(setq python-shell-interpreter "/usr/local/bin/python3")
;(setq org-babel-python-command "/usr/local/bin/python3")

;; Setup Org-Mode (capture template and actions)
(setq org-capture-templates
      '(("t" "Tasks" entry (file+headline "~/orgfiles/journal.org" "Inbox") "* TODO %?\n %U")
	("j" "Journal Entry" entry (file+datetree "~/orgfiles/journal.org") "* %U\n%?")))
