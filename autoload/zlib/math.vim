" =============== ============================================================
" Name           : math.vim
" Synopsis       : vim script library: math
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Wed 19 Sep 2012 05:18:42 PM EDT
" Tag            : [ vim, math ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================


if !has('python')
    finish
endif

" ============================================================================
" Random:                                                                 [[[1
" ============================================================================
python << __PY__
from random import random
import vim
__PY__

function! zlib#math#rand()
    return pyeval('random()')
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
