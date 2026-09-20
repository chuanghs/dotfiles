;;; -*- lexical-binding: t -*-

;;; ============================================================================
;;; 1. 基礎環境、編碼與套件系統 (Environment, Encoding & Packages)
;;; ============================================================================

;; 強制全域 UTF-8 編碼
(set-language-environment "UTF-8")
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; 套件管理系統初始化 (確保批次測試與非交互啟動時能正確載入套件)
(require 'package)
(require 'cl-lib)
(unless (bound-and-true-p package--initialized)
  (package-initialize))

;; 使用者身分資訊
(setq user-full-name "Zombie Chuang"
      user-mail-address "chuanghs@gmail.com")

;; 啟動記憶體釋放最佳化 (啟動時擴大 GC 門檻至 64MB，完成後恢復為 800KB)
(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold 800000)))

;; 即時字型繪製效能最佳化 (Jit-lock performance)
(setq jit-lock-stealth-time 1.25)
(setq jit-lock-stealth-nice 0.5) ;; Seconds between font locking
(setq jit-lock-chunk-size 4096)
(setq jit-lock-defer-time 0.25)

;; ----------------------------------------------------------------------------
;; Custom 自動產生之設定與字型 (由 Emacs Custom 管理)
;; ----------------------------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(org-agenda-files
   '("~/orgfiles/personal.org" "~/orgfiles/journal.org"
     "~/orgfiles/mac_calendar.org"))
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
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#002b36" :foreground "#839496" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 160 :width normal :foundry "nil" :family "Monaco")))))


;;; ============================================================================
;;; 2. 介面視覺與編輯體驗 (UI & Appearance)
;;; ============================================================================

(load-theme 'solarized-dark t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(show-paren-mode 1)
(global-hl-line-mode 1)
(winner-mode 1)

;; 全域自動重載檔案 (搭配 Syncthing / beorg 同步時偵測變更)
(global-auto-revert-mode t)
(setq auto-revert-check-vc-info t)


;;; ============================================================================
;;; 3. 補全系統與輸入增強 (Completion System: Corfu / Vertico / Orderless)
;;; ============================================================================

;; 緩衝區內即時自動補全 (In-buffer Completion - Corfu)
(global-corfu-mode 1)
(setq tab-always-indent 'complete)

;; Minibuffer 垂直清單補全 (Minibuffer UI - Vertico)
(use-package vertico
  :init
  (vertico-mode +1))

;; Minibuffer 候選項目詳細註解 (Marginalia)
(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;; 進階模糊與正規匹配樣式 (Orderless)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))


;;; ============================================================================
;;; 4. 專案管理與版本控制 (Project Management & Magit)
;;; ============================================================================

;; Projectile 專案導覽與搜尋
(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (global-set-key (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

;; Magit Git 操作界面
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))


;;; ============================================================================
;;; 5. 程式語言開發與 LSP 支援 (Languages & LSP)
;;; ============================================================================

;; Python 模式重對應至 Tree-sitter
(setq major-mode-remap-alist '((python-mode . python-ts-mode)))

(use-package python
  :mode ("\\.py\\'" . python-ts-mode)
  :hook (python-ts-mode . eglot-ensure))

;; Python 虛擬環境切換
(use-package pyvenv
  :init
  (require 'widget)
  :config
  (pyvenv-mode 1))

;; Python Black 自動排版
(use-package python-black
  :ensure t
  :demand t
  :after python
  :hook ((python-mode . python-black-on-save-mode)))

;; Swift 語法支援
(use-package swift-mode
  :ensure t
  :mode ("\\.swift\\'" . swift-mode))

;; 備註：swift-ts-mode 在關鍵字 font-lock 仍有未解問題，維持保留註解
;; (use-package swift-ts-mode
;;   :ensure t
;;   :mode ("\\.swift\\'" . swift-ts-mode))

;; Eglot 語言伺服器協議 (LSP) 用戶端
(use-package eglot
  :ensure t
  :defer
  :hook ((swift-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (go-mode . eglot-ensure))
  :config
  ;; 伺服器啟動指令註冊
  (add-to-list 'eglot-server-programs '(swift-mode . ("sourcekit-lsp")))
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("pyright-langserver" "--stdio" :initializationOptions (:format (:enabled :json-false)))))
  (setq eglot-sync-connect nil)    ;; 非同步連線，防範啟動阻塞
  (setq eglot-connect-timeout 60) ;; 提高大型專案逾時門檻
  :custom
  (eglot-confirm-server-initiated-edits nil)
  (eglot-extend-to-xref t)
  (eglot-autoshutdown t))


;;; ============================================================================
;;; 6. Org-mode 核心、GTD 工作流與行事曆整合 (Org-mode, GTD & Calendar)
;;; ============================================================================

;; 核心 Agenda 檔案清單
(setq org-agenda-files '("~/orgfiles/personal.org"
                         "~/orgfiles/journal.org"
                         "~/orgfiles/mac_calendar.org"))

;; GTD 任務狀態機：NA (下一步行動)、WAITING (等待) | DONE (完成)、CANCELLED (取消)
(setq org-todo-keywords
      '((sequence "NA(n@)" "WAITING(w@/!)" "|" "DONE(d@)" "CANCELLED(c@)")))

;; GTD 情境與分類標籤
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
                      ("finance"   . ?$)
                      ("work"      . ?W)
                      ("admin"     . ?A)
                      ("project"   . ?P)))

(with-eval-after-load 'org
  ;; 斷開 project 標籤向下繼承，避免子任務繼承 :project: 污染 Agenda 與 beorg 視圖
  (add-to-list 'org-tags-exclude-from-inheritance "project")
  (global-org-modern-mode))

;; org-modern 大綱折疊符號
(setq org-modern-fold-stars
      '(("▶" . "▼")
        ("▷" . "▽")
        ("▸" . "▾")
        ("▹" . "▿")))

;; 狀態更新時記錄 Log 筆記與時間戳記，並自動收納至 :LOGBOOK: Drawer
(setq org-log-done 'note)                 ;; 任務完成 (DONE) 時彈出視窗輸入 Log Note
(setq org-log-into-drawer "LOGBOOK")       ;; 所有狀態變更 Log、筆記皆自動存入 :LOGBOOK: 抽屜
(setq org-log-reschedule 'note)           ;; 重新排程時提示輸入原因
(setq org-log-redeadline 'note)           ;; 修改截止日 (DEADLINE) 時提示輸入原因
(setq org-return-follows-link t)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)

;; 當 Syncthing 或外部同步更新檔案時，自動重新解析 Org 規則（免按 C-c C-c）
(add-hook 'after-revert-hook
          (lambda ()
            (when (derived-mode-p 'org-mode)
              (org-set-regexps-and-options))))

;; Org Capture 收集箱範本
(setq org-capture-templates
      '(("i" "📥 快速收集箱 (Inbox)" entry (file+headline "~/orgfiles/personal.org" "📥 00_INBOX / Quick Capture (收集箱)")
         "* NA %?\n  記錄時間：%U\n  來源鏈接：%a" :empty-lines 1)
        ("w" "🏢 下班工作速記 (Work Quick Capture)" entry (file+headline "~/orgfiles/personal.org" "📥 00_INBOX / Quick Capture (收集箱)")
         "* NA %? :work:\n  記錄時間：%U\n  備註：週五 WFH 或隔日進公司轉錄至 gtd.org" :empty-lines 1)
        ("r" "🏃 跑步/生理速記 (Running)" entry (file+headline "~/orgfiles/personal.org" "📥 00_INBOX / Quick Capture (收集箱)")
         "* NA %? :running:health:\n  記錄時間：%U" :empty-lines 1)
        ("j" "📔 日誌紀錄 (Journal)" entry (file+olp+datetree "~/orgfiles/journal.org")
         "* %U\n%?")))

;; 客製化 Agenda 儀表板視圖
(setq org-agenda-custom-commands
      '(("g" "🎯 GTD 個人總控儀表板 (Dashboard)"
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-overriding-header "📅 今日時間線與排程 (Today's Schedule)")))
          (todo "NA" ((org-agenda-overriding-header "⚡ 可立即執行的待辦行動 (Next Actions by Context)")
                      (org-agenda-todo-ignore-scheduled 'future)
                      (org-agenda-todo-ignore-deadlines 'future)))
          (todo "WAITING" ((org-agenda-overriding-header "⏳ 等待外部回覆事項 (Waiting For)")))
          (tags "project"
                ((org-agenda-overriding-header "🎯 進行中重大專案 (Active Projects - High Level Overview)")
                 (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "CANCELLED")))))))))

;; 自動自 macOS Calendar 同步行程 (透過 icalBuddy，具備 15 分鐘快取防卡頓)
(defun my/sync-mac-calendar (&rest _args)
  "Sync macOS Calendar events via icalBuddy with 15-minute caching."
  (interactive)
  (let* ((cal-file (expand-file-name "~/orgfiles/mac_calendar.org"))
         (script (expand-file-name "~/orgfiles/scripts/sync_mac_calendar.py"))
         (mod-time (and (file-exists-p cal-file)
                        (float-time (file-attribute-modification-time (file-attributes cal-file)))))
         (now (float-time))
         (threshold (* 15 60)))
    (when (or (called-interactively-p 'interactive)
              (not mod-time)
              (> (- now mod-time) threshold))
      (message "Syncing macOS calendar via icalBuddy...")
      (let ((exit-code (call-process "python3" nil nil nil script)))
        (if (zerop exit-code)
            (message "macOS calendar synced successfully.")
          (message "Failed to sync macOS calendar (exit code %d)." exit-code))))))

(advice-add 'org-agenda :before #'my/sync-mac-calendar)

;; 全域 Org 快捷鍵
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)

;; 全域專案檔案 Refile 設定 (跨檔案分派至 projects/、travel/、personal.org 等)
(defun my/org-project-files ()
  "動態掃描全域專案 Org 檔案清單（排除暫存、同步衝突與衍生檔案）。"
  (let ((search-dirs (list (expand-file-name "~/orgfiles/projects")
                           (expand-file-name "~/orgfiles/travel/projects")
                           (expand-file-name "~/orgfiles/running/training_plans"))))
    (seq-filter
     (lambda (file)
       (and (file-regular-p file)
            (not (string-match-p "/\\." file))                     ;; 排除隱藏檔
            (not (string-match-p "sync-conflict" file))            ;; 排除 Syncthing 衝突檔
            (not (string-match-p "itinerary_mobile\\.org$" file))  ;; 排除隨身口袋書 (自動產生)
            (not (string-match-p "-travel-guide\\.org$" file))))   ;; 排除出版原稿
     (apply #'append
            (mapcar (lambda (dir)
                      (if (file-directory-p dir)
                          (directory-files-recursively dir "\\.org$")
                        nil))
                    search-dirs)))))

(setq org-refile-targets
      '((nil :maxlevel . 3)                   ;; 當前檔案前 3 層標題
        (org-agenda-files :maxlevel . 3)      ;; Agenda 核心檔案 (personal.org, journal.org)
        (my/org-project-files :maxlevel . 3)  ;; 全域專案檔案 (含 projects/family-finance-dashboard/ 等)
        ("~/orgfiles/reading-list.org" :maxlevel . 3))) ;; 📚 個人閱讀與主題書庫

(setq org-refile-use-outline-path 'file)       ;; 補全路徑以「檔案名稱/標題」顯示，避免跨檔案同名標題混淆
(setq org-outline-path-complete-in-steps nil)  ;; 配合 Vertico 一次輸入整個大綱路徑進行模糊搜尋
(setq org-refile-allow-creating-parent-nodes 'confirm) ;; 允許在 Refile 時動態確認建立新父節點
(setq org-hide-emphasis-markers t)

;; Refile 至 reading-list.org 時自動塑形與結構標準化
(defun my/org-enrich-reading-list-on-refile ()
  "當條目 Refile 至 reading-list.org 時，自動剝除來源 NA/WAITING、轉為 TODO/READING 並補齊標準骨架。"
  (when (and (buffer-file-name)
             (string-match-p "reading-list\\.org$" (buffer-file-name)))
    (save-excursion
      (org-back-to-heading t)
      (let* ((outline (org-get-outline-path))
             (is-reading (cl-some (lambda (s) (string-match-p "CURRENTLY READING" s)) outline))
             (target-state (if is-reading "READING" "TODO"))
             (category (or (car (last outline)) "未分類"))
             (today (format-time-string "[%Y-%m-%d %a]"))
             (entry-end (save-excursion (org-end-of-subtree t t))))
        ;; 1. 剝除來源標題可能殘留的 NA 或 WAITING 前綴
        (let ((case-fold-search nil))
          (when (looking-at org-complex-heading-regexp)
            (let ((title (match-string 4)))
              (when (and title (string-match "^\\(NA\\|WAITING\\)[ \t]+" title))
                (org-edit-headline (replace-regexp-in-string "^\\(NA\\|WAITING\\)[ \t]+" "" title))))))
        ;; 2. 設定符合 reading-list 狀態機之關鍵字
        (org-todo target-state)
        ;; 3. 若尚未具備「- 開始時間：」則自動插入標準欄位
        (unless (save-excursion (re-search-forward "^[ \t]*- 開始時間：" entry-end t))
          (org-end-of-meta-data t)
          (insert (format "- 開始時間：%s\n- 領域分類：%s\n- 閱讀筆記：尚未建立（待閱讀精讀後透過 ~M-x org-roam-node-find~ 建立關聯）\n"
                          today category)))))))

(add-hook 'org-after-refile-insert-hook #'my/org-enrich-reading-list-on-refile)


;;; ============================================================================
;;; 7. 知識庫與雙向連結筆記 (Knowledge Base: Vulpea & Org-roam)
;;; ============================================================================

;; Vulpea: Org-mode 資料庫層
(use-package vulpea)
(vulpea-db-autosync-mode +1)

;; Deadgrep 搜尋 Org-Roam 目錄
(use-package deadgrep)
(defun org-roam-deadgrep (arg)
  (interactive "MSearch term: ")
  (deadgrep arg org-roam-directory))

;; Org-Roam 雙向鏈結網路
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-directory (file-truename "~/orgfiles/note"))
  :config
  ;; 啟動模式與同步
  (org-roam-db-autosync-mode 1)
  ;; UTF-8 節點名稱捕獲範本
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+created: %U\n")
           :unnarrowed t)))
  ;; 節點顯示模板
  (setq org-roam-node-display-template
        (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

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
               (("C-c n i" . org-roam-node-insert)
                ("C-c n I" . org-roam-node-insert-immediate)
                ("C-c n o" . org-id-get-create)
                ("C-c n t" . org-roam-tag-add)
                ("C-c n a" . org-roam-alias-add)
                ("C-c n l" . org-roam-buffer-toggle)))))


;;; ============================================================================
;;; 8. 終端機整合與實用工具 (Terminals & Utilities)
;;; ============================================================================

;; Eat 終端模擬器 (Terminal Backend)
(use-package eat :ensure t)

;; Vterm 終端調校
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
(with-eval-after-load 'vterm
  ;; 微幅增加渲染計時器延遲，確保完整的 UTF-8 多位元組字串組合完畢才繪製 (預設 0.01)
  (setq vterm-timer-delay 0.03)
  ;; 提高滾動緩衝區上限
  (setq vterm-max-scrollback 10000)
  ;; 將 C-c 直接傳給終端程式（例如 CLI 工具），不要留給 Emacs 當 prefix key
  (define-key vterm-mode-map (kbd "C-c") #'vterm-send-C-c)
  ;; C-c 已保留給終端程式，改用 C-M-l 清空 vterm 滾動紀錄
  (define-key vterm-mode-map (kbd "C-M-l") #'vterm-clear-scrollback))

;; Beancount 複式記帳模式
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

;;; emacs.el ends here
