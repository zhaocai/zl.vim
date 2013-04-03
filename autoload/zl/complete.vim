"=============================================================================
"     FileName: complete.vim
"       Author: Zhao Cai
"        Email: caizhaoff@gmail.com
"     HomePage:
" Date Created: Sat 24 Dec 2011 08:08:03 PM EST
"Last Modified: Thu 20 Sep 2012 04:28:29 PM EDT
"	 Copyright: (C) 2011 Zhao Cai
"=============================================================================

">=< Load Guard [[[1 =========================================================
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif

">=< Settings [[[1 ===========================================================







">=< complete words [[[1 =====================================================
function! zl#complete#get_prev_cur(cmdline) "                           [[[2
    "--------- ----------------------------------------------------
    " Desc    : previous and current word for input() completion
    "
    " Args    : cmdline
    " Return  : [prev, cur]
    " Raise   :
    "
    " Example : >
    "   fun! xxx#completion(arglead, cmdline, cursorpos)
    "       let [prev, cur] = zl#complete#get_prev_cur(a:arglead)
    "       return map(filter(xxxwordslist,
    "              \ 'cur == "" ? 1 : stridx(v:val, cur) == 0' ),
    "              \ 'prev == "" ? v:val : join([prev, v:val])')
    "   endf
    "--------- -----------------------------------------------------

    if a:cmdline =~# '\s\+$'
        return [a:cmdline, '']
    endif

    let words = split(a:cmdline)
    return [join(words[0:-2]), get(words, -1, "")]
endfunction

"
"▲ Modeline ◀ [[[1 ===========================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :
