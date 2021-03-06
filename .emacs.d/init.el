; Gentoo specific stuff
(require 'site-gentoo)

; minor modes I want on by default
(column-number-mode t)
(size-indication-mode t)
(icomplete-mode t)
; for some reason, I can't just start auto-fill mode, I have to add it
; as a hook
(add-hook 'text-mode-hook 'auto-fill-mode)
; automatically reload unmodified files from disk
(global-auto-revert-mode t)

; prefer UTF-8 encoding
(prefer-coding-system 'utf-8)

; must find out how to set these
(set-fill-column '80)

; makes vertical splits make more sense
(setq split-window-keep-point nil)

; highlight trailing whitespace
(setq-default show-trailing-whitespace t)

; prevent a message from being shown on every Emacs startup
(setq magit-last-seen-setup-instructions "1.4.0")

; add various package repositories
(require 'package)
(add-to-list 'package-archives
    '("marmalade" .
      "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
    '("melpa-stable" .
      "http://stable.melpa.org/packages/") t)
(package-initialize)

(setq package-list '(; misc. packages
		     auto-complete
		     autopair
		     fill-column-indicator
		     ido-ubiquitous
		     ido-vertical-mode
		     org-journal
		     smex
		     undo-tree
		     yasnippet
		     ; version control tools
		     find-file-in-repository
		     magit
		     magit-filenotify
		     ; python related (python-mode is installed via portage)
		     flymake-python-pyflakes
		     ein
		     ; themes
		     solarized-theme
		     ; spelling related
		     rw-hunspell
		     rw-language-and-country-codes))

; install the missing packages
(setq refreshed-package-contents? nil)
(dolist (package package-list)
  (when (not (package-installed-p package))
    (when (not refreshed-package-contents?)
      (package-refresh-contents)
      (setq refreshed-package-contents? t))
    (message "Installing package \"%s\"" package)
    (package-install package)))

; activate yasnippet globally, that is, activate the minor mode
; automatically per buffer; this is more robust than per-mode hooks,
; which would require (yas-reload-all) to load the snippets
(yas-global-mode)

; activate undo-tree mode
(global-undo-tree-mode t)

; TODO: look at icicles, it looks more general, but also more complex
;; (icy-mode t)

; set up IDO
(ido-mode t)
(setq ido-enable-flex-matching t)
(ido-everywhere)
(ido-ubiquitous-mode t)
(ido-vertical-mode t)

; set up smex, which completes commands with IDO, but also keep the
; old M-x around just in case
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(autopair-global-mode t)

; load fci-mode in text-mode derivatives
(add-hook 'text-mode-hook 'fci-mode)

; set up auto-complete-mode
(global-auto-complete-mode t)
(setq
 ac-use-fuzzy t
 ;ac-use-overriding-local-map t
 ac-use-menu-map t)

; find files in repository by default
(global-set-key (kbd "C-x f") 'find-file-in-repository)

; create nice keybindings for moving between windows
(windmove-default-keybindings)

(require 'paren)
(show-paren-mode t)
(setq
 show-paren-style 'mixed)

; set up python-mode
(require 'python-mode)
(setq-default
 py-shell-name "ipython"
 py-which-bufname "IPython")
(setq
 py-force-py-shell-name-p t
 py-smart-indentation t)
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(add-to-list 'interpreter-mode-alist '("ipython" . python-mode))
; flake8 errors out otherwise
(setq py-flake8-history nil)

; set up a flymake mode for flake8
(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)
(setq flymake-python-pyflakes-executable "flake8")

; set up autopair mode to handle triple quotes in python-mode
(add-hook 'python-mode-hook
	  #'(lambda ()
	      (setq autopair-handle-action-fns
		    (list #'autopair-default-handle-action
			  #'autopair-python-triple-quote-action))))

; activate octave-mode for m-Files
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))

; set up spell checking, use hunspell instead of ispell
(setq ispell-program-name "hunspell")
(require 'rw-ispell)
(require 'rw-hunspell)

; custom variables
(custom-set-variables
 ; automatically save the bookmarks file when creating bookmarks
 '(bookmark-save-flag 1)
 '(ein:use-auto-complete t)
 '(org-agenda-files (quote ("~/Dropbox/master/master_arbeit/arbeit.org")))
 '(py-python-command-args (quote ("-i" "--gui=qt4")))
 '(rw-hunspell-default-dictionary "de_DE_myspell")
 '(rw-hunspell-dicpath-list (quote ("/usr/share/myspell")))
 '(rw-hunspell-make-dictionary-menu t)
 '(rw-hunspell-use-rw-ispell t)
 '(rw-ispell-language-pdict-alist
   (quote
    (("^en" . "~/.emacs.d/pdict_english")
     ("^de" . "~/.emacs.d/pdict_deutsch")
     ("" . "~/.emacs.d/pdict_default"))))
 ; in addition to the clipboard (used by default), also use the primary selection
 '(x-select-enable-primary t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; set the *global* dictionary to de_DE (NOTE: using this function ensures that
; the personal dictionary is correctly set according to
; rw-ispell-language-pdict-alist)
;
; TODO it is possible to set multiple dictionaries with hunspell (e.g., "-d
; en_us,de_DE"), but so far nothing I know of exploits this
(rw-ispell-change-dictionary "de_DE_myspell" 1)

; configure org-mode to use latexmk for compiling LaTeX documents, since latexmk
; is a somewhat standard tool for compiling LaTeX documents; set
; org-latex-remove-logfiles to nil to prevent dependency problems
(setq org-latex-remove-logfiles nil)
(setq org-latex-pdf-process
 '("latexmk -pdflatex='pdflatex -shell-escape -interaction nonstopmode' -pdf -f %f"))

; automatically load ox-bibtex when loading org-mode documents; this contains
; the super-useful command org-reftex-citation, which is a great way for
; inserting citations from a BibTeX file
(add-hook 'org-mode-hook
 (lambda () (load-library "ox-bibtex")))

; override org-emphasis-regexp-components to allow footnotes after emphasis
; markup
(add-hook 'org-mode-hook
 (lambda ()
   (setcar
    (cdr org-emphasis-regexp-components)
    (concat (nth 1 org-emphasis-regexp-components) "["))
   (org-reload)))

; define a helper function that calls org-latex-export-to-pdf with a
; modified process-environment where TMPDIR=., in order to prevent a
; bibtex2html error; this is because TeXLive is configured to not
; allow writes (or some such) to /tmp/
(defun org-latex-export-to-pdf-with-bibtex ()
  "Runs org-latex-export-to-pdf with TMPDIR=., so that
bibtex2html does not fail."
  (interactive)
  (let ((process-environment (cons "TMPDIR=." process-environment)))
	 (org-latex-export-to-pdf)))

; the same for orb-beamer-export-to-pdf (see previous defun)
(defun org-beamer-export-to-pdf-with-bibtex ()
  "Runs org-beamer-export-to-pdf with TMPDIR=., so that
bibtex2html does not fail."
  (interactive)
  (let ((process-environment (cons "TMPDIR=." process-environment)))
	 (org-beamer-export-to-pdf)))

; customize the theme
(load-theme 'solarized-dark t t)
(enable-theme 'solarized-dark)
(set-background-color "black")
