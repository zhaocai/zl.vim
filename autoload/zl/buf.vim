" =============== ============================================================
" Name           : buf.vim
" Synopsis       : vim script library: buffer
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Version        : 0.1
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Thu 20 Sep 2012 04:25:07 PM EDT
" Tag            : [ vim, buffer ]
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
" Completion:                                                             [[[1
" ============================================================================
function! zl#buf#complete_name(arglead, cmdline, cursorpos) "           [[[2
    let buffer_names = []

    for i in range( tabpagenr('$') )
        let tabnr = i + 1
        let buffer_names += map(tabpagebuflist(tabnr),
                    \ 'fnamemodify(bufname(v:val),":t") . ":" . v:val' )
    endfor

    return filter( zl#list#unique_sort(buffer_names),
                \ 'stridx(v:val, a:arglead) == 0' )
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

function! zl#buf#quit()
    if ! s:_buf_quit_hook('q')
        execute 'quit'
    endif
endfunction

function! zl#buf#del(cmd)
    if ! s:_buf_quit_hook(a:cmd)
        let current = bufnr('%')

        call zl#window#alternate_buffer()

        silent! execute a:cmd . ' ' . current
    endif
endfunction




" ============================================================================
" Goto:                                                                   [[[1
" ============================================================================
function! zl#buf#goto(id)  " (buf_nr or partial_filename)               [[[2
    "--------- ------------------------------------------------
    " Desc    : goto buffer if visible, otherwise open
    "
    " Args    : bufnr id (bufnr or partial_filename)
    " Return  :
    " Raise   :
    "
    " Example : >
    "   command! -nargs=1 -complete=customlist,zl#buf#complete_name J
    "           \ call zl#buf#goto(<q-args>)
    "--------- ------------------------------------------------

    if a:id =~# '\v(.*):(\d+)$'
        let [buf_name, buf_id ] = matchlist(a:id,'\v(.*):(\d+)$')[1:2]
        let buf_id = str2nr(buf_id)
    elseif a:id =~# '\d\+'
        let buf_id = str2nr(a:id)
    else
        let buf_id = a:id
    endif

    let buf_nr = bufnr(buf_id)
    if buf_nr == -1
        echoerr 'Buffer "'.buf_id.'" not found'
    endif

    for i in range(tabpagenr('$'))
        let tabnr = i + 1
        for nr in tabpagebuflist(tabnr)
            if nr == buf_nr
                execute 'tabnext' tabnr
                execute bufwinnr(nr) 'wincmd w'
                " Jump to the first.
                return
            endif
        endfor
    endfor
    try
        execute 'buffer' buf_nr
    catch /^Vim.*/
        echoerr 'Buffer "'.buf_id.'" not found'
    endtry
endfunction





" ============================================================================
" Infomation:                                                             [[[1
" ============================================================================
function! zl#buf#name_list() "                                          [[[2
    return map(filter(
                \ range(1, bufnr('$')),
                \ 'buflisted(v:val) && filereadable( bufname(v:val) )'
                \),
                \ 'zl#path#smart_quote( bufname(v:val) )'
                \)
endfunction




" ============================================================================
" Output:                                                                 [[[1
" ============================================================================
function! zl#buf#redir(...) "                                           [[[2
    "--------- ------------------------------------------------
    " Desc    : Redirect command output to buffer
    "
    " Args    :
    "    opts = {
    "             \ 'cmd'         : ''      ,
    "             \ 'split'       : 'split' ,
    "             \ 'alway_split' : 1 ,
    "         \}
    " Return  :
    " Raise   :
    "
    " Example : >
    "   command! -nargs=* -complete=command Redir
    "       \ call zl#buf#redir(<q-args>)
    "
    " Refer   :
    "   - genutils#GetVimCmdOutput
    "   - QuickRun
    "
    " Issue   : does not handle nested run
    "--------- ------------------------------------------------

    let opts = {'cmd'         : ''
            \ , 'split'       : zl#window#nicely_split_cmd()
            \ , 'alway_split' : 1
        \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    let l:output = ''
    if opts['cmd'] != ''
        let v:errmsg = ''
        let _shortmess = &shortmess
        set shortmess=
        try
            redir => l:output
            silent exec opts['cmd']
        catch /.*/
            let v:errmsg = substitute(v:exception, '^[^:]\+:', '', '')
        finally
            redir END
            let &shortmess = _shortmess
        endtry
    endif

    if l:output == '' && !opts['alway_split']
		echohl MoreMsg
		echom "[ Empty Output ]"
		echohl NONE
        return
    endif
    execute opts['split']
    enew
    setl buftype=nofile
    setl filetype=scratch

    silent 0put! = l:output
    if v:errmsg != '' && &verbose > 0
        call append(line('$'),"---ERROR MSSSAGE---")
        call append(line('$'),v:errmsg)
    endif

    " Fix Ctrl-M
    %s///ge

    1 delete _
    setl nomodified
    setl bufhidden=wipe


    silent! RainbowParenthesesToggleAll
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :

