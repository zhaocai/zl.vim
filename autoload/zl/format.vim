" =============== ============================================================
" Synopsis       : vim script library: format
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Version        : 0.1
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Fri 28 Sep 2012 03:53:31 PM EDT
" Tag            : [ vim, buffer ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



function! zl#format#append_modeline()
    " -------- - -----------------------------------------------
    "  Desc    : append modeline in the end of the file
    "
    "  Args    : Arguments
    "  Return  : Returns
    "  Raise   :
    "
    "  Example : > nnoremap <Leader>ml :call zl#format#append_modeline()<CR>
    "
    "  Refer   : Use substitute() instead of printf() to handle
    "            '%%s' modeline in LaTeX files.
    " -------- - -----------------------------------------------

    let l:modeline = printf(" vim: set ft=%s ts=%d sw=%d tw=%d fmr=%s fdm=%s :",
                \ &filetype, &tabstop, &shiftwidth, &textwidth, &foldmarker, &foldmethod)
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
