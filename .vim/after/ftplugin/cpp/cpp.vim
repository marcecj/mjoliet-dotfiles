" Damn, that's slow. I should check for directories I can exclude.
setlocal tags+=~/.vim/tags/Cpp.tag
setlocal tags+=~/.vim/tags/C.tag
" nmap ,t :!(cd %:p:h;ctags *.[ch])&

" Custom options, making it more compatible to other peoples style
setlocal shiftwidth=4                 " Sets indent length (<<, >>, autoindent).
setlocal softtabstop=4                " How many spaces a <Tab> takes up (edit mode)
setlocal noexpandtab                  " Converts tabs to spaces

" override .vimrc setting
set cinkeys+=0#
set indentkeys+=0#
