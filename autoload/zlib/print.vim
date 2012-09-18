" =============== ============================================================
" Name           : print.vim
" Synopsis       : vim script library: print
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Tue 18 Sep 2012 01:38:18 PM EDT
" Tag            : [ vim, print ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================
if !zlib#rc#load_guard('zlib_'.expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif




" ============================================================================
" Echo Message:                                                           [[[1
" ============================================================================

function! zlib#print#echomsg(message, ...)
    "--------- ------------------------------------------------
    " Desc    : echomsg wrapper
    "
    " Args    :
    "  - message to print
    "  - opts : >
    "  {
    "    'msg' : 'message to print' ,
    "    'hl'  : 'MoreMsg'          ,
    "  }
    " Return  :
    " Raise   :
    "--------- ------------------------------------------------

    if empty(a:message) | return | endif
    let opts = {
        \ 'hl' : 'MoreMsg',
        \ }
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    execute 'echohl ' . opts.hl
    for m in split(a:message, "\n")
        echomsg m
    endfor
    echohl NONE
endfunction

function! zlib#print#warning(message)
    call zlib#print#echomsg(message, {'hl':'WarningMsg'})
endfunction
function! zlib#print#error(message)
    call zlib#print#echomsg(message, {'hl':'ErrorMsg'})
endfunction
function! zlib#print#moremsg(message)
    call zlib#print#echomsg(message, {'hl':'MoreMsg'})
endfunction

" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :


