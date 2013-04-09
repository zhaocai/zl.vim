" =============== ============================================================
" Name           : string
" Synopsis       : vim string library
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 03 Apr 2013 12:46:57 AM EDT
" Tag            : [ vim, library, filetype ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================


" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif

" ============================================================================
" Utility:                                                                   [[[1
" ============================================================================

function! zl#string#count(haystack, needle)
    let counter = 0
    let index = stridx(a:haystack, a:needle)
    while index != -1
        let index = stridx(a:haystack, a:needle, index+1)
        let counter += 1
    endw
    return counter
endfunction

function! zl#string#chop(str)
    return substitute(a:str, '.$', '', '')
endfunction

function! zl#string#is_mbyte(str)
    return ( strdisplaywidth(a:str) != strlen(a:str) )
endfunction


function! zl#string#check_back_space()
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction



function! zl#string#count_first_nonwhite(text)
    let first_sym = matchstr(a:text, '\S')
    return len(matchstr(a:text, first_sym.'\+'))
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :

