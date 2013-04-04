" =============== ============================================================
" Name           : find.vim
" Synopsis       : vim script library: find
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Wed 03 Apr 2013 12:44:35 AM EDT
" Tag            : [ vim, find ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================





" ============================================================================
" Grep:                                                                   [[[1
" ============================================================================

function! zl#find#vimgrep(query,where)
    " -------- - -----------------------------------------------
    "  Desc    : vimgrep the word pointed by the cursor
    "
    "  Args    : Arguments
    "  Return  : quickfix window with the search results
    "  Raise   :
    "
    "  Example : nnoremap vf :<C-U>
    "					\call zl#find#vimgrep(expand("<cword>"),"%")<CR>
    "		     vnoremap <silent> vf :<C-U><CR>
    "					\gvy:
    "                   \call zl#find#vimgrep(tlib#rx#Escape(@@),"%")<CR>
    "  Refer   :
    "  Note    : escape specail characters like #,% in the query argument
    " -------- - -----------------------------------------------

    "	call Dfunc('zl#find#vimgrep('.a:query.' '.a:where.')')
    let l:cmd = 'silent! vimgrep /'. a:query .'/ '.a:where
    exe l:cmd
    call zl#quickfix#open(0,1,1,64,l:cmd)
    "	call Dret('zl#find#vimgrep')
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :


