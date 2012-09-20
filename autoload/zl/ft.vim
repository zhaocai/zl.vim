" =============== ============================================================
" Name           : ft.vim
" Description    : vim library: filetype
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Thu 20 Sep 2012 04:25:09 PM EDT
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
" Filetype Detect:                                                        [[[1
" ============================================================================
let s:ft_map = {
            \ '\.\%(vim\|vba\)$'                           : 'vim'      ,
            \ '\.\%(snip\|snippet\)$'                      : 'snippet'  ,
            \ '\.\%(sh\|bash\)$'                           : 'sh'       ,
            \ '\.\%(zsh\)$'                                : 'zsh'      ,
            \ '\.\%(rb\|gemspec\)$'                        : 'rb'       ,
            \ '\.\%(markdown\|md\)$'                       : 'markdown' ,
            \ '\.\%(csv\)$'                                : 'csv'      ,
            \ '\.\%(pandoc\)$'                             : 'pandoc'   ,
            \ '\.\%(pl\|pm\)$'                             : 'perl'     ,
            \ '\.\%(py\)$'                                 : 'python'   ,
            \ '\.\%(cpp\|cc\|cxx\|m\|hpp\|hh\|h\|hxx\)$'   : 'cpp'      ,
        \ }
function! s:ftdetect(filename)
    " quick match based on filename extension
    for [key, value] in items(s:ft_map)
        if a:filename =~ key
            return value
        endif
    endfor

    " vim filetype detect
    if !exists('b:zl_ftdetect_buf')
        let b:zl_saved_lazyredraw = &lazyredraw
        set lazyredraw
        vsplit | enew
        let b:zl_ftdetect_buf = bufnr('%')
    endif
    try
        silent exec 'noautocmd file ' . escape(a:filename, ' ')
        silent filetype detect

        return &ft
    catch /^Vim\%((\a\+)\)\=:E95/
        " existing buffer
        return getbufvar(a:filename, '&ft')
    catch /^Vim\%((\a\+)\)\=:E749/
        " empty buffer
        return &ft
    endtry
endfunction

function! zl#ft#detect(filename) "                                      [[[2
    "--------- ------------------------------------------------
    " Desc    : Detect Filetype
    "
    " Args    : filename as string, list or dict
    " Return  : filetype as string, list or dict
    " Raise   : 'zl: unsupported type'
    "
    " Example : >
    "   echo zl#ft#detect('.ssh/config')
    "   echo zl#ft#detect(['a.vim', '.ssh/config'])
    "   echo zl#ft#detect({'a.vim':'', '.ssh/config':''})
    "--------- ------------------------------------------------
    try
        if type(a:filename) == type('')
            let fts = <SID>ftdetect(a:filename)
        elseif type(a:filename) == type([])
            let fts = map(a:filename, '<SID>ftdetect(v:val)')
        elseif type(a:filename) == type({})
            let fts = map(a:filename, '<SID>ftdetect(v:key)')
        else
            throw 'zl: unsupported type ' . string(type(a:filename))
        endif
    finally
        if exists('b:zl_ftdetect_buf')
            bwipeout!
            redraw
            let &lazyredraw = b:zl_saved_lazyredraw
        endif

    endtry

    return fts
endfunction




" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
