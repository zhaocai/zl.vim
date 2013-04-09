" =============== ============================================================
" Name           : sys.vim
" Description    : vim library
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Thu 20 Sep 2012 04:25:15 PM EDT
" Tag            : [ vim, library ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================










" ============================================================================
" Environment:                                                            [[[1
" ============================================================================
let s:os_type   = 'undefined'
let s:is_cygwin = has('win32unix')

function! zl#sys#ostype() "                                             [[[2
    "--------- ------------------------------------------------
    " Args    :
    " Return  :
    "   - Mac, Windows, Linux, FreeBSD, SunOS, Unix,
    "   - undefined
    " Raise   :
    "
    " Example : >
    "   call zl#rc#set_default('g:os_type', zl#sys#ostype())
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
        if ( arch=="Linux" )
            let s:os_type="Linux"
        elseif ( arch=="FreeBSD" )
            let s:os_type="FreeBSD"
        elseif ( arch=="SunOS" )
            let s:os_type="SunOS"
        elseif ( arch=="Darwin" )
            let s:os_type="Mac"
        else
            let s:os_type="Unix"
        endif
    endif
    return s:os_type
endfunction

function! zl#sys#is_cygwin()"                                           [[[2
    return s:is_cygwin
endfunction

function! zl#sys#is_win() "                                             [[[2
    return s:os_type == 'Windows'
endfunction
function! zl#sys#is_mac() "                                             [[[2
    return s:os_type == 'Mac'
endfunction
function! zl#sys#is_linux() "                                           [[[2
    return s:os_type == 'Linux'
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
