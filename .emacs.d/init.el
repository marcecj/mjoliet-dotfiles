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
(package-initialize)

; must be after (package-initialize)
(require 'undo-tree)
(global-undo-tree-mode)
(require 'org-journal)

; set up go mode
(require 'go-mode-load)

; set up spell checking, use hunspell instead of ispell
(setq ispell-program-name "hunspell") 
(require 'rw-language-and-country-codes)
(require 'rw-ispell)
(require 'rw-hunspell)
(setq ispell-dictionary "de_DE_myspell")

; activate octave-mode for m-Files
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))

; custom variables
(custom-set-variables
 ; in addition to the clipboard (used by default), also use the primary selection
 '(x-select-enable-primary t)
 ; automatically save the bookmarks file when creating bookmarks
 '(bookmark-save-flag 1)
 '(rw-hunspell-default-dictionary "de_DE_myspell")
 '(rw-hunspell-dicpath-list (quote ("/usr/share/myspell")))
 '(rw-hunspell-make-dictionary-menu t)
 '(rw-hunspell-use-rw-ispell t))
