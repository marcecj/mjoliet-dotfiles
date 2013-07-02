" Copyright (c) 2009 Marc Joliet <marcec@gmx.de>
"
" A python extension for vim that, if the visual area takes up more than one
" line, reverses the order of lines, else switches order of characters in the
" selected range.
"
" This is a reimplementation of Textmates transpose feature for vim, done pretty
" much just for fun. It might be better to do this in vim-script, but I already
" know Python, so...

python << EOF
import vim
def transpose():
    w = vim.current.window
    b = vim.current.buffer
    ls, cs = b.mark('<')
    le, ce = b.mark('>')
    r = b.range(ls,le)

    # Swap the selected lines if the selection spans multiple lines, else
    # reverse the chars in the selection (per line).
    if abs(le-ls)>0:
        r[:] = r[:][-1::-1]
        return

    enc = vim.eval("&encoding")

    # This is needed, since when the '>' mark lies on a multibyte character
    # vim only returns the column of it's first byte.
    w.cursor = ls,ce
    vim.command(":silent! normal l")
    col = w.cursor[1]
    w.cursor = ls,cs
    # cursor couldn't move right, so must be end of line; elif difference is
    # >1, so current char must be multibyte; else no change
    if col == ce:
        ce = len(r[0])
    elif col-ce > 1:
        ce = col - 1

    r1 = r[0][:cs].decode(enc)
    rr = r[0][cs:ce+1].decode(enc)[-1::-1]
    r2 = r[0][ce+1:].decode(enc)

    r[0] = (r1 + rr + r2).encode(enc, "backslashreplace")
EOF
