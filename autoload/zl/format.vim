"=============================================================================
"     FileName: format.vim
"       Author: Zhao Cai
"        Email: caizhaoff@gmail.com
"     HomePage:
" Date Created: Sat 03 Sep 2011 03:54:00 PM EDT
"Last Modified: Thu 20 Sep 2012 04:28:31 PM EDT
"
"	 Copyright: (C) 2010-2011 Zhao Cai
"=============================================================================
"===  Load Guard  ===                                                     [[[1
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif
let s:save_cpo = &cpo
set cpo&vim


"===  SEARCH / REPLACE ===                                                [[[1


"---  FUNCTION  --------------------------------------------------------------
"  Function: zl#format#append_modeline                                  [[[2
" Arguments:
"    Return: modeline appended in the end of the file
"      Note: Use substitute() instead of printf() to handle '%%s' modeline in
"            LaTeX files.
"
"   Example: nnoremap <silent> <Leader>ml :call zl#format#append_modeline()<CR>

func! zl#format#append_modeline()
    let l:modeline = printf(" vim: set ft=%s ts=%d sw=%d tw=%d fdm=%s :",
                \ &filetype, &tabstop, &shiftwidth, &textwidth, &foldmethod)
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
endf

let &cpo = s:save_cpo
unlet s:save_cpo


" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=0 :
