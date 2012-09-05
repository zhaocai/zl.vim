" =============== ============================================================
" Name           : list
" Synopsis       : vim list library
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : [TODO]( HomePage )
" Version        : 0.1
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Wed 05 Sep 2012 04:59:16 PM EDT
" Tag            : [ vim, list ]
" Copyright      : (c) 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================


" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================
if !zlib#rc#load_guard('zlib_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif



" ============================================================================
" Sort:                                                                   [[[1
" ============================================================================

function! zlib#list#unique_sort(list, ...) "                              [[[2
    "--------- ------------------------------------------------
    " Args    : list, [func]
    " Return  : unique sorted list
    " Raise   :
    "
    " Refer   : http://vim.wikia.com/wiki/Unique_sorting
    "--------- ------------------------------------------------
    let list = copy(a:list)
    if ( exists( 'a:1' ) )
        call sort(list, a:1 )
    else
        call sort(list)
    endif
    if len(list) <= 1 | return list | endif
    let result = [ list[0] ]
    let last = list[0]
    let i = 1
    while i < len(list)
        if last != list[i]
            let last = list[i]
            call add(result, last)
        endif
        let i += 1
    endwhile
    return result
endfunction













" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
