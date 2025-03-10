(setq inhibit-startup-screen t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)
(setq exec-path (append exec-path '("~/bin")))

; allow '#' entry on Mac UK keyboard
(global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#")))

; allow use of a single press of ESC to cancel stuff
(define-key global-map (kbd "<escape>") 'keyboard-escape-quit)    

; ensure absence of obnoxious bell
(setq visible-bell nil)
(setq ring-bell-function #'ignore)

(defun open-init-el()
  (interactive)
  (find-file user-init-file)
  )

; TODO not sure if this is necessary in emacs 30
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'evil)
(evil-mode 1)

; allow undoing window configuration changes
(winner-mode 1)
(keymap-global-set "s-[" 'winner-undo)

(use-package evil
  :bind (:map evil-motion-state-map
	      ("s-." . open-init-el)
	      ("s-;" . fill-paragraph)
              ("C-a" . move-beginning-of-line)
              ("C-e" . move-end-of-line)
	      ("U" . undo-redo)))

(setopt display-fill-column-indicator-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

(when (require 'afternoon-theme nil 'noerror)
  (load-theme 'afternoon t))

(use-package go-ts-mode
  :ensure t
  :preface
  (setq treesit-language-source-alist '())
  (defun ad/go-presave()
    (lsp-organize-imports)
    (lsp-format-buffer)
    )
  (defun ad/go-lsp-start()
    (setq tab-width 2)
    (add-hook 'before-save-hook #'ad/go-presave t t)
    (lsp-deferred)
   )
  (defun ad/golang-ts-init()
    (add-to-list 'treesit-language-source-alist '(go "https://github.com/tree-sitter/tree-sitter-go"))
    (add-to-list 'treesit-language-source-alist '(gomod "https://github.com/camdencheek/tree-sitter-go-mod"))
    ;(dolist (lang '(go gomod)) (treesit-install-language-grammar lang))
    (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
    (add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))
  )
  :init (ad/golang-ts-init)
  :hook
  (go-ts-mode . ad/go-lsp-start)
)

(defun ad/format-project (p)
  (if (null p)
      "null"
    (propertize
     (concat " " (string-trim (with-output-to-string (print p))))
     'font-lock-face
     '(:foreground "green"))))
(defconst ad/custom-mode-string
  '(:eval (ad/format-project (project-current))))
(add-to-list 'global-mode-string ad/custom-mode-string 'APPEND)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(afternoon-theme evil flycheck lsp-mode lsp-ui magit)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
