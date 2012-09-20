" =============== ============================================================
" Name           : syntax.vim
" Synopsis       : vim script library: syntax
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Version        : 0.1
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Thu 20 Sep 2012 04:25:15 PM EDT
" Tag            : [ vim, syntax ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================







" ============================================================================
" Current Word Auto Highlight:                                            [[[1
" ============================================================================
"     Desc: Highlight cursor word for source browsing (mostly).
"           It is useful and not hard to implementent. But naïve approach can
"           make the highlights very annoying when the cursor is put on words
"           like "set, if, print,..." because these words are everywhere.
"
"  Feature: Ignore certain syntax group
"
"   Config: 1. g:zl_hl_cword_disable_hlgroup
"           2. g:zl_hl_cword_hlgroup
"
"  Example: >
"       let g:zl_hl_cword_hlgroup = 'SpellCap'
"       nnoremap <silent> <C-h>h :<C-u>call zl#syntax#hl_cword_toggle()<CR>
" ============================================================================

let s:zl_hl_cword_hlgroup = 'ZlCword'
call zl#rc#set_default({
            \ 'g:zl_hl_cword_disable_hlgroup'    : {
            \     'Statement'        : 1 ,
            \     'SpecialStatement' : 1 ,
            \     'Comment'          : 1 ,
            \     'Delimiter'        : 1 ,
            \     'Structure'        : 1 ,
            \     'Type'             : 1 ,
            \     'Conditional'      : 1 ,
            \     'Class'            : 1 ,
            \     'StorageClass'     : 1 ,
            \ }
            \
            \ , 'g:zl_hl_cword_hlgroup' : s:zl_hl_cword_hlgroup
        \ })

function! zl#syntax#hl_cword_toggle()
    if exists('b:zl_hl_cword_auto') && b:zl_hl_cword_auto == 1
        call <SID>zl_hl_cword_manual()
        echo 'auto highlight current word: off'
    else
        call <SID>zl_hl_cword_auto()
        echo 'auto highlight current word: on'
    endif
endfunction

