" =============== ============================================================
" Name           : sys.vim
" Description    : vim library
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Mon 03 Sep 2012 09:41:31 AM EDT
" Tag            : [ vim, library ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================

" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================
if !zlib#rc#load_guard('zlib_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif










" ============================================================================
" Environment:                                                            [[[1
" ============================================================================
let s:os_type = 'undefined'
let s:is_cygwin = has('win32unix')

function! zlib#sys#ostype() "                                             [[[2
    "--------- ------------------------------------------------
    " Args    :
    " Return  :
    "   - Mac, Windows, Linux, FreeBSD, SunOS, Unix,
    "   - undefined
    " Raise   :
    "
    " Example : >
    "   call zlib#rc#set_default('g:os_type', zlib#sys#ostype())
    "--------- ------------------------------------------------
    if s:os_type != 'undefined'
        return s:os_type
    endif

    if (has("win32") || has("win95") || has("win64") || has("win16"))
        let s:os_type = "Windows"
    elseif has('mac')
        let s:os_type="Mac"
    elseif has('unix')
            let arch = system("uname | tr -d '\n'")
            if ( arch=="Darwin" )
                let s:os_type="Mac"
            elseif ( arch=="Linux" )
                let s:os_type="Linux"
            elseif ( arch=="FreeBSD" )
                let s:os_type="FreeBSD"
            elseif ( arch=="SunOS" )
                let s:os_type="SunOS"
            else
                let s:os_type="Unix"
            endif
        endif
    endif
    return s:os_type
endfunction

function! zlib#sys#is_cygwin()"                                           [[[2
    return s:is_cygwin
endfunction

function! zlib#sys#is_win() "                                             [[[2
    return s:os_type == 'Windows'
endfunction
function! zlib#sys#is_mac() "                                             [[[2
    return s:os_type == 'Mac'
endfunction
function! zlib#sys#is_linux() "                                           [[[2
    return s:os_type == 'Linux'
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
