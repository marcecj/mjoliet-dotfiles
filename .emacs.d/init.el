; Gentoo specific stuff
(require 'site-gentoo)

; minor modes I want on by default
(column-number-mode)
(size-indication-mode)
; FIXME: for some reason, this doesn't work as-is
(auto-fill-mode)

; prefer UTF-8 encoding
(prefer-coding-system 'utf-8)

; must find out how to set these
(set-fill-column '80)

; add various package repositories
(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives 
    '("melpa" .
      "http://melpa.milkbox.net/packages/"))
(package-initialize)

; must be after (package-initialize)
(require 'undo-tree)
(global-undo-tree-mode)
(require 'org-journal)
(require 'ipython)

; set up go mode
(require 'go-mode-load)

; activate octave-mode for m-Files
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))

; set up spell checking, use hunspell instead of ispell
(setq ispell-program-name "hunspell")
(require 'rw-language-and-country-codes)
(require 'rw-ispell)
(require 'rw-hunspell)

; custom variables
(custom-set-variables
 ; automatically save the bookmarks file when creating bookmarks
 '(bookmark-save-flag 1)
 '(ein:use-auto-complete t)
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
