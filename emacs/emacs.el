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
 '(current-language-environment "UTF-8")
 '(org-agenda-files
   '("~/orgfiles/personal.org"
     "~/orgfiles/journal.org"
     "~/orgfiles/travel/projects/2026-sydney-marathon/info.org"))
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("nongnu" . "https://elpa.nongnu.org/nongnu/")
     ("melpa" . "https://melpa.org/packages/")))
 '(package-selected-packages
   '(beancount company company-org-block corfu-terminal deadgrep eat
	       gemini-cli gherkin-mode haskell-mode lsp-pyright magit
	       marginalia markdown-preview-mode multi-vterm orderless
	       org-roam org-roam-ui popup projectile
	       projectile-ripgrep pyvenv-auto solarized-theme
	       swift-mode swift-ts-mode vertico vulpea vulpea-ui))
 '(package-vc-selected-packages
   '((gemini-cli :url "https://github.com/linchen2chris/gemini-cli.el")))
 '(tool-bar-mode nil)
 '(vulpea-db-sync-directories '("~/orgfiles")))
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

;; projectile
(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  :config
  ;; I typically use this keymap prefix on macOS
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (global-set-key (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status))
  )

;; Try setup python
;; check tree-sitter exist in emacs
;; M-: (treesit-available-p) RET should be t
;; install python languar grammer
;; M-x treesit-install-language-grammer RET type python
(setq major-mode-remap-alist '((python-mode . python-ts-mode)))
;; install python3-pylsp from console
;; package-install corfu
(use-package python
  :mode ("\\.py\\'" . python-ts-mode)
  :hook (python-ts-mode . eglot-ensure))
;  :config
;  (add-to-list 'eglot-server-programs
;	       '(python-ts-mode . ("pyright-langserver" "--stdio"))))

(use-package pyvenv
  :init
  (require 'widget)
  :config (pyvenv-mode 1))

(use-package eglot
  :ensure t
  :defer
  :hook ((swift-mode . eglot-ensure)
	 (python-mode . eglot-ensure)
	 (python-ts-mode . eglot-ensure)
	 (go-mode . eglot-ensure) )
  ;; optimize eglot
  :config
   ;; 告訴 Eglot 如何啟動 sourcekit-lsp
  (add-to-list 'eglot-server-programs
               '(swift-mode . ("sourcekit-lsp"))
	       '(python-ts-mode . ("pyright-langserver" "--stdio")))
  (setq eglot-sync-connect nil)  ;; async connection, prevent jam emacs
  (setq eglot-connect-timeout 60)   ;; increase timeout for large project
  :custom
  (eglot-confirm-server-initiated-edits nil)
  (eglot-extend-to-xref t)
  (eglot-autoshutdown t)
  )

(use-package swift-mode
  :ensure t
  :mode ("\\.swift\\'" . swift-mode))
; switf-ts-mode cannodt handle font-lock for keyword:
;(use-package swift-ts-mode
;  :ensure t
;  :mode ("\\.swift\\'" . swift-ts-mode) ;; 自動將 .swift 檔案關聯到此模式
;  :config
;; 連結 Eglot 與 SourceKit-LSP, 應該可以用 eglot 裡的設定取代
;; (add-to-list 'eglot-server-programs
;;               '(swift-ts-mode . ("sourcekit-lsp"))) 
  ;; 設定當進入 swift-ts-mode 時自動啟動 Eglot
					;  (add-hook 'swift-ts-mode-hook 'eglot-ensure))


(use-package python-black
  :ensure t
  :demand t
  :after python
  :hook ((python-mode . python-black-on-save-mode)))
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("pyright-langserver" "--stdio" :initializationOptions (:format (:enabled :json-false)))))
  )


;; Completion UI
(global-corfu-mode)
(setq tab-always-indent 'complete)

;; Setup Org-Mode (GTD & Capture Templates)
(setq org-agenda-files '("~/orgfiles/personal.org"
                         "~/orgfiles/journal.org"
                         "~/orgfiles/travel/projects/2026-sydney-marathon/info.org"))
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "SOMEDAY(s)" "|" "DONE(d!)" "CANCELLED(c@)")))

(setq org-tag-alist '((:startgroup)
                      ("@computer" . ?c)
                      ("@phone"    . ?p)
                      ("@errand"   . ?e)
                      ("@home"     . ?h)
                      ("@work"     . ?w)
                      (:endgroup)
                      ("health"    . ?H)
                      ("running"   . ?R)
                      ("travel"    . ?T)
                      ("family"    . ?F)
                      ("finance"   . ?$)))

(with-eval-after-load 'org (global-org-modern-mode))
(setq org-modern-fold-stars
      '(("▶" . "▼")
        ("▷" . "▽")
        ("▸" . "▾")
        ("▹" . "▿")))
(setq org-log-done 'time)
(setq org-return-follows-link t)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)

(setq org-capture-templates
      '(("i" "📥 快速收集箱 (Inbox)" entry (file+headline "~/orgfiles/personal.org" "00_INBOX / Quick Capture (收集箱)")
         "* TODO %?\n  記錄時間：%U\n  來源鏈接：%a" :empty-lines 1)
        ("n" "⚡ 下一步行動 (Next Action)" entry (file+headline "~/orgfiles/personal.org" "01_NEXT ACTIONS (下一步行動清單 - 按情境 Context 分流)")
         "* NEXT %?\n  SCHEDULED: %t\n  記錄時間：%U" :empty-lines 1)
        ("r" "🏃 跑步/生理速記 (Running)" entry (file+headline "~/orgfiles/personal.org" "00_INBOX / Quick Capture (收集箱)")
         "* TODO %? :running:health:\n  記錄時間：%U" :empty-lines 1)
        ("t" "Tasks (舊版任務)" entry (file+headline "~/orgfiles/journal.org" "Inbox") "* TODO %?\n %U")
        ("j" "Journal Entry (日誌)" entry (file+olp+datetree "~/orgfiles/journal.org") "* %U\n%?")))

(setq org-agenda-custom-commands
      '(("g" "🎯 GTD 個人總控儀表板 (Dashboard)"
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-overriding-header "📅 今日時間線與排程 (Today's Schedule)")))
          (todo "NEXT" ((org-agenda-overriding-header "⚡ 可立即執行的下一步行動 (Next Actions by Context)")))
          (todo "WAITING" ((org-agenda-overriding-header "⏳ 等待外部回覆事項 (Waiting For)")))
          (tags "CATEGORY=\"Projects\"" ((org-agenda-overriding-header "🎯 進行中重大專案 (Active Projects)")))))))

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


;; Enable Vertico
(use-package vertico
  :init
  (vertico-mode +1))

;; Enable Marginalia for descriptions in the Vertico minibuffer
(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;; Use Orderless for advanced pattern matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))


;; setup roam
(use-package deadgrep)
(defun org-roam-deadgrep (arg)
  (interactive "MSearch term: ")
  (deadgrep arg org-roam-directory))

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
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" 
                              "#+title: ${title}\n#+created: %U\n")
           :unnarrowed t)))  
  ;; 節點顯示模板
;  (setq org-roam-node-display-template "${title} ${tags}")
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

  ;; 視窗佈局設定
  (add-to-list 'display-buffer-alist
               '("\\*org-roam\\*"
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.33)
                 (window-height . fit-window-to-buffer)))
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

;; try to fix vterm display issue
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
(with-eval-after-load 'vterm
  ;; 設定 vterm 處理 Coding System 嚴格為 UTF-8
;  (set-process-coding-system 'utf-8)
  ;; 微幅增加渲染計時器延遲，確保完整的 UTF-8 多位元組字串組合完畢才繪製 (預設 0.01)
  (setq vterm-timer-delay 0.03)
  ;; 提高滾動緩衝區上限
  (setq vterm-max-scrollback 10000)
  ;; 將 C-c 直接傳給終端程式（例如 Codex CLI），不要留給 Emacs 當 prefix key。
  (define-key vterm-mode-map (kbd "C-c") #'vterm-send-C-c)
  ;; C-c 已保留給終端程式，改用 C-M-l 清空 vterm 滾動紀錄。
  (define-key vterm-mode-map (kbd "C-M-l") #'vterm-clear-scrollback))

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

; Hard code customize beancount-mode to support auto-complete for chinese account, leave it as comment because I manually fix it in package
;(with-eval-after-load 'beancount
;  (setq beancount-account-regexp "\\(?:Assets\\|E\\(?:quity\\|xpenses\\)\\|Income\\|Liabilities\\)\\(?::[[:alnum:][:upper:][:digit:]][[:alnum:]-_]+\\)+"))
