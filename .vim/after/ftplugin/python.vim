setlocal tags+=~/.vim/tags/C.tag
setlocal tags+=~/.vim/tags/Cpp.tag
setlocal tags+=~/.vim/tags/Python.tag
setlocal nosmartindent
" setlocal smartindent
setlocal smarttab
setlocal shiftwidth=4
setlocal foldmethod=indent
setlocal expandtab " shouldn't this be on by default?
setlocal textwidth=79 " for PEP 8

" Enable switching to python class libraries via 'gf'
python << EOF
import os
import sys
import vim
for p in sys.path:
  if os.path.isdir(p):
    vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF

" python << EOF
" def SetBreakpoint():
"     import re
"     nLine = int( vim.eval( 'line(".")') )

"     strLine = vim.current.line
"     strWhite = re.search( '^(\s*)', strLine).group(1)

"     vim.current.buffer.append(
"         "%(space)spdb.set_trace() %(mark)s Breakpoint %(mark)s" %
"         {'space':strWhite, 'mark': '#' * 30}, nLine - 1)

"     for strLine in vim.current.buffer:
"         if strLine == "import pdb":
"             break
"     else:
"         vim.current.buffer.append('import pdb', 0)
"         vim.command('normal j1')

" vim.command( 'map <f7> :py SetBreakpoint()<cr>' )

" def RemoveBreakpoints():
"   import re

"   nCurrentLine =int( vim.eval( 'line(".")'))

"   nLines = []
"   nLine = 1
"   for strLine in vim.current.buffer:
"       if strLine == 'import pdb' or strLine.lstrip()[:15] == 'pdb.set_trace()':
"           nLines.append( nLine )
"       nLine += 1

"   nLines.reverse()

"   for nLine in nLines:
"       vim.command( 'normal %dG' % nLine)
"       vim.command( 'normal dd')
"       if nLine < nCurrentLine:
"           nCurrentLine -= 1

"   vim.command( 'normal %dG' % nCurrentLine)

" vim.command( 'map <s-f7> :py RemoveBreakpoints()<cr>' )
" EOF

" Author: Nick Anderson <nick at anders0n.net>
" Website: http://www.cmdln.org
" Adapted from sonteks post on Vim as Python IDE
" http://blog.sontek.net/2008/05/11/python-with-a-modular-ide-vim/

python << EOF
def SetBreakpoint():
    import re
    nLine = int( vim.eval( 'line(".")'))

    strLine = vim.current.line
    strWhite = re.search( '^(\s*)', strLine).group(1)

    vim.current.buffer.append(
       "%(space)sfrom ipdb import set_trace;set_trace() %(mark)s Breakpoint %(mark)s" %
         {'space':strWhite, 'mark': '#' * 30}, nLine - 1)

vim.command( 'map <f7> :py SetBreakpoint()<cr>')

def RemoveBreakpoints():
    import re

    nCurrentLine = int( vim.eval( 'line(".")'))

    nLines = []
    nLine = 1
    for strLine in vim.current.buffer:
        if strLine.lstrip()[:38] == 'from ipdb import set_trace;set_trace()':
            nLines.append( nLine)
            print nLine
        nLine += 1

    nLines.reverse()

    for nLine in nLines:
        vim.command( 'normal %dG' % nLine)
        vim.command( 'normal dd')
        if nLine < nCurrentLine:
            nCurrentLine -= 1

    vim.command( 'normal %dG' % nCurrentLine)

# vim.command( 'map <s-f7> :py RemoveBreakpoints()<cr>')
EOF

" Call pylint on current buffer
if exists(":Pylint") == 0
    command Pylint :call Pylint()
endif
function! Pylint()
    setlocal makeprg=(echo\ '[%]';\ pylint\ %)
    setlocal efm=%+P[%f],%t:\ %#%l:%m
    silent make
    cwindow
endfunction
