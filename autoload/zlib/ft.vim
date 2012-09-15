" =============== ============================================================
" Name           : ft.vim
" Description    : vim library: filetype
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Sat 15 Sep 2012 02:08:28 AM EDT
" Tag            : [ vim, library, filetype ]
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
    if !exists('b:zlib_ftdetect_buf')
        let b:zlib_saved_lazyredraw = &lazyredraw
        set lazyredraw
        vsplit | enew
        let b:zlib_ftdetect_buf = bufnr('%')
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

function! zlib#ft#detect(filename) "                                      [[[2
    "--------- ------------------------------------------------
    " Desc    : Detect Filetype
    "
    " Args    : filename as string, list or dict
    " Return  : filetype as string, list or dict
    " Raise   : 'zlib: unsupported type'
    "
    " Example : >
    "   echo zlib#ft#detect('.ssh/config')
    "   echo zlib#ft#detect(['a.vim', '.ssh/config'])
    "   echo zlib#ft#detect({'a.vim':'', '.ssh/config':''})
    "--------- ------------------------------------------------
    try
        if type(a:filename) == type('')
            let fts = <SID>ftdetect(a:filename)
        elseif type(a:filename) == type([])
            let fts = map(a:filename, '<SID>ftdetect(v:val)')
        elseif type(a:filename) == type({})
            let fts = map(a:filename, '<SID>ftdetect(v:key)')
        else
            throw 'zlib: unsupported type ' . string(type(a:filename))
        endif
    finally
        if exists('b:zlib_ftdetect_buf')
            bwipeout!
            redraw
            let &lazyredraw = b:zlib_saved_lazyredraw
        endif

    endtry

    return fts
endfunction




" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
