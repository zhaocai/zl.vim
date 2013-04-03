" =============== ============================================================
" Name           : web
" Synopsis       : vim web library
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 03 Apr 2013 12:51:15 AM EDT
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
" Google:                                                                 [[[1
" ============================================================================
function! zl#web#google_suggest(query, language)
    " -------- - -----------------------------------------------
    "  Desc    : google suggest
    "
    "  Args    : query and language
    "  Return  : google suggested queries
    "  Raise   :
    "
    "  Example : >
    "
    "  Refer   :
    " -------- - -----------------------------------------------

    let keyword_list = []
    let res = webapi#http#get(
                \ 'http://suggestqueries.google.com/complete/search',
                \ {
                    \ "client" : "youtube",
                    \ "q"      : a:query,
                    \ "hjson"  : "t",
                    \ "hl"     : a:language,
                    \ "ie"     : "UTF8",
                    \ "oe"     : "UTF8"
                \ }
            \ )
    let arr = webapi#json#decode(res.content)
    for m in arr[1]
        call add(keyword_list, m[0])
    endfor
    return keyword_list
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :
