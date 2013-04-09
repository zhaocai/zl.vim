" =============== ============================================================
" Name           : math.vim
" Synopsis       : vim script library: math
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Thu 20 Sep 2012 04:25:10 PM EDT
" Tag            : [ vim, math ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================


if !has('python')
    zl#print#error("some features require vim compiled with +python")
    finish
endif

" ============================================================================
" Random:                                                                 [[[1
" ============================================================================
python << __PY__
from random import random
import vim
__PY__

function! zl#math#rand()
    return pyeval('random()')
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
