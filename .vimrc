" vim:foldmethod=marker

" vimrc of Marc Joliet <marcec@gmx.de>
"
" For filetype dependent settings, edit ~/.vim/after/ftplugin/<ft>.vim
" Note: the files in that directory are processed *after* the system-wide ones!

" {{{ Startup Options

" fix behaviour under fish
if &shell == "/bin/fish"
    set shell=bash
endif

" this example vimrc already does several nice things I don't have to care about
source $VIMRUNTIME/vimrc_example.vim

" Show a smallish menu for possible completions upon pressing <tab>.
" To navigate into a directory, press <down>.
set wildmenu

set timeoutlen=500
set ttimeoutlen=200
" NOTE: alternative would be ":folddoopen s/.../.../...
" TODO: Should I just omit textwidth, or set it to something higher?
set textwidth=79                 " set the max line length to 79 chars
set linebreak					 " visually break long lines between words
set shiftwidth=4                 " Sets indent length (<<, >>, (auto-)indent).
set tabstop=4                    " How many spaces a <Tab> takes up (viewing a file).
set softtabstop=4                " How many spaces a <Tab> takes up (edit mode)
set expandtab                    " Converts tabs to spaces
set foldmethod=syntax
set formatoptions=tcrqnl         " formatting options
set cpoptions+=J                 " Make sentences start with >=2 spaces
set number                       " Display line numbers
set printoptions=syntax:y,number:y,wrap:y " print line numbers and wrap lines
set ignorecase smartcase         " ignores case when search pattern contains lower case only
set spell spelllang=en,de        " activate spell checking and check English, then German
" set smartindent                  " Smart indenting (ignored if cindent is on).
" set go+=a                        " Copies a visual selection to the x clipboard
set clipboard=unnamed           " Share x paste buffer ('*' register) for better copy & paste
set tabpagemax=15                " Set maximum number of tabs
set foldopen+=jump		 " open a fold when jumping lines via 'G' or 'g'
set scrolloff=4			 " 4 lines between cursor and edge when scrolling
set tagbsearch                  " use binary search for finding tags
set autoread             " re-read unedited files that are modified outside Vim
set undofile             " save undo history to file for persistent undo
set undodir=~/.vim/undofiles       " save undo history to to a specific directory
set showcmd              " show current command in last line
" set listchars+=tab:\|\ 
set display+=lastline    " show as much of the last line in the window as possible
set shiftround           " round shifts to multiples of shiftwidth


set statusline=%<%f%=\ [%1*%M%*%{','.&fileformat}%{&fileencoding!=''?','.&fileencoding:''}%R%Y][%6l,%4c%V]\ %3b=0x%02B\ %P
set laststatus=2                  " always show status line
set viminfo+=%			  " save buffer list after closing vim
" set tildeop

" stop reindenting when '#' is typed
set cinkeys-=0#
set indentkeys-=0#

"
set cinoptions=(0

" highlight matching angle brackets
set matchpairs+=<:>

" TODO: try this (from vim-use)
" displaying tab characters and trailing spaces
" with special characters \u2592\u2591 and \u2593
" set lcs=tab:\u2592\u2591,trail:\u2593
" set list

" Not sourced by default, provides 'Man' command
runtime ftplugin/man.vim
" Source matchit plugin
runtime macros/matchit.vim
" Source pydoc plugin
runtime ftplugin/pydoc.vim
" source my own swap_lines() function
" source ~/.vim/plugins/rever

"}}}

" {{{ Vim Addons

call vam#ActivateAddons([])

" generally useful add-ons
ActivateAddons Align%294
ActivateAddons DetectIndent
ActivateAddons FuzzyFinder
ActivateAddons increment%842
ActivateAddons The_NERD_tree
ActivateAddons session%3150
ActivateAddons YankRing
ActivateAddons Indent_Guides
ActivateAddons surround
ActivateAddons repeat
ActivateAddons searchfold
ActivateAddons NrrwRgn
ActivateAddons wildfire
ActivateAddons bufexplorer.zip

" programming related add-ons
ActivateAddons a                " alternate.vim
ActivateAddons xptemplate

" matlab related add-ons
ActivateAddons mlint%2378

" python related add-ons
ActivateAddons python%30        " vimpython
ActivateAddons python_pydoc
ActivateAddons indentpython%974 " python indentation according to PEP 8
ActivateAddons python%790       " different python syntax script
ActivateAddons vim-ipython
ActivateAddons vim-flake8

" misc add-ons
ActivateAddons The_NERD_Commenter
ActivateAddons fugitive

"}}}

" {{{ Terminal specific settings

set termencoding=utf-8

"}}}

" {{{ Misc. AutoCmds

" Open an error window if there are compiler errors (help quickfix for info).
" Implement as an autocommand group
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost make lcl | cwindow
    " autocmd BufWrite quickfix cwindow
    " TODO: Find out if lmake is useful at all
    autocmd QuickFixCmdPost lmake ccl | lwindow
    " autocmd QuickFixCmdPost * set nospell
augroup END

" autocloses hint window, does nothing if in Cmdwin
" FIXME: Well, I like the ability to jump into the pydoc window, so uncommenting
" for now. Maybe delete later, or add a toggle function?
"
" augroup completion
"   autocmd CursorMovedI * if pumvisible() == 0 && expand("%") != "[Command Line]"|pclose|endif
"   autocmd InsertLeave * if pumvisible() == 0 && expand("%") != "[Command Line]"|pclose|endif
" augroup END

" NOTE: Another possible method, but couldn't figure it out (too tired, maybe).
" augroup cmdline
"   autocmd CmdwinEnter * try|set eventignore=all|finally|set eventignore=""|endtry
" augroup END

" Transparently use gpg for encrypting files " TODO: look at me!
" au BufNewFile,BufReadPre *.gpg :set secure viminfo= noswapfile nobackup nowritebackup history=0 binary
" au BufReadPost *.gpg :%!gpg -d 2>/dev/null
" au BufWritePre *.gpg :%!gpg -e -r CB06CE30 2>/dev/null
" au BufWritePost *.gpg u

" Configure vim for ebuild writing
au BufRead,BufNewFile *.e{build,class} let is_bash=1|setfiletype sh
au BufRead,BufNewFile *.e{build,class} set ts=4 sw=4 noexpandtab

" auto-detect file-type when writing a file from a new buffer
au BufWrite * if &ft == '' | filetype detect | endif

" matlab specific stuff
let g:mlint_path_to_mlint="/usr/local/matlab/bin/glnx86/mlint"

augroup scons
    au!
    autocmd BufEnter SConstruct,SConscript set filetype=python
augroup END

augroup faust
    au! BufEnter *.fst setfiletype faust
    au! BufEnter *.dsp setfiletype faust
augroup END

" rule to source project local vimrc files
augroup vimrc_local
    au!
    autocmd BufEnter * if filereadable(expand('%:p:h') . '/.vimlocalrc') | source %:p:h/.vimlocalrc | endif
augroup END

" When switching buffers, preserve window view.
" (see http://vim.wikia.com/wiki/Avoid_scrolling_when_switch_buffers)
if v:version >= 700
    au BufLeave * let b:winview = winsaveview()
    au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

" don't write undo files for certain directories
augroup noundofiles
    au BufWritePre /tmp/* setlocal noundofile
    au BufWritePre /var/tmp/* setlocal noundofile
    au BufWritePre ~/Other/* setlocal undodir=.
augroup END

"}}}

" {{{ Misc. Keymaps

" TODO: test these and see if they help
" map ü <C-]>
" map ö [
" map ä ]
" map Ö {
" map Ä }
" map ß /

" Make a simple "search" text object.
" NOTE: repeats won't work with variable length results (e.g. regex), single
" characters, continuation at top of buffer and with selection=exclusive set and
" results being at end of line
" (see http://vim.wikia.com/wiki/Copy_or_change_search_hit)
" vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
"     \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
" omap s :normal vs<CR>

" some handy quickfix/location window keymaps
nmap <Leader>qq :cwindow<CR>
nmap <Leader>qc :cclose<CR>
nmap <Leader>pp :lwindow<CR>
nmap <Leader>pc :lclose<CR>

" search in current file for special notes
nmap <Leader>ff :lvimgrep /\CTODO\\|FIXME/j %<CR>:lopen<CR>
nmap <Leader>nn :lvimgrep /\CNOTE\\|TEST/j %<CR>:lopen<CR>

" chdir to where current file resides
nmap <silent> <Leader>cd :lcd %:p:h<CR>

" Remap omnicompletion to CTRL-Space
inoremap <C-@> <C-x><C-o>

" Easier search and replace, one each for normal and visual mode.
nnoremap <Leader>, :%s:::g<Left><Left><Left>
vnoremap <Leader>, :s:::g<Left><Left><Left>
nnoremap <Leader>. :%s:::cg<Left><Left><Left><Left>
vnoremap <Leader>. :s:::cg<Left><Left><Left><Left>

" Search for selected text, forwards or backwards.
" see http://vim.wikia.com/wiki/Search_for_visually_selected_text
vnoremap <silent> * :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy/<C-R><C-R>=substitute(
            \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy?<C-R><C-R>=substitute(
            \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>

" emulates Textmate transpose feature
vmap <Leader>sl :py transpose()<CR>

" Toggle line numbers and fold column for easy copying
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

" TODO: check if this is useful
" highlight spell corrected words
" nmap tr :exe "call matchadd('WarningMsg','\\%".line('.').'l'.expand("<cword>") . "')"<CR>
" nmap tq ma[S1z=tr| 
" NOTE: modified version, F7 removes the match
" nmap tr :if !exists("b:a") <bar> let b:a=[] <bar> endif <bar>:call add(b:a,matchadd('WarningMsg','\%'.line('.').'l'.expand("<cword>")))<CR>
" nmap tq ma[S1z=tr|
" nmap   <F7> :if exists("b:a")<bar>:for val in b:a<bar>:silent! call matchdelete(val)<bar>:endfor<bar>:let b:a=[]<bar>:endif<cr>

" moves windows to the previous or next tab
" <M-,> and <M-.> in their raw forms using Ctrl-V
nnoremap , :call MoveToPrevTab()<CR>
nnoremap . :call MoveToNextTab()<CR>

" search across multiple lines (*,#) regardless of whitespace (g*,g#)
" vnoremap <silent> * :<C-U>
" \let old_reg=getreg('"')<bar>
" \let old_regmode=getregtype('"')<cr>
" \gvy/<C-R><C-R>=substitute(
" \escape(@", '\\/.*$^~[]'), '\n', '\\n', 'g')<cr><cr>
" \:call setreg('"', old_reg, old_regmode)<cr>
" vnoremap <silent> # :<C-U>
" \let old_reg=getreg('"')<bar>
" \let old_regmode=getregtype('"')<cr>
" \gvy?<C-R><C-R>=substitute(
" \escape(@", '\\/.*$^~[]'), '\n', '\\n', 'g')<cr><cr>
" \:call setreg('"', old_reg, old_regmode)<cr>
" vnoremap <silent> g* :<C-U>
" \let old_reg=getreg('"')<bar>
" \let old_regmode=getregtype('"')<cr>
" \gvy/<C-R><C-R>=substitute(
" \escape(@", '\\/.*$^~[]'), '\_s\+', '\\_s\\+', 'g')<cr><cr>
" \:call setreg('"', old_reg, old_regmode)<cr>
" vnoremap <silent> # :<C-U>
" \let old_reg=getreg('"')<bar>
" \let old_regmode=getregtype('"')<cr>
" \gvy?<C-R><C-R>=substitute(
" \escape(@", '\\/.*$^~[]'), '\_s\+', '\\_s\\+', 'g')<cr><cr>
" \:call setreg('"', old_reg, old_regmode)<cr>

" From http://vim.wikia.com/wiki/Selecting_your_pasted_text; gp normally puts
" the cursor right after the pasted text, instead of at the end
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Fuzzy Finder mappings
nnoremap <Leader>Ff :FufFile<CR>
nnoremap <Leader>FF :FufCoverageFile<CR>
nnoremap <Leader>Fb :FufBuffer<CR>
nnoremap <Leader>Fl :FufLine<CR>

" Pyclewn Mappings
" NOTE: This is not quite the same as the default <C-b> mapping. For some reason
" it behaves differently when the compiled source file is located in a different
" location or is a symlink to the original (open) source file.
nnoremap <Leader>Db :exe ":Cbreak " . line('.')

" from vim-use, allows moving a visual selection up and down with counts;
" modified to not clash with latex-suite mappings
vnoremap <expr> <C-d> 'jo'.v:count1.'jo'
vnoremap <expr> <C-u> 'ko'.v:count1.'ko'

" select from current line to line of last yanked/edited character
nnoremap <leader>v V`]

" From http://vim.wikia.com/wiki/Search_across_multiple_lines.
" Search for the ... arguments separated with whitespace (if no '!'),
" or with non-word characters (if '!' added to command).
function! SearchMultiLine(bang, ...)
  if a:0 > 0
    let sep = (a:bang) ? '\_W\+' : '\_s\+'
    let @/ = join(a:000, sep)
  endif
endfunction
command! -bang -nargs=* -complete=tag S call SearchMultiLine(<bang>0, <f-args>)|normal! /<C-R>/<CR>

"}}}

" {{{ Misc. Commands

" convience commands for starting an internal Matlab shell
command MatlabShell ConqueTermSplit matlab -nodesktop -nosplash
command MatlabShellBelow botright split | ConqueTerm matlab -nodesktop -nosplash

" modified from Vim-ML
command SearchIgnoreLines let @/=substitute(@/, '<bslash>s', '<bslash><bslash>_s<bslash><bslash>+', 'g') | normal n
command SearchNoIgnoreLines let @/=substitute(@/, '<bslash><bslash>_s<bslash><bslash>+', '<bslash>s', 'g') | normal n

" extra PyClewn command for debugging mex files
command -nargs=1 Cmlab Crun -nosplash -nodesktop -nojvm -r \"<args>\"

"}}}

" {{{ Omnicompletion (c++)
" " If no other omnicompletion function was defined, revert to completion by
" " syntax (uses the file types syntax keywords).
" if has("autocmd") && exists("+omnifunc")
"     autocmd Filetype *
"                 \ if &omnifunc == "" |
"                 \   setlocal omnifunc=syntaxcomplete#Complete |
"                 \ endif
" endif
"}}}

" {{{ Various Plugin Settings

" for NERDcommenter
let g:NERDSpaceDelims       = 1  " Add a space to the comment delim
let g:NERDRemoveExtraSpaces = 1  " Remove the space after the comment delim
let g:NERDShutUp            = 1  " Suppress unknown filtype warnings
let g:NERDMapleader         = '\c'  " set keymap leader
inoremap <C-c> <SPACE><BS><ESC>:call NERDComment(0, "insert")<CR>

" for NERDTree
let NERDTreeHijackNetrw=1 " use NERDTree instead of Netrw with :edit

" tree style directory listing with {Te,Ve,Pe,E}xplore
let g:netrw_liststyle=3

" more python highlighting
let python_highlight_all = 1

" fixes incorrect highlighting in large files
" let python_slow_sync = 1

" showmarks highlighting
" For marks a-z
" hi ShowMarksHLl cterm=bold gui=bold ctermbg=Black guibg=Black ctermfg=Blue guifg=Blue
" For marks A-Z
" hi ShowMarksHLu cterm=bold gui=bold ctermbg=Black guibg=Black ctermfg=DarkRed guifg=DarkRed
" For all other marks
" hi ShowMarksHLo cterm=bold gui=bold ctermbg=Black guibg=Black ctermfg=DarkYellow guifg=DarkYellow
" For multiple marks on the same line.
" hi ShowMarksHLm cterm=bold gui=bold ctermbg=Black guibg=Black ctermfg=DarkGreen guifg=DarkGreen

" deactivate XPT's brace completion
let g:xptemplate_brace_complete=0

" indent guides settings
let g:indent_guides_guide_size=1
let g:indent_guides_start_level=2
let g:indent_guides_enable_on_vim_startup = 0

let g:notes_directories = ['~/Documents/Notes']
let g:notes_indexfile   = '~/Documents/Notes/index.sqlite3'
let g:notes_tagsindex   = '~/Documents/Notes/tags.txt'

" make clang_complete use libclang
let g:clang_use_library  = 1
let g:clang_library_path = '/usr/lib'

" for Mex programming
let g:clang_user_options = '-I/usr/local/matlab/extern/include'

" please don't pollute $HOME
let g:yankring_history_dir = '~/.vim'

" don't autoload sessions
let g:session_autoload = 'no'

"}}}

" {{{ LaTeX

" set quoting right for german
let g:Tex_SmartQuoteOpen="\"`"
let g:Tex_SmartQuoteClose="\"'"

set grepprg=grep\ -nH\ $*

let g:Tex_ViewRuleComplete_dvi = 'okular $*.dvi &>/dev/null &'
let g:Tex_ViewRuleComplete_ps  = 'okular $*.ps  &>/dev/null &'
" let g:Tex_ViewRuleComplete_pdf = 'okular $*.pdf &>/dev/null &'
let g:Tex_ViewRuleComplete_pdf = 'zathura $*.pdf --fork &>/dev/null &'
let g:Tex_MultipleCompileFormats = 'pdf'

let g:Tex_DefaultTargetFormat = 'pdf'

let g:tex_flavor='latex'
" let g:Tex_TaglistSupport=0
" let g:Tex_Menus=0

" This can be changed to adapt to new latex compilers
" let g:Tex_CompileRule_dvi = 'latex -interaction=nonstopmode $*'
" let g:Tex_CompileRule_ps = 'dvips -Ppdf -o $*.ps $*.dvi'
" let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'

"}}}

" {{{ Taglist

" extend taglist to support latex
" let tlist_tex_settings       = 'latex;s:sections;g:graphics;l:labels'
let tlist_make_settings      = 'make;m:makros;t:targets'

" change various settings of the taglist plugin
nnoremap <silent> <F4> :TlistToggle<CR>
nnoremap <silent> <F3> :TlistOpen<CR>
let Tlist_Auto_Highlight_Tag  = 1
let Tlist_Show_One_File       = 0
let Tlist_Process_File_Always = 1
let Tlist_Auto_Update         = 1
let Tlist_Show_Menu           = 1
let Tlist_Exit_OnlyWindow     = 1
let Tlist_Use_SingleClick     = 1

"}}}

" {{{ cscope + ctags

" set up cscope (searches cscope *and* ctags database)
if has("cscope")
    set csprg=/usr/bin/cscope
    set cscopetagorder=0
    set cscopetag
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
        " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb
    " set cscopequickfix=s,t,g,e,f,i
    set cscopequickfix=s-,c-,d-,i-,t-,e-
endif

" CScope mappings, courtesy of "Clark J. Wang" <dearvoid@gmail.com>
nnoremap <silent> csc :exe "cs find c " . expand("<cword>")<CR>
nnoremap <silent> csd :exe "cs find d " . expand("<cword>")<CR>
nnoremap          cse :cs find e<SPACE>
nnoremap          csf :cs find f<SPACE>
nnoremap <silent> csg :exe "cs find g " . expand("<cword>")<CR>
nnoremap <silent> csh :cs help<CR>
nnoremap          csi :cs find i<SPACE>
nnoremap          csk :cs kill<SPACE>
nnoremap <silent> csK :cs kill -1<CR>
nnoremap <silent> csr :cs reset<CR>
nnoremap <silent> css :exe "cs find s " . expand("<cword>")<CR>
nnoremap          cst :cs find t<SPACE>
nnoremap          cs/ :cs find<SPACE>
nnoremap <silent> cs? :cs show<CR>

" Keybinding for regenerating tag file in current directory
" TODO: must get around to sanitizing this, perhaps with a function and/or autocmd
" nmap ,t :!(cd %:p:h;ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .*)&

"}}}

" {{{ Misc. Stuff

function! IsPreviewWinOpen()
    let winnum=winnr('$')
    while winnum > 0
        if getwinvar(winnum, '&previewwindow')
            return 1
        endif
        let winnum -= 1
    endwhile
    return 0
endfunction

if exists('##InsertEnter') && exists('##InsertLeave')
    " Detect if the preview window existed before entering insert mode.
    autocmd InsertEnter * let t:preview_open=IsPreviewWinOpen()

    " Close the preview window when exiting insert mode so that the
    " completion-menu "preview" option doesn't get in the way of editing.
    " But, don't close it if it was already open before insert mode, or if on
    " the command line (pclose is not allowed on the command line)
    autocmd InsertLeave *
                \ if !t:preview_open && bufname('') !~# (v:version < 702 ? 'command-line' : '\[Command Line\]') |
                \   pclose |
                \ endif
endif

" gentoo vim plugin options
let g:bugsummary_browser="firefox '%s'"

" open output of cmd in new tab
function! TabMessage(cmd)
    redir => message
    silent execute a:cmd
    redir END
    tabnew
    silent put=message
    set nomodified
endfunction
command! -nargs=+ -complete=command TabMessage call TabMessage(<q-args>)

" move a window to the previous tab
function MoveToPrevTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
        return
    endif
    "preparing new window
    let l:tab_nr = tabpagenr('$')
    let l:cur_buf = bufnr('%')
    if tabpagenr() != 1
        close!
        if l:tab_nr == tabpagenr('$')
            tabprev
        endif
        sp
    else
        close!
        exe "0tabnew"
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
endfunc

" move a window to the next tab
function MoveToNextTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
        return
    endif
    "preparing new window
    let l:tab_nr = tabpagenr('$')
    let l:cur_buf = bufnr('%')
    if tabpagenr() < tab_nr
        close!
        if l:tab_nr == tabpagenr('$')
            tabnext
        endif
        sp
    else
        close!
        tabnew
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
endfunc

"}}}

" {{{ Colorscheme stuff
" (GVim settings are in ~/.gvimrc)

" highlight extra whitespace
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen

" prevent match from getting deleted
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red

" Show trailing whitespace:
" :match ExtraWhitespace /\s\+$/
" Show trailing whitepace and spaces before a tab:
" :match ExtraWhitespace /\s\+$\| \+\ze\t/
" Show tabs that are not at the start of a line:
" :match ExtraWhitespace /[^\t]\zs\t\+/
" Show spaces used for indenting (so you use only tabs for indenting).
" :match ExtraWhitespace /^\t*\zs \+/

" Show trailing whitepace and spaces before a tab:
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ containedin=ALL

" Color Schemes with 256 colors support:
"
"   colorscheme blacklight
"   colorscheme calmar256-dark
"   colorscheme crt
"   colorscheme desert256
"   colorscheme gardener
"   colorscheme inkpot
"   colorscheme oceanblack256
"   colorscheme tabula
"   colorscheme vibrantink
"   colorscheme vividchalk
"   colorscheme xterm16

" These work (mostly) equally well in Vim *and* Gvim!
" t_Co gets set automatically depending on the terminal used.
if &t_Co == 256
    " colorscheme inkpot
    colorscheme solarized
    " colorscheme black_angus " Pretty nice, actually, yeah I like it! Also
    " useful for light backgrounds.
    " colorscheme mustang     " nice low contrast
    " colorscheme blacklight  " easy on the eyes, but not quite perfect for console
    " colorscheme bluez
    " colorscheme calmar256-dark
    " colorscheme turbo       " Not sure, a bit bright...
    " colorscheme crt         " Not sure, either...
    " colorscheme understated " Hmmm...
    " colorscheme gardener
    " colorscheme oceanblack256
    " colorscheme vibrantink
    " colorscheme vividchalk
    " colorscheme xterm16
    " colorscheme desert256
    " colorscheme impactG   " Color scheme suitable for console Vim
    " colorscheme manxome
    " colorscheme smp
elseif &t_Co == 88
    colorscheme inkpot
elseif &t_Co == 8
    colorscheme default
    " colorscheme print_bw " useful for b/w printing
    " colorscheme simple_b
endif

" set background=dark              " Default. Some colors set bg manually...

" Set comments to (bold) italic. This of course only works if the terminal
" emulator supports it (konsole doesn't, for instance)!
if &term == "rxvt-unicode"
            \ || &term == "rxvt-unicode256"
            \ || &term == "rxvt-unicode-256color"
    " highlight Comment term=bold,italic cterm=bold,italic gui=bold,italic
    highlight Comment term=italic cterm=italic gui=italic
endif

"}}}
