" =============== ============================================================
" Name           : dict.vim
" Description    : vim library: Dictionary
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 19 Sep 2012 06:48:28 PM EDT
" Tag            : [ vim, library, Dictionary ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================








" ============================================================================
" True Or False:                                                          [[[1
" ============================================================================
fun! zlib#dict#has_key_value(dict, key, val) "                            [[[2
    if !has_key(a:dict,a:key)
        return 0
    endif
    if get(a:dict,a:key) != a:val
        return 0
    endif
    return 1
endf


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
