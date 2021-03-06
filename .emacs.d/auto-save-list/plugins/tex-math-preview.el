;;; tex-math-preview.el --- preview TeX math expressions.

;; Copyright 2006, 2007, 2008, 2009, 2010, 2011 Kevin Ryde

;; Author: Kevin Ryde <user42@zip.com.au>
;; Version: 12
;; Keywords: tex
;; URL: http://user42.tuxfamily.org/tex-math-preview/index.html
;; EmacsWiki: TexMathPreview
;; Compatibility: Emacs 21, Emacs 22
;; Incompatibility: XEmacs 21

;; tex-math-preview.el is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; tex-math-preview.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
;; Public License for more details.
;;
;; You can get a copy of the GNU General Public License online at
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; M-x tex-math-preview previews TeX math expressions.  Put point in a TeX,
;; LaTeX, Texinfo, Wikipedia or DBTexMath math expression and M-x
;; tex-math-preview shows either an image or TeX error messages.
;;
;; `tex-mode' has its own far more substantial buffer and region previewing,
;; but tex-math-preview is intentionally simpler and is geared towards
;; unsophisticated TeX users.
;;
;; This started for Texinfo as a way to check how "@tex $$ $$ @end tex"
;; forms come out, and @math{} after it became TeX-ified.  The LaTeX bits
;; haven't had quite as much use, and there might be better ways to choose
;; between TeX or LaTeX.  See also latex-math-preview.el for an adaption
;; designed specifically for that, http://www.emacswiki.org/LaTeXMathPreview

;;; Emacsen:

;; Designed for Emacs 21 up.
;;
;; Doesn't work in XEmacs due to some absent functions there and because
;; `shell-command' doesn't return an exit status.  Could add the extra
;; functions but redoing shell-command is too much like hard work.
;;
;; Can work in Emacs 20 if you get load poe.el for `make-temp-file', and
;; from later Emacs get `derived-mode-p' (derived.el) and
;; `replace-regexp-in-string' (subr.el).

;;; Install:

;; To make M-x tex-math-preview available put tex-math-preview.el in one of
;; your `load-path' directories and add following to your .emacs
;;
;;     (autoload 'tex-math-preview "tex-math-preview" nil t)
;;
;; There's an autoload cookie for this, if you try `update-file-autoloads'
;; and friends.
;;
;; Bind the command to a key if desired, eg. f8 in texinfo-mode,
;;
;;     (add-hook 'texinfo-mode-hook
;;                (lambda ()
;;                  (define-key texinfo-mode-map [f8] 'tex-math-preview)))

;;; History:

;; Version 1 - the first version
;; Version 2 - multi-line <math> reported by Uwe Brauer; better $...$ matching
;; Version 3 - also images in a buffer using dvipng
;; Version 4 - yet better $...$ handling, add some dbtexmath
;; Version 5 - add latex \(...\) and \[...\] suggested by Rodrigo Lazo
;; Version 6 - use "-T tight" on dvipng for maximum on screen
;; Version 7 - run latex on $$ forms when in latex-mode
;;           - for latex include \usepackage{} commands from the buffer
;; Version 8 - use image-mode or auto-image-file-mode for buffer
;; Version 9 - remove thing-at-point on unload-feature
;; Version 10 - customize fixes
;; Version 11 - use derived-mode-p to recognise slitex-mode etc as latex
;; Version 12 - add [; ;] tex-the-world suggested by Barton
;;            - add latex \begin{equation}, amsmath \begin{align}
;;            - org-mode $...$ is latex 

;;; Code:

(require 'thingatpt)
(require 'derived) ;; emacs21 `derived-mode-p' is not preloaded 
(eval-when-compile
  (require 'cl)) ;; for dolist in emacs20

;;;###autoload
(defgroup tex-math-preview nil
  "Tex Math Preview."
  ;; Partial prefix tex-math to display `tex-math-preview-function' as
  ;; "preview function", except :prefix disabled as of emacs23.
  :prefix "tex-math-"
  :group  'tex
  :link   '(url-link
            :tag "tex-math-preview home page"
            "http://user42.tuxfamily.org/tex-math-preview/index.html"))

(defcustom tex-math-preview-function
  'tex-math-preview-adaptview
  "Function for `tex-math-preview' to show a DVI file.
The default `tex-math-preview-adaptview' chooses among the
methods, according to what Emacs and the system supports."
  :type  '(radio (function-item tex-math-preview-adaptview)
                 (function-item tex-math-preview-dvi-view)
                 (function-item tex-math-preview-png-image)
                 function)
  :group 'tex-math-preview)
;; automatically `risky-local-variable-p' due to name `-function'


;;-----------------------------------------------------------------------------

(defun tex-math-preview-bounds-of-tex-math ()
  "A `bounds-of-thing-at-point' function for a TeX math expression.
See `tex-math-preview' for what's matched.
The return is a pair of buffer positions (START . END), or nil if
no recognised expression at or surrounding point."

  ;; TeX style $...$ could easily match some huge chunk of the buffer, and
  ;; even @math{...} or <math>...</math> could occur in comments or some
  ;; unrelated context.  So it's not reliable just to take the first of
  ;; these which match, instead the strategy is to check for all forms
  ;; around point and take the one that's the smallest.
  ;;
  ;; Only the start position of the match is considered for "smallest", the
  ;; one that's the shortest distance before point (but covering point of
  ;; course) in the buffer is taken.

  (let (case-fold-search beg end)

    ;; $...$ and $$...$$
    ;; thing-at-point-looking-at doesn't work on "$...$".  The way the start
    ;; and end are the same (ie. "$") breaks the straightforward
    ;; implementation of that function; so the idea here is to search back
    ;; for the starting "$", and one not "\$" escaped, then check the $...$
    ;; extent covers point
    (save-excursion
      (while (and (search-backward "$" nil t) ;; $ not preceded by \
                  (eq ?\\ (char-before))))
      (when (looking-at "\\$+\\(\\(?:\\\\\\$\\|[^$]\\)+?\\)\\$")
        (setq beg (match-beginning 1) end (match-end 1))))

    (dolist (elem
             '(;; <math>...</math>
               (1 . "<math>\\(\\(.\\|\n\\)*?\\)</math>")

               ;; @math{...}
               (1 . "@math{\\(\\(.\\|\n\\)*?\\)}")

               ;; <alt role="tex">$...$</alt>
               ;; <alt role="tex">\[...\]</alt>
               ;; the contents $..$ or \[..\] of the alt can be recognised
               ;; on their own, but with this pattern we can work with point
               ;; in the <alt> part as well as in the expression
               (1 . "<alt\\s-+role=\"tex\">\\$*\\(\\(.\\|\n\\)+?\\)\\$*</alt>")

               ;; \[...\]
               (0 . "\\\\\\[\\(.\\|\n\\)*?\\\\]")

               ;; \(...\)
               (0 . "\\\\(\\(.\\|\n\\)*?\\\\)")

               ;; [;...;]
               (0 . "\\[;\\(.\\|\n\\)*?;]")

               ;; \begin{math}...\end{math}
               ;; \begin{displaymath}...\end{displaymath}
               (0 . "\\\\begin{\\(\\(display\\)?math\\|equation\\|align\\*?\\)}\\(\\(.\\|\n\\)*?\\)\\\\end{\\1}")))

      (when (thing-at-point-looking-at (cdr elem))
        ;; if no other match, or this match is later, then override
        (if (or (not beg)
                (> (match-beginning (car elem)) beg))
            (setq beg (match-beginning (car elem)) end (match-end (car elem))))))

    (and beg
         (cons beg end))))
          
(put 'tex-math 'bounds-of-thing-at-point 'tex-math-preview-bounds-of-tex-math)

;;;###autoload
(defun tex-math-preview ()
  "Preview a TeX mathematical expression at or surrounding point.
The expressions recognised are

    $...$ or $$...$$              TeX or LaTeX
    \\(...\\) or \\=\\[...\\]            LaTeX
    \\begin{math}...\\end{math}     LaTeX
    \\begin{displaymath}...        LaTeX
    \\begin{equation}...           LaTeX
    \\begin{align}, {align*}       LaTeX with amsmath
    @math{...}                    Texinfo (plain TeX)
    <math>...</math>              Wikipedia (plain TeX)
    <alt role=\"tex\">...</alt>     DBTexMath (TeX or LaTeX)
    [; ... ;]                     Tex-the-World (LaTeX)

$...$ forms use plain tex by default, or latex if the buffer is
`latex-mode' (or a derivative).  DBTexMath is plain tex by
default, or latex if it contains \\(...\\) or \\=\\[...\\].  For
latex any \\usepackage{} directives in the buffer are included
for possible maths extensions.  In each case
`tex-math-preview-function' controls viewing the resulting dvi.

\"$\" is both a start and end for TeX forms, making it slightly
ambiguous.  `tex-math-preview' assumes point is inside the
expression, so when just after a \"$\" then that's the start, or
when just before then that's the end.  If point is in between two
\"$$\" then that's considered the start of a \"$$\" form.

`org-mode' formulas can be previewed natively with its
`org-preview-latex-fragment' (Info node `(org)LaTeX fragments'
and Info node `(org)Previewing LaTeX fragments').
`tex-math-preview' can be used too.  $...$ and $$ forms are put
through latex, and in new enough org the
`org-export-latex-packages-alist' etc is incorporated.

For more on the respective forms see

    URL `http://www.latex-project.org/'
    Info node `(texinfo)math'
    URL `http://meta.wikimedia.org/wiki/Help:Displaying_a_formula'
    URL `http://ricardo.ecn.wfu.edu/~cottrell/dbtexmath/'
    URL `http://thewe.net/tex/'
    URL `http://orgmode.org'

The tex-math-preview.el home page is
URL `http://user42.tuxfamily.org/tex-math-preview/index.html'"

  (interactive)
  (let ((str (thing-at-point 'tex-math)))
    (or str
        (error "Not in a TeX math expression"))
    (tex-math-preview-str str)))

(defun tex-math-preview-usepackages ()
  "Return a string of latex \\usepackage directives from the buffer.
If there's no usepackage directives then return an empty string."
  (save-excursion
    (goto-char (point-min))
    (let ((ret ""))
      (while (re-search-forward "^\\\\usepackage[{[].*" nil t)
        (setq ret (concat ret (match-string 0) "\n")))
      ret)))

(defun tex-math-preview-str (str)
  "Preview the given STR string as a TeX math expression.
STR should not have $ or $$ delimiters."

  (let* ((tex-math-dir (make-temp-file "tex-math-preview-" t))
         (dot-tex      (expand-file-name "foo.tex" tex-math-dir))
         (dot-dvi      (expand-file-name "foo.dvi" tex-math-dir))
         (dot-log      (expand-file-name "foo.log" tex-math-dir))
         (dot-aux      (expand-file-name "foo.aux" tex-math-dir))
         ;; \[ or \( or \begin anywhere means latex
         (tex-cmd      (if (or (derived-mode-p 'latex-mode)
                               (derived-mode-p 'org-mode)
                               (string-match "\\\\[[(]\\|\\`\\[;\\|begin" str))
                           "latex"
                         "tex"))
         ;; As per `org-create-formula-image' and `org-splice-latex-header'.
         (org-packages (and (derived-mode-p 'org-mode)
                            ;; new in org 7 or some such
                            (fboundp 'org-latex-packages-to-string)
                            (concat (org-latex-packages-to-string
                                     org-export-latex-default-packages-alist)
                                    (org-latex-packages-to-string
                                     org-export-latex-packages-alist)))))

    (with-temp-file dot-tex
      (if (equal "tex" tex-cmd)
          (progn
            ;; must be careful with the newlines here, a blank line inside
            ;; $$...$$ would be a paragraph separator, which tex doesn't
            ;; allow; let any in the user's input go through to see the
            ;; error, but be careful not to add a \n here before or after $$
            ;; in case that and the user input makes \n\n
            (insert "$$ ")
            (insert str)
            (insert " $$\n\\par\\bye\n"))

        ;; TeX-the-World goes to http://www.codecogs.com/gif.latex?a+b
        ;; like http://www.codecogs.com/latex/eqneditor.php
        ;; What does it's wrapping normally include?
        ;;
        ;; Seems `org-format-latex-header' has \package{amsmath} explicitly
        ;; rather than through `org-export-latex-default-packages-alist', so
        ;; work that in here similarly.  Is that right?  Hopefully can rely
        ;; on anyone who has latex will have amsmath.
        ;;
        (insert "\\documentclass{article}\n")
        (insert (tex-math-preview-usepackages))
        (when (string-match "\\\\begin{align" str)
          (insert "\\usepackage{amsmath}\n"))
        (when org-packages
          (insert "\\usepackage{amsmath}\n"
                  org-packages)
          (require 'org-latex)
          ;; fill-in AUTO of \package[AUTO]{inputenc}
          (when (fboundp 'org-export-latex-fix-inputenc)
            (save-excursion
              (org-export-latex-fix-inputenc))))
        (insert "\\pagestyle{empty}\n")
        (insert "\\begin{document}\n")
        (cond ((string-match "\\`\\[;" str)
               (insert "\\begin{math}"
                       (substring str 2
                                  (if (string-match ";]\\'" str)
                                      -2 nil))
                       "\\end{math}"))
              ((string-match "\\`$\\|\\\\\\([[(]\\|begin\\)" str)
               (insert str))
              (t
               (insert "$" str "$")))
        (insert "\\par\n")
        (insert "\\end{document}\n")))

    (unwind-protect
        ;; don't show all the tex ramblings in the minibuffer, leave it to
        ;; the shell buffer, and show that only if there's an error (ie. put
        ;; back window config if no error)
        ;;
        (let ((max-mini-window-height 1)  ;; force shell-command to buffer
              (windows (current-window-configuration)))
          (if (not (eq 0 (shell-command
                          (concat tex-cmd " -output-directory " tex-math-dir
                                  " " dot-tex " </dev/null"))))
              (error "TeX processing error")

            (set-window-configuration windows)
            (funcall tex-math-preview-function dot-dvi)))

      ;; cleanup temp files
      (dolist (filename (list dot-tex dot-dvi dot-log dot-aux))
        (condition-case nil (delete-file filename) (error)))
      (delete-directory tex-math-dir))))


;;-----------------------------------------------------------------------------
;; adaptive viewer selection

(defun tex-math-preview-adaptview (filename)
  "Display dvi FILENAME using either png image or `tex-dvi-view-command'.
A PNG image in a buffer per `tex-math-preview-png-image' is used
if possible, or if not then the `tex-mode' previewer given by
`tex-dvi-view-command' (like `tex-math-preview-dvi-view' uses).

This function is the default for `tex-math-preview-function',
allowing `tex-math-preview' to adapt to the Emacs display
capabilities and available viewer program(s)."

  (if (and (boundp 'image-type-available-p) ;; not in emacs20
           (image-type-available-p 'png)
           (display-images-p)
           (eq 0 (shell-command "dvipng --version >/dev/null 2>&1" nil)))
      (tex-math-preview-png-image filename)
      (tex-math-preview-dvi-view filename)))


;;-----------------------------------------------------------------------------
;; view by running tex-dvi-view-command

(defun tex-math-preview-dvi-view (filename)
  "Display dvi FILENAME using `tex-dvi-view-command'.
This can be used in `tex-math-preview-function'.

The default `tex-dvi-view-command' under X is xdvi and it works
well.  On an SVGA console of a GNU/Linux system you can use
dvisvga (from tmview), or perhaps try a combination of dvipng (or
dvips+ghostscript) and a console image viewer like zgv.  Any
program output is shown in a buffer, which is good for error
messages but if it prints a startup banner etc you'll want to
find a \"quiet\" mode or use a wrapper script to grep that out."

  (eval-and-compile
    (require 'tex-mode))

  ;; eval/expand like `tex-view' and `tex-send-command' do
  (let* ((template (eval tex-dvi-view-command))
         (command  (replace-regexp-in-string "\\*" filename
                                             template t t)))
    (if (string-equal command template)
        (setq command (concat command " " filename)))
    (shell-command command)))


;;-----------------------------------------------------------------------------
;; view png in a buffer

(defmacro tex-math-preview--with-auto-image-file-mode (&rest body)
  "Evaluate BODY with `auto-image-file-mode' enabled."
  ;; (declare (debug t))  ;; emacs22,xemacs21, or 'cl
  `(let ((tex-math-preview--with-auto-image-file-mode--old
          auto-image-file-mode))
     (unwind-protect
         (progn
           (auto-image-file-mode 1)
           ,@body)
       (if (not tex-math-preview--with-auto-image-file-mode--old)
           (auto-image-file-mode 0)))))

(defun tex-math-preview-png-image (filename)
  "Display dvi FILENAME as a png image in a buffer.
This can be used in `tex-math-preview-function', but it requires:

* the \"dvipng\" program (URL `http://sourceforge.net/projects/dvipng/')
* a display which can show images (eg. X, not a tty)
* Emacs built with the PNG image libraries

The \"*tex-math-preview*\" buffer uses `image-mode' when
available (Emacs 22 and up), or `auto-image-mode' if not (Emacs
21).  You can save the buffer contents if desired.  (The buffer
coding system will come from the usual \".png\" file setups,
normally per `auto-coding-alist'.)"

  (unless (and (boundp 'image-type-available-p) ;; not in emacs20
               (image-type-available-p 'png)
               (display-images-p))
    (error "Cannot display PNG in this Emacs"))

  (let ((dot-png (expand-file-name "foo.png" tex-math-dir))
        (inhibit-read-only t))
    (when (eq 0 (shell-command (concat "dvipng -T tight -x 1728 -o" dot-png
                                       " " filename)))
      (unwind-protect
          (save-selected-window
            (switch-to-buffer-other-window "*tex-math-preview*")
            (erase-buffer)

            ;; no need to lock down (fboundp 'image-mode) with an
            ;; eval-when-compile, can use it if someone has back-ported to
            ;; emacs21
            (if (fboundp 'image-mode)
                (progn
                  ;; emacs22
                  (insert-file-contents dot-png)
                  (image-mode))

              ;; emacs21
              (tex-math-preview--with-auto-image-file-mode
               (insert-file-contents dot-png))))

        (delete-file dot-png)))))


;;-----------------------------------------------------------------------------

(defun tex-math-preview-unload-function ()
  "Undo tex-math-preview.el stuff."
  (put 'tex-math 'bounds-of-thing-at-point nil)
  nil) ;; and do normal unload-feature actions too

;; LocalWords: DBTexMath usepackage xdvi dvisvga tmview dvipng ghostscript zgv dvips

(provide 'tex-math-preview)

;;; tex-math-preview.el ends here
