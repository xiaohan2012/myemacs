(require 'package)


;; Adds the Melpa archive to the list of available repositories
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Initializes the package infrastructure
(package-initialize)


;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))


;; Installs packages

;;

;; myPackages contains a list of package names
(defvar myPackages
  '(material-theme                 ;; Theme
    better-defaults                ;; better defaults
    elpy                           ;; Emacs Lisp Python Environment
    flycheck                       ;; syntax checkingyes
    ein                            ;; Emacs IPython Notebook
    ido-vertical-mode              ;; IDO vertical mode
    smex                           ;; IDO for M-x
    use-package                    ;;
    yaml-mode
    projectile
    latex-preview-pane
    company-bibtex
    )
  )


;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)


;; ===================================
;; Basic Customization
;; ===================================


(setq inhibit-startup-message t)    ;; Hide the startup message
(load-theme 'material t)            ;; Load material theme
(global-linum-mode t)               ;; Enable line numbers globally
(require 'better-defaults)          ;; use better-defaults

;; ====================================

;; Development Setup

;; ====================================

;; Enable elpy

(elpy-enable)
(setq elpy-test-runner 'elpy-test-pytest-runner)

;; Use IPython for REPL
(setq python-shell-interpreter "jupyter"
      python-shell-interpreter-args "console --simple-prompt"
      python-shell-prompt-detect-failure-warning nil)

(add-to-list 'python-shell-completion-native-disabled-interpreters
             "jupyter")


(when (load "flycheck" t t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(smex ido-vertical-mode ein flycheck elpy better-defaults material-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )





;; Misc stuff

(global-set-key (kbd "M-o")  'mode-line-other-buffer)


(add-to-list 'load-path
	     "~/.emacs.d/plugins/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)

(electric-pair-mode)


;; IDO mode

(setq ido-enable-flex-matching nil)
(setq ido-create-new-buffer 'always)
(setq ido-everywhere t)
(add-to-list 'ido-ignore-files "\.bak")
(add-to-list 'ido-ignore-files "\.log")
(ido-mode 1)


(ido-vertical-mode 1)

(setq ido-vertical-define-keys 'C-n-and-C-p-only)

(use-package smex
  :ensure t
  :init (smex-initialize)
  :bind
  ("M-x" . smex))



(global-set-key (kbd "C-x b") 'ido-switch-buffer)

(setq ibuffer-expert t)  ;; kill buffer without asking confirmation


(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;; (use-package beacon
;;   :ensure t
;;   :config
;;   (beacon-mode 1))


(global-hl-line-mode 1)




(require 'ein)
(setq ein:use-auto-complete t)  ;; enable  auto-completion in python
(setq ein:use-smartrep t)
(setq ein:worksheet-enable-undo t)
(setq ein:notebook-modes '(ein:notebook-multilang-mode ein:notebook-python-mode))

;; (defun ein:auto-login (url-or-port password)
;;   (ein:login url-or-port (lambda (buffer _) (pop-to-buffer buffer))
;;              nil nil password))


(projectile-mode +1)
;; Recommended keymap prefix on Windows/Linux
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)


;; https://github.com/jwiegley/use-package/issues/379
(use-package tex
  :defer t
  :ensure auctex
  :config
  (setq TeX-auto-save t)
  (setq TeX-save-query nil)
  )

(latex-preview-pane-enable)


(require 'company-bibtex)
(add-to-list 'company-backends 'company-bibtex)
(setq company-bibtex-bibliography
      '("/home/cloud-user/documents/diverse-xml/presentation/nov-1/ref.bib"))

; in compnay mode, use C-p and C-n to move up and down 
(with-eval-after-load "company"
  (define-key company-active-map (kbd "C-p") #'company-select-previous-or-abort)
  (define-key company-active-map (kbd "C-n") #'company-select-next-or-abort))

(require 'dired-x)
(setq-default dired-omit-files-p t) ; this is buffer-local variable
(setq dired-omit-files
      ;; (concat dired-omit-files "\\|^\\..+$\\|\\.pdf$\\|\\.tex$")
      (concat dired-omit-files "\\.lprof$")
      )

(setq-default mode-require-final-newline nil)  ; do not add new line, a yas-script issue


; avy-related
(global-set-key (kbd "M-g b") 'avy-goto-char-2)
(global-set-key (kbd "M-g a") 'avy-goto-char-timer)

(setq-default avy-timeout-seconds 0.5)  ; slow down to 1 sec


;; ; add ghostscript to exec-path
;; (setq exec-path (append exec-path '("/usr/local/bin/")))
;; (setq exec-path (append exec-path '("/Library/TeX/texbin/")))


; help AucTex find related binaries
(setenv "PATH"
         (concat
          "/usr/local/bin/" ":" "/Library/TeX/texbin/" ":"

          (getenv "PATH")))

; forward/reverse search between PDF and Latex source
(defun my/latex-buffer-setup ()
  (TeX-source-correlate-mode)
  (TeX-PDF-mode))

(add-hook 'LaTeX-mode-hook 'my/latex-buffer-setup)
(setq TeX-source-correlate-method 'synctex
      TeX-view-program-list   ;; Use Skim, it's awesome
      '(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline -g -b %n %o %b"))
      TeX-view-program-selection '((output-pdf "Skim"))
      TeX-auto-save t
      TeX-parse-self t
      TeX-save-query nil
      ;; TeX-master 'dwim
      )
;
(set-face-attribute 'default nil :height 200)  ; font size

(setq-default TeX-master "main") ; all master files called "main".

;; (setq TeX-parse-self t
;;       TeX-auto-regexp-list 'TeX-auto-full-regexp-list
;;       TeX-auto-parse-length 999999)



;; auto-complete for AucTex
(require 'auto-complete)
(add-to-list 'ac-modes 'latex-mode) ; beware of using 'LaTeX-mode instead
(require 'ac-math) ; package should be installed first 
(defun my-ac-latex-mode () ; add ac-sources for latex
   (setq ac-sources
         (append '(ac-source-math-unicode
           ac-source-math-latex
           ac-source-latex-commands)
                 ac-sources)))
(add-hook 'LaTeX-mode-hook 'my-ac-latex-mode)
(setq ac-math-unicode-in-math-p t)
(ac-flyspell-workaround) ; fixes a known bug of delay due to flyspell (if it is there)
(add-to-list 'ac-modes 'org-mode) ; auto-complete for org-mode (optional)
(require 'auto-complete-config) ; should be after add-to-list 'ac-modes and hooks
(ac-config-default)
;; (setq ac-auto-start nil)            ; if t starts ac at startup automatically
(setq ac-auto-show-menu t)
(global-auto-complete-mode t)


(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)

(setq ido-ignore-files '("\.cmake" "CMakeCache.txt"))

(setq ido-ignore-files
      (append ido-ignore-files '(".out" ".pdf" ".gz" ".log" "_region_*")))


(setq ido-ignore-files
      (append ido-ignore-files '(".out" ".pdf" ".gz" ".log" "_region_*" "auto/")))

(setq ido-ignore-directories
      (append ido-ignore-directories '("_region_*" "auto/")))

