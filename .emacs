;hides;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Load
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path
    "~/.emacs.d")
(add-to-list 'load-path
    "~/.emacs.d/icicles")
(add-to-list 'load-path
    "~/.emacs.d/elisp-buffer-timer")

(require 'package)
(package-initialize)
(setq package-archives
'(("ELPA" . "http://tromey.com/elpa/")
   ("gnu" . "http://elpa.gnu.org/packages/")
   ("melpa" . "http://melpa.milkbox.net/packages/")
   ("marmalade" . "http://marmalade-repo.org/packages/")))

;; Window position
(set-face-attribute 'default (selected-frame) :height 110)
(add-to-list 'default-frame-alist '(width . 210))
(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(left . 100))
(add-to-list 'default-frame-alist '(top . 50))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Global
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(global-set-key [C-tab] 'comint-dynamic-complete)

(defun zap-up-to-char (arg char)
  "Kill up to, but not including ARGth occurrence of CHAR.
Case is ignored if `case-fold-search' is non-nil in the current buffer.
Goes backward if ARG is negative; error if CHAR not found.
Ignores CHAR at point."
  (interactive "p\ncZap up to char: ")
  (let ((direction (if (>= arg 0) 1 -1)))
    (kill-region (point)
		 (progn
		   (forward-char direction)
		   (unwind-protect
		       (search-forward (char-to-string char) nil nil arg)
		     (backward-char direction))
		   (point)))))
(global-set-key "\M-Z" 'zap-up-to-char)

(defun kill-other-window ()
  "Kill the buffer in the other pane."
  (interactive)
  (other-window 1)
  (kill-this-buffer)
  (other-window -1)
  )
(global-set-key "\C-c\C-w" 'kill-other-window)

;; key to switch between windows
;;(global-set-key (kbd "s-`") 'other-window)

;; highlight brackets
(require 'paren)
(show-paren-mode 1)

;; colour highlighting
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

(global-set-key "\C-z" nil)  ;; prevent emacs from being minimized with C-Z

(global-set-key (kbd "C-<") 'previous-buffer)                                  
(global-set-key (kbd "C->") 'next-buffer)                                 
(global-set-key "\C-a" 'back-to-indentation)

;; use autofill on text modes
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; (require 'save-visited-files)
;; (turn-on-save-visited-files-mode)

;; (add-to-list 'load-path "~/.emacs.d/predictive/")
;; (add-to-list 'load-path "~/.emacs.d/predictive/latex/")
;; (require 'predictive)
;; ;http://www.emacswiki.org/emacs/PredictiveMode
;; (autoload 'predictive-mode "predictive" "predictive" t)
;; (set-default 'predictive-auto-add-to-dict t)
;; (setq predictive-main-dict 'rpg-dictionary
;;       predictive-auto-learn t
;;       predictive-add-to-dict-ask nil
;;       predictive-use-auto-learn-cache nil
;;       predictive-which-dict t)
(require 'auto-complete)

(setq max-lisp-eval-depth 10000)

(require 'pabbrev)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Colours
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load-theme 'wombat)
;; (load-theme 'tango-dark)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flyspell-duplicate ((t (:foreground "Gold3" :underline nil :weight bold))))
 '(font-latex-sectioning-2-face ((t (:inherit font-latex-sectioning-3-face :height 1.05))))
 '(font-latex-sectioning-3-face ((t (:inherit font-latex-sectioning-4-face :weight extra-bold :height 1.05))))
 '(font-latex-sectioning-4-face ((t (:inherit font-latex-sectioning-5-face :weight normal))))
 '(font-latex-sectioning-5-face ((t (:inherit variable-pitch :foreground "yellow" :weight bold :foundry "sans" :family "mono"))))
 '(font-lock-builtin-face ((t (:foreground "PeachPuff"))))
 '(font-lock-string-face ((t (:foreground "DarkSeaGreen2"))))
 '(font-lock-type-face ((t (:foreground "CadetBlue1"))))
 '(org-level-4 ((t (:foreground "khaki1" :inherit (outline-4)))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "darksalmon"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "LightGoldenrod4")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cua-delete-copy-to-register-0 nil)
 '(cua-enable-cua-keys t)
 '(cua-mode t nil (cua-base))
 '(ess-R-font-lock-keywords (quote ((ess-R-fl-keyword:modifiers . t) (ess-R-fl-keyword:fun-defs . t) (ess-R-fl-keyword:keywords . t) (ess-R-fl-keyword:assign-ops . t) (ess-R-fl-keyword:constants . t) (ess-fl-keyword:fun-calls . t) (ess-fl-keyword:numbers . t) (ess-fl-keyword:operators . t) (ess-fl-keyword:delimiters . t) (ess-fl-keyword:= . t) (ess-R-fl-keyword:F&T . t))))
 '(inhibit-startup-screen t)
 '(show-paren-mode t)
 '(sql-connection-alist nil)
 '(sql-product (quote postgres)))

;; (add-to-list 'auto-mode-alist '("\\.Rnw\\'" . Rnw-mode))
;; (add-to-list 'auto-mode-alist '("\\.rnw\\'" . Rnw-mode))
;; (add-to-list 'auto-mode-alist '("\\.Snw\\'" . Rnw-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Desktop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (require 'desktop)
(desktop-save-mode 1)
(desktop-read)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Latex, Sweave, etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; use reftex
  ; with AUCTeX LaTeX mode
(add-hook 'LaTeX-mode-hook 'turn-on-reftex) 
  ; with Emacs latex mode
(add-hook 'latex-mode-hook 'turn-on-reftex)
  ; use natural science bibliography style
(setq reftex-cite-format 'natbib)
(setq-default TeX-master nil)

;; (setq reftex-file-extensions
;;       '(("Snw" "Rnw" "nw" "tex" ".tex" ".ltx") ("bib" ".bib")))
;; (setq TeX-file-extensions
;;       '("Snw" "Rnw" "nw" "tex" "sty" "cls" "ltx" "texi" "texinfo"))

;; (setq ispell-program-name "ispell") ; could be ispell as well, depending on your preferences
(setq ispell-dictionary "english") ; this can obviously be set to any language your spell-checking program supports

(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-buffer)

(add-to-list 'ispell-skip-region-alist '("^<<.*>>=" . "^@"))
;; (add-to-list 'ispell-skip-region-alist '("Sexpr{" . "}"))
(defun flyspell-eligible ()
  (let ((p (point)))
    (save-excursion
      (cond ((re-search-backward (ispell-begin-skip-region-regexp) nil t)
             (ispell-skip-region (match-string-no-properties 0))
             (< (point) p))
            (t)))))
(put 'latex-mode 'flyspell-mode-predicate 'flyspell-eligible)
(put 'LaTeX-mode 'flyspell-mode-predicate 'flyspell-eligible)
(put 'Rnw-mode 'flyspell-mode-predicate 'flyspell-eligible)
(put 'ess-mode 'flyspell-mode-predicate 'flyspell-eligible)

(add-hook 'tex-mode-hook (function (lambda () (setq ispell-parser 'tex))))

;; (defun flyspell-ignore-verbatim ()
;;   "Function used for `flyspell-generic-check-word-predicate' to ignore {{{ }}} blocks."
;;   (save-excursion
;;     (widen)
;;     (let ((p (point))
;;           (count 0))
;;       (not (or (and (re-search-backward "^<<" nil t)
;;                     (> p (point))
;;                     ;; If there is no closing }}} then assume we're still in it
;;                     (or (not (re-search-forward "^@" nil t))
;;                         (< p (point))))
;;                (eq 1 (progn (while (re-search-backward "`" (line-beginning-position) t)
;;                               (setq count (1+ count)))
;;                             (- count (* 2 (/ count 2))))))))))
;; (put 'latex-mode 'flyspell-mode-predicate 'flyspell-ignore-verbatim)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    markdown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    ido-mode (autocompletion)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ido-mode t)
(setq ido-enable-flex-matching t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    uniquify (change file<2> to file/fold)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'uniquify) 
(setq uniquify-buffer-name-style 'post-forward)
(setq uniquify-after-kill-buffer-p t) ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    utils for finding non-ascii characters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Helper functions to find non-ascii characters
(defun find-first-non-ascii-char ()
  "Find the first non-ascii character from point onwards."
  (interactive)
  (let (point)
    (save-excursion
      (setq point
            (catch 'non-ascii
              (while (not (eobp))
                (or (eq (char-charset (following-char))
                        'ascii)
                    (throw 'non-ascii (point)))
                (forward-char 1)))))
    (if point
        (goto-char point)
        (message "No non-ascii characters."))))

(defun find-next-unsafe-char (&optional coding-system)
  "Find the next character in the buffer that cannot be encoded by
coding-system. If coding-system is unspecified, default to the coding
system that would be used to save this buffer. With prefix argument,
prompt the user for a coding system."
  (interactive "Zcoding-system: ")
  (if (stringp coding-system) (setq coding-system (intern coding-system)))
  (if coding-system nil
    (setq coding-system
          (or save-buffer-coding-system buffer-file-coding-system)))
  (let ((found nil) (char nil) (csets nil) (safe nil))
    (setq safe (coding-system-get coding-system 'safe-chars))
    ;; some systems merely specify the charsets as ones they can encode:
    (setq csets (coding-system-get coding-system 'safe-charsets))
    (save-excursion
      ;;(message "zoom to <")
      (let ((end  (point-max))
            (here (point    ))
            (char  nil))
        (while (and (< here end) (not found))
          (setq char (char-after here))
          (if (or (eq safe t)
                  (< char ?\177)
                  (and safe  (aref safe char))
                  (and csets (memq (char-charset char) csets)))
              nil ;; safe char, noop
            (setq found (cons here char)))
          (setq here (1+ here))) ))
    (and found (goto-char (1+ (car found))))
    found))

(defun occur-non-ascii ()
  "Find any non-ascii characters in the current buffer."
  (interactive)
  (occur "[^[:ascii:]]"))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    i-buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; rebind to use buffer-menu instead of list-buffers 
;; to keep everything in same buffer
(global-set-key "\C-x\C-b" 'ibuffer)
(setq ibuffer-default-sorting-mode 'filename/process)

;; set sorting column
(setq Buffer-menu-sort-column 4)

(setq ibuffer-formats
      '((mark modified read-only " "
	      (name 30 30 :left :elide)
	      " "
	      (size 6 -1 :right)
	      " "
	      (mode 10 10 :left :elide)
	      " " filename-and-process)
	(mark " "
	      (name 16 -1)
	      " " filename)))

(setq ibuffer-saved-filter-groups
      '(("home"
	 ("Kaikoura" (filename . "kaikoura"))
	 ("MMRA" (filename . "mmra-2013"))
	 ("Mammals 2013" (filename . "mammals-may"))
	 ("Northern royals" (filename . "northern-royal"))
	 ("emacs-config" (or (filename . ".emacs.d")
			     (filename . "emacs-config")
			     (filename . ".emacs"))))))
(add-hook 'ibuffer-mode-hook 
	  '(lambda ()
	     (ibuffer-switch-to-saved-filter-groups "home")))
(setq ibuffer-show-empty-filter-groups nil)
(add-hook 'ibuffer-mode-hook 
	  '(lambda ()
	     (ibuffer-auto-mode 1)
	     (ibuffer-switch-to-saved-filter-groups "home")))

(setq buffer-menu-buffer-font-lock-keywords 
      '(("^....[*]Man .*Man.*" . font-lock-variable-name-face) ;Man page 
	(".*Dired.*" . font-lock-comment-face) ; Dired 
	("^....[*]shell.*" . font-lock-preprocessor-face) ; shell buff 
	(".*[*]scratch[*].*" . font-lock-function-name-face) ; scratch buffer 
	("^....[*].*" . font-lock-string-face) ; "*" named buffers 
	("^..[*].*" . font-lock-constant-face) ; Modified 
	("^.[%].*" . font-lock-keyword-face))) ; Read only

(defun buffer-menu-custom-font-lock  ()
  (let ((font-lock-unfontify-region-function
	 (lambda (start end)
	   (remove-text-properties start end '(font-lock-face nil)))))
    (font-lock-unfontify-buffer)
    (set (make-local-variable 'font-lock-defaults)
	 '(buffer-menu-buffer-font-lock-keywords t))
    (font-lock-fontify-buffer)))

(add-hook 'ibuffer-menu-mode-hook 'buffer-menu-custom-font-lock)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Code folding & indentation & formatting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'rainbow-delimiters)
(global-rainbow-delimiters-mode)

;; Highlight region between parentheses
;; (require 'paren)
;; (set-face-background 'show-paren-match-face "#696969")
;; (set-face-foreground 'show-paren-match-face "#def")
;; (set-face-attribute 'show-paren-match-face nil :weight 'extra-bold)
;; (setq show-paren-delay 0)
;; (show-paren-mode 1)

(require 'highlight-indentation)
(add-hook 'ess-mode-hook 'highlight-indentation-mode) 
(add-hook 'lisp-mode-hook 'highlight-indentation-mode)

(defun aj-toggle-fold () 
  "Toggle fold all lines larger than indentation on current line" 
  (interactive) 
  (let ((col 1)) 
    (save-excursion 
      (back-to-indentation) 
      (setq col (+ 1 (current-column))) 
      (set-selective-display 
       (if selective-display nil (or col 1))))))
(global-set-key (kbd "M-C-i") 'aj-toggle-fold)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Julia
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq inferior-julia-program-name "~/Deps/julia/usr/bin/julia-basic")
(add-to-list 'load-path "~/Deps/julia/contrib")
(require 'julia-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    ESS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'ess-jags-d)
(autoload 'ess-jags-mode "ess-jags-mode"
   "Major mode for editing JAGS files" t)
(add-to-list 'auto-mode-alist '("\\.bug\\'" . ess-jags-mode))

(require 'ess-eldoc) ;to show function arguments while you are typing them

(setq ess-eval-visibly-p nil) ;otherwise C-c C-r (eval region) takes forever
(setq ess-ask-for-ess-directory nil) ;otherwise you are prompted each time you start

(setq ess-local-process-name "R")
(setq ansi-color-for-comint-mode 'filter)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)
(defun my-ess-start-R ()
  (interactive)
  (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
      (progn
	(delete-other-windows)
	(setq w1 (selected-window))
	(setq w1name (buffer-name))
	(setq w2 (split-window w1 nil t))
	(R)
	(set-window-buffer w2 "*R*")
	(set-window-buffer w1 w1name))))
(defun my-ess-eval ()
  (interactive)
  (my-ess-start-R)
  (if (and transient-mark-mode mark-active)
      (call-interactively 'ess-eval-region)
    (call-interactively 'ess-eval-line-and-step)))
(add-hook 'ess-mode-hook
	  '(lambda()
	     (local-set-key [(shift return)] 'my-ess-eval)))
(add-hook 'inferior-ess-mode-hook
	  '(lambda()
	     (local-set-key [C-up] 'comint-previous-input)
	     (local-set-key [C-down] 'comint-next-input)))
;; (require 'ess-site)
(load "~/Deps/ESS/lisp/ess-site")

(ess-toggle-underscore nil)
(setq ess-S-assign-key [?\C-=])
(ess-toggle-S-assign-key t)
;; (ess-auto-newline t)

(defun comint-interrupt-subjob-other ()
  "Interrupt process in the other pane."
  (interactive)
  (other-window 1)
  (comint-interrupt-subjob)
  (other-window -1)
  )
(global-set-key "\C-c\C-q" 'comint-interrupt-subjob-other)

(defun interupt-job-other-window ()
  "Interupt job in other pane."
  (interactive)
  (other-window 1)
  (comint-interrupt-subjob)
  (other-window -1)
  )
(global-set-key "\C-c\C-a" 'interupt-job-other-window)

(setq ess-indent-level 4)


(global-set-key [C-tab] 'other-window)

(define-key comint-mode-map [C-up] 'comint-previous-matching-input-from-input)
(define-key comint-mode-map [C-down] 'comint-next-matching-input-from-input)

;(defun uncomment-region (beg end)
;  (interactive "r")
 ; (comment-region beg end -1))

;(define-key ess-mode-map (kbd "\C-d") 'comment-region)
;(define-key ess-mode-map (kbd "\C-S-d") 'uncomment-region)

;; Delete selection when pressing [delete] key
  (delete-selection-mode t)

;; ESS Mode (.R file)
  (define-key ess-mode-map "\C-RET" 'ess-eval-line-and-step)
  (define-key ess-mode-map "\C-p" 'ess-eval-function-or-paragraph-and-step)
  (define-key ess-mode-map "\C-RET" 'ess-eval-region)

;; iESS Mode (R console)
  (define-key inferior-ess-mode-map "\C-u" 'comint-kill-input)
  (define-key inferior-ess-mode-map "\C-w" 'backward-kill-word)
  (define-key inferior-ess-mode-map "\C-a" 'comint-bol)
  (define-key inferior-ess-mode-map [home] 'comint-bol)

;; Comint Mode (R console as well)
  (define-key comint-mode-map "\C-e" 'comint-show-maximum-output)
  (define-key comint-mode-map "\C-r" 'comint-show-output)
  (define-key comint-mode-map "\C-o" 'comint-kill-output)

;; Search with C-f / C-F (control-maj-F for backware search)
   (global-set-key "\C-f" 'isearch-forward)
   (global-set-key (kbd "C-S-f") 'isearch-backward)
   (define-key isearch-mode-map "\C-f" 'isearch-repeat-forward)
   (define-key isearch-mode-map (kbd "C-S-f") 'isearch-repeat-backward)

;; Save with C-s / C-S
  (global-set-key (kbd "C-s") 'save-buffer)
  (global-set-key (kbd "C-S-s") 'write-file)
  ;; need to redefine them for isearch mode (don't know why)
  (define-key isearch-mode-map (kbd "C-s") 'save-buffer)
  (define-key isearch-mode-map (kbd "C-S-s") 'write-file)

;; Pause = dedicate window. 
  (defun toggle-current-window-dedication ()
   (interactive)
   (let* ((window    (selected-window))
          (dedicated (window-dedicated-p window)))
     (set-window-dedicated-p window (not dedicated))
     (message "Window %sdedicated to %s"
              (if dedicated "no longer " "")
              (buffer-name))))
  (global-set-key [pause] 'toggle-current-window-dedication)

;; delete = delete
  (global-set-key [delete] 'delete-char)

;; C-b = list buffers
  (global-set-key (kbd "C-b") 'bs-show)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    org-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-src-fontify-natively t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Load hideshow and enable for ESS
(autoload 'hideshowvis-enable "hideshowvis" "Highlight foldable regions")
(dolist (hook (list 'emacs-lisp-mode-hook
                  'ess-mode-hook))
(add-hook hook 'hideshowvis-enable))
(setq hs-special-modes-alist
    (cons '(ess-mode "{" "}" "#" nil nil) hs-special-modes-alist))

(define-fringe-bitmap 'hs-marker [0 24 24 126 126 24 24 0])

(defcustom hs-fringe-face 'hs-fringe-face
  "*Specify face used to highlight the fringe on hidden regions."
  :type 'face
  :group 'hideshow)

(defface hs-fringe-face
  '((t (:foreground "#888" :box (:line-width 2 :color "grey75" :style
released-button))))
  "Face used to highlight the fringe on folded regions"
  :group 'hideshow)

(defcustom hs-face 'hs-face
  "*Specify the face to to use for the hidden region indicator"
  :type 'face
  :group 'hideshow)

(defface hs-face
  '((t (:background "#ff8" :box t)))
  "Face to hightlight the ... area of hidden regions"
  :group 'hideshow)

(defun display-code-line-counts (ov)
  (when (eq 'code (overlay-get ov 'hs))
    (let* ((marker-string "*fringe-dummy*")
           (marker-length (length marker-string))
           (display-string (format "(%d)..." (count-lines
(overlay-start ov) (overlay-end ov))))
           )
      (overlay-put ov 'help-echo "Hiddent text. C-c,= to show")
      (put-text-property 0 marker-length 'display (list 'left-fringe
'hs-marker 'hs-fringe-face) marker-string)
      (overlay-put ov 'before-string marker-string)
      (put-text-property 0 (length display-string) 'face 'hs-face
display-string)
      (overlay-put ov 'display display-string)
      )))

(setq hs-set-up-overlay 'display-code-line-counts)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; Load hideshow-org (http://github.com/secelis/hideshow-org/tree/master)
;(require 'hideshow)
;(require 'hideshow-org)
;(add-to-list 'hs-special-modes-alist
 ;           '(ess-mode "{" "}" "/[*/]" nil
;hs-c-like-adjust-block-beginning))
;(global-set-key "\C-ch" 'hs-org/minor-mode) ;; toggles hideshow-org
; (add-hook 'ess-mode-hook 'hs-org/minor-mode) ;; starts for ESS files
;(add-hook 'ess-mode-hook '(lambda () (hs-org/minor-mode 1)))
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    buffer-timer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (require 'buffer-timer)

;; ; Example list of titles and regexps to group by.  This
;; (setq buffer-timer-regexp-master-list
;;   '(
;;     ("idle" . 
;;      (("generic" .			  "^\\*idle\\*")
;;       ("generic2" .			  "^\\*idle-2\\*")
;;       ("minibuf" .                        "^ \\*Minibuf-.*")))
;;     ("customizations" .                   "\\.emacs")
;;     ("work" .
;;      (("my R pkg" .                       "yr-r-package")
;;       ("seabird counts" .
;;        (("Main project" .                 "abundance")
;; 	("Web site" .                     "seabird-counts-website")))
;;       ("SRA 2012" .
;;        (("analysis" .                     "sra-2012/analysis")
;; 	("report" .                       "sra-2012/report")))
;;       ("Encounter kaikoura" .
;;        (("data" .                          "encounter-kaikoura/data")
;; 	("analysis" .                      "encounter-kaikoura/analysis")
;; 	("plots" .                         "encounter-kaikoura/plots")
;; 	("report" .                        "encounter-kaikoura/report")))
;;       ("XNR Taiaroa" .
;;        (("data" .                          "northern-royal-albatross-taiaroa/data")
;; 	("analysis" .                      "northern-royal-albatross-taiaroa/analysis")
;; 	("plots" .                         "northern-royal-albatross-taiaroa/plots")
;; 	("report" .                        "northern-royal-albatross-taiaroa/report")))
;;       ("R terminal" .                     "^\\*R\\*$")
;;       ("Dragonfly others" .               "/dragonfly/")))
;;     )
;; )