function! zl#syntax#hl_cword()
    call <SID>zl_hl_cword_clear()

    if !has_key(g:zl_hl_cword_disable_hlgroup
                \ , zl#syntax#cursor_trans_hlgroup())
        let pattern = '\V\<' . zl#regex#escape(expand('<cword>'), 'V') . '\>'
        if g:zl_hl_cword_hlgroup == 'ZlCword'
            exec 'hi '
                \ . g:zl_hl_cword_hlgroup
                \ . ' GUI=reverse CTERM=reverse'
        else
            exec 'hi link '
                \ . s:zl_hl_cword_hlgroup
                \ . ' '
                \ . g:zl_hl_cword_hlgroup
        endif
        let b:zl_hl_cword_match = matchadd(g:zl_hl_cword_hlgroup, pattern)
    endif
endfunction


function! s:zl_hl_cword_clear()
    if exists('b:zl_hl_cword_match')
        silent! call matchdelete(b:zl_hl_cword_match)
        unlet b:zl_hl_cword_match
    endif
endfunction

function! s:zl_hl_cword_auto()
    call zl#syntax#hl_cword()
    augroup zlHlMatch
        autocmd! CursorMoved <buffer> call zl#syntax#hl_cword()
    augroup end
    let b:zl_hl_cword_auto = 1
endfunction

function! s:zl_hl_cword_manual()
    autocmd! zlHlMatch
    call <SID>zl_hl_cword_clear()

    let b:zl_hl_cword_auto = 0
endfunction





" ============================================================================
" ColorColumn:                                                            [[[1
" ============================================================================

function! zl#syntax#colorcolum() "                                      [[[2
    "--------- ------------------------------------------------
    " Desc    : Toggle colorcolumn on and off
    "
    " Args    :
    " Return  :
    " Raise   :
    "
    " Example : >
    "   nnoremap <Leader>cc
    "   \        :<C-u>call zl#syntax#colorcolum()<CR>
    "--------- ------------------------------------------------

    if empty(&colorcolumn)
        if empty(&textwidth)
            echo "colorcolumn=80"
            setlocal colorcolumn=80
        else
            echo "colorcolumn=+1 (" . (&textwidth + 1) . ")"
            setlocal colorcolumn=+1
        endif
    else
        echo "colorcolumn="
        setlocal colorcolumn=
    endif
endfunction





" ============================================================================
" Syntax Highlight Info:                                                  [[[1
" ============================================================================
function! zl#syntax#cursor_col(...) "                                   [[[2
    let mode = a:0 >= 1 ? a:1 : mode()
    return(mode ==# 'i' ? col('.') - 1 : col('.'))
endfunction


function! zl#syntax#synstack_names(...) "                               [[[2
    "--------- ------------------------------------------------
    " Desc    : Get actual syntax stack names of under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line number   ,
    "      'col'  : column number ,
    "   }
    " Return  : all synstack group names
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let syn_stack = synstack(opts['line'], opts['col'])
    return zl#list#uniq(
        \  map(copy(syn_stack), 'synIDattr(synIDtrans(v:val), "name")')
        \+ map(syn_stack, 'synIDattr(v:val, "name")')
        \ )
endfunction




function! zl#syntax#cursor_hlgroup(...) "                               [[[2
    "--------- ------------------------------------------------
    " Desc    : Get syntax group name of under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    "
    " Return  : Highlight group name
    " Raise   :
    "--------- ------------------------------------------------

    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif
    return synIDattr(synID(opts['line'], opts['col'], 1), "name")
endfunction

function! zl#syntax#cursor_trans_hlgroup(...) "                         [[[2
    "--------- ------------------------------------------------
    " Desc    : Get actual syntax group name of under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    " Return  : Translated highlight group name
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    return synIDattr(synIDtrans(synID(opts['line'], opts['col'], 1)), "name")
endfunction

function! zl#syntax#cursor_synid(...) "                                 [[[2
    "--------- ------------------------------------------------
    " Desc    : Get detailed syntax ID under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    " Return  : syntax ID
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let synid = ""

    let id1  = synID(opts['line'], opts['col'], 1)
    let tid1 = synIDtrans(id1)

    if synIDattr(id1, "name") != ""
        let synid = synIDattr(id1, "name")
        if (tid1 != id1)
            let synid = synid . '->' . synIDattr(tid1, "name")
        endif
        let id0 = synID(line("."), col("."), 0)
        if (synIDattr(id1, "name") != synIDattr(id0, "name"))
            let synid = synid .  " (" . synIDattr(id0, "name")
            let tid0 = synIDtrans(id0)
            if (tid0 != id0)
                let synid = synid . '->' . synIDattr(tid0, "name")
            endif
            let synid = synid . ")"
        endif
    endif

    return synid
endfunction

function! zl#syntax#cursor_gui(...) "                                   [[[2
    "--------- ------------------------------------------------
    " Desc    : Get syntax highlight style under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    " Return  : gui
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let gui   = ""

    let id1  = synID(opts['line'], opts['col'], 1)
    let tid1 = synIDtrans(id1)

    if (synIDattr(tid1, "bold"     ))
        let gui   = gui . ",bold"
    endif
    if (synIDattr(tid1, "italic"   ))
        let gui   = gui . ",italic"
    endif
    if (synIDattr(tid1, "reverse"  ))
        let gui   = gui . ",reverse"
    endif
    if (synIDattr(tid1, "inverse"  ))
        let gui   = gui . ",inverse"
    endif
    if (synIDattr(tid1, "underline"))
        let gui   = gui . ",underline"
    endif
    if (gui != ""                  )
        let gui   = substitute(gui, "^,", "gui=", "")
    endif

    return gui
endfunction

function! zl#syntax#cursor_guifg(...) "                                 [[[2
    "--------- ------------------------------------------------
    " Desc    : Get syntax highlight guifg under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    " Return  : guifg
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let guifg = ""

    let id1  = synID(opts['line'], opts['col'], 1)
    let tid1 = synIDtrans(id1)

    " Use the translated id for all the color & attribute lookups
    if (synIDattr(tid1, "fg") != "" )
        let guifg = "guifg="
                    \ . synIDattr(tid1, "fg")
                    \ . "(" . synIDattr(tid1, "fg#") . ")"
    endif
    return guifg
endfunction

function! zl#syntax#cursor_guibg(...) "                                 [[[2
    "--------- ------------------------------------------------
    " Desc    : Get syntax highlight guibg under cursor
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    "
    " Return  : guibg
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let guibg = ""

    let id1  = synID(opts['line'], opts['col'], 1)
    let tid1 = synIDtrans(id1)

    if (synIDattr(tid1, "bg") != "" )
        let guibg = "guibg="
                    \ . synIDattr(tid1, "bg")
                    \ . "(" . synIDattr(tid1, "bg#") . ")"
    endif
    return guibg
endfunction

function! zl#syntax#cursor_hl(...) "                                    [[[2
    "--------- ------------------------------------------------
    " Desc    : Combined info of above syntax#cursor_* funcs
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'line' : line('.') ,
    "      'col'  : zl#syntax#cursor_col()  ,
    "   }
    " Return  : Syntax highlight info under cursor
    " Raise   :
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let info = [ zl#syntax#cursor_synid(opts)
                \ , zl#syntax#cursor_guifg(opts)
                \ , zl#syntax#cursor_guibg(opts)
                \ , zl#syntax#cursor_gui(opts)
            \ ]

    return join(filter(info, "v:val != ''"), ' ')
endfunction

function! zl#syntax#cursor_hl_echo(...) "                               [[[2
    "--------- ------------------------------------------------
    " Desc    : Echo zl#syntax#cursor_hl()
    "
    " Example : >
    "   nnoremap <Leader>a :call zl#syntax#cursor_hl_echo()<CR>
    "--------- ------------------------------------------------
    let opts = {
                \ 'line' : line('.') ,
                \ 'col'  : zl#syntax#cursor_col()  ,
                \}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let message = zl#syntax#cursor_hl(opts)
    echohl MoreMsg
    if message == ""
        echohl WarningMsg
        let message = "<no syntax group here>"
    endif
    echo message
    echohl None
endfunction





" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :