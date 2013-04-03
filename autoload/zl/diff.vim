"=============================================================================
"     FileName: diff.vim
"       Author: Zhao Cai
"        Email: caizhaoff@gmail.com
"     HomePage:
" Date Created: Sun 11 Sep 2011 05:18:00 PM EDT
"Last Modified: Mon 25 Mar 2013 08:02:38 PM EDT
"
"	 Copyright: (C) 2010-2011 Zhao Cai
"=============================================================================

"===  Load Guard  ===                                                     [[[1
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif
let s:save_cpo = &cpo
set cpo&vim

call zl#rc#set_default({
        \ 'g:zl_diff_ignore_ft_pattern'   :   '\%(^$\|'
            \.'man\|voomtree\|voomlog\|help\|qf\|'
            \.'qfreplace\|Decho\|ref\|simpletap-summary\|'
            \.'vimcalc\|unite\|vimfiler\|vimshell\|'
            \.'git-status\|git-log\|gitcommit\|vcs-commit\|vcs-status'
            \.'\)'
        \ ,
        \ 'g:zl_diff_ignore_fname_pattern' :   '\.\%(o\|exe\|dll\|sw[po]\)$'
        \ ,
    \})

fun! zl#diff#toggle(...)
    let opts = {
                \ 'buf'    : bufnr('%'),
                \ 'toggle' : 'toggle'
            \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    let old_buffer = bufnr('%')

    if opts['buf'] != old_buffer | execute bufwinnr(opts['buf']) 'wincmd w' | endif
    " --------%>--------
    if opts['toggle'] == 'toggle'

        if &ft =~# g:zl_diff_ignore_ft_pattern
                 \ || fnamemodify(expand('%'), ':p') =~ g:zl_diff_ignore_fname_pattern

            return 0
        endif
        if &diff == 1
            diffoff
        else
            diffthis
        endif
    elseif opts['toggle'] == 'off'
        if &diff == 1
            diffoff
        endif
    elseif opts['toggle'] == 'on'
        if &ft =~# g:zl_diff_ignore_ft_pattern
                 \ || fnamemodify(expand('%'), ':p') =~ g:zl_diff_ignore_fname_pattern

            return 0
        endif

        if &diff != 1
            diffthis
        endif
    endif
    " --------%<--------
    if opts['buf'] != old_buffer | execute bufwinnr(old_buffer) 'wincmd w' | endif

    return 1
endf


fun! zl#diff#tab(...)
    let opts = {
                \ 'toggle' : 'toggle'
            \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    " --------%>--------
    if opts['toggle'] == 'toggle'
        for nr in tabpagebuflist()
            if getbufvar(nr, '&diff') == 1
                let opts['toggle'] = 'off'
                break
            endif
        endfor
    endif

    for nr in tabpagebuflist()
        let opts['buf'] = nr
        call zl#diff#toggle(opts)
    endfor
    " --------%<--------
endf










let &cpo = s:save_cpo
unlet s:save_cpo



" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :
