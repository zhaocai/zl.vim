" =============== ============================================================
" Name           : window.vim
" Synopsis       : vim script library: window
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Version        : 0.1
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Tue 11 Sep 2012 04:42:57 AM EDT
" Tag            : [ vim, syntax ]
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
" Status:                                                                 [[[1
" ============================================================================
function! zlib#window#is_last_visible(...)
    "--------- ------------------------------------------------
    " Desc    : check if no visible buffer left
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'ignored_ft' : [] ,
    "   }
    "
    " Return  :
    "   - 0 : false
    "   - 1 : true
    " Raise   :
    "
    "--------- ------------------------------------------------

    let opts = {
            \ 'ignored_ft' : [
                \ 'qf'       , 'vimpager' , 'undotree' , 'tagbar' ,
                \ 'nerdtree' , 'vimshell' , 'vimfiler' , 'voom'   ,
                \ 'tabman'   , 'unite'    ,
                \ ]
            \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    for i in range(tabpagenr('$'))
        let tabnr = i + 1
        for bufnr in tabpagebuflist(tabnr)
            let ft = getbufvar(bufnr, '&ft')
            let buftype = getbufvar(bufnr, '&buftype')
            if empty(ft) && empty(buftype)
                continue
            endif
            if index(opts['ignored_ft'], ft) == -1
                return 0
            endif
        endfor
    endfor

    return 1
endfunction



" ============================================================================
" Close:                                                                  [[[1
" ============================================================================
function! s:_buf_quit_hook(cmd)
    if exists('*Voom_Exec')
        call Voom_DeleteOutline(a:cmd)
        return 1
    endif
    return 0
endfunction

function! zlib#window#buffer_quit()
    if ! s:_buf_quit_hook('q')
        execute 'quit'
    endif
endfunction

function! zlib#window#buffer_delete(cmd)
    if ! s:_buf_quit_hook(a:cmd)
        let current = bufnr('%')

        call zlib#window#alternate_buffer()

        silent! execute a:cmd . ' ' . current
    endif
endfunction


" ============================================================================
" Move:                                                                   [[[1
" ============================================================================
function! zlib#window#next_window_or_tab()
    if tabpagenr('$') == 1 && winnr('$') == 1
        call zlib#window#split_nicely()
    elseif winnr() < winnr("$")
        wincmd w
    else
        tabnext
        wincmd w
    endif
endfunction

function! zlib#window#previous_window_or_tab()
    if winnr() > 1
        wincmd W
    else
        tabprevious
        execute winnr("$") . "wincmd w"
    endif
endfunction



" ============================================================================
" Split:                                                                  [[[1
" ============================================================================

function! zlib#window#nicely_split_cmd()
    return (winwidth(0) > 2 * &winwidth
                \ ? 'vsplit' : 'split')
endfunction

function! zlib#window#split_nicely()
    exec zlib#window#nicely_split_cmd()
    wincmd p
endfunction

function! zlib#window#toggle_split()
    let prev_name = winnr()
    silent! wincmd w
    if prev_name == winnr()
        split
    else
        call zlib#window#buffer_quit()
    endif
endfunction



" ============================================================================
" Sort:                                                                   [[[1
" ============================================================================
function! zlib#window#sort_by(...)
    "--------- ------------------------------------------------
    " Desc    : sort buffer by size, height, or width
    "
    " Args    :
    "   - opts : > ↓
    "   {
    "     'by'            : 'size'|'height'|'width' ,
    "     'tabnr'         : tabpagenr()             ,
    "     'width_weight'  : 1.618                   ,
    "     'height_weight' : 1                       ,
    "   }
    "
    " Return  : sorted list of
    "   {
    "     'bufnr'  : bufnr  ,
    "     'width'  : width  ,
    "     'height' : height ,
    "     'size'   : size   ,
    "   }
    "
    " Raise   :
    "
    "--------- ------------------------------------------------

    let opts = {
                \ 'by'            : 'size' ,
                \ 'tabnr'         : tabpagenr() ,
                \ 'width_weight'  : 1.618       ,
                \ 'height_weight' : 1           ,
            \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    let list = []
    for bufnr in tabpagebuflist(opts['tabnr'])
        let winnr  = bufwinnr(bufnr)
        let width  = winwidth(winnr)
        let height = winheight(winnr)
        let size   = width * opts['width_weight']
                    \ + height * opts['height_weight']

        call add(list, {
                    \ 'bufnr'  : bufnr  ,
                    \ 'width'  : width  ,
                    \ 'height' : height ,
                    \ 'size'   : size   ,
                \ })
    endfor

    return zlib#list#sort_by(list,'v:val["'.opts['by'].'"]')
endfunction


" ============================================================================
" Switch:                                                                 [[[1
" ============================================================================

function! zlib#window#switch_with_largest(...)
    "--------- ------------------------------------------------
    " Desc    : switch buffer with the largest window
    "
    " Args    :
    "   - opts : >
    "   {
    "     'bufnr'         : bufnr('%')              ,
    "     'by'            : 'size'|'height'|'width' ,
    "     'tabnr'         : tabpagenr()             ,
    "     'width_weight'  : 1.618                   ,
    "     'height_weight' : 1                       ,
    "   }
    "
    " Return  :
    " Raise   :
    "
    " Example : >
    "   nnoremap <silent> <C-@>
    "   \ :<C-u>call zlib#window#switch_with_largest()<CR>
    "--------- ------------------------------------------------


    let opts = {
                \ 'bufnr'         : bufnr('%')  ,
                \ 'by'            : 'size'      ,
                \ 'tabnr'         : tabpagenr() ,
                \ 'width_weight'  : 1.618       ,
                \ 'height_weight' : 1           ,
            \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    let sorted = zlib#window#sort_by(filter(copy(opts),'v:key != "bufnr"'))
    let bufnr_to = sorted[-1]['bufnr']
    call zlib#window#switch_buffer(opts['bufnr'], bufnr_to)
endfunction

function! zlib#window#switch_buffer(bufnr1, bufnr2)
    "--------- ------------------------------------------------
    " Desc    : switch buffer window if both are visible
    "
    " Args    : bufnr1 <-> bufnr2
    " Return  :
    "   - 0 : fail
    "   - 1 : success
    " Raise   :
    "
    " Example : >
    "
    " Refer   :
    "--------- ------------------------------------------------
    let winnr1 = bufwinnr(a:bufnr1)
    let winnr2 = bufwinnr(a:bufnr2)
    if winnr1 != -1 && winnr2 != -1
        set lazyredraw
        silent exec winnr1 'wincmd w'
        if bufnr('%') != a:bufnr2
            silent exec 'buffer' a:bufnr2
        endif
        silent exec winnr2 'wincmd w'
        if bufnr('%') != a:bufnr1
            silent exec 'buffer' a:bufnr1
        endif
        redraw
        return 1
    else
        return 0
    endif
endfunction

function! zlib#window#alternate_buffer()
    if bufnr('%') != bufnr('#') && buflisted(bufnr('#'))
        buffer #
    else
        let cnt = 0
        let pos = 1
        let current = 0
        while pos <= bufnr('$')
            if buflisted(pos)
                if pos == bufnr('%')
                    let current = cnt
                endif

                let cnt += 1
            endif

            let pos += 1
        endwhile

        if current > cnt / 2
            bprevious
        else
            bnext
        endif
    endif
endfunction

" ============================================================================
" Scroll:                                                                 [[[1
" ============================================================================

function! zlib#window#scroll_other_window(direction)
    execute 'wincmd' (winnr('#') == 0 ? 'w' : 'p')
    execute (a:direction ? "normal! \<C-d>" : "normal! \<C-u>")
    wincmd p
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :

