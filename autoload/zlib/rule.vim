" =============== ============================================================
" Name           : rule.vim
" Synopsis       : vim script library: rule
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Thu 20 Sep 2012 10:12:27 AM EDT
" Tag            : [ vim, rule ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



" ============================================================================
" Rule:                                                                   [[[1
" ============================================================================
" [TODO]( mode ) @zhaocai @start(2012-09-20 10:12)
" [TODO]( apply to hl cword ) @zhaocai @start(2012-09-20 10:12)
function! zlib#rule#norm(urule, ...)
    "--------- ------------------------------------------------
    " Desc    : normalize rules
    "
    " Rule    :
    "   - "urule" : "Unnormalized RULE", rules written by users.
    "   - "nrule" : "Nnormalized RULE", rules completed with
    "               optional items and internal items.
    "
    " Args    :
    "   - urule: un-normalized rules
    "   - opts :
    "     - eval_order : ['filetype', 'bufname', 'syntax', 'expr'],
    "     - logic      :
    "       - or     : 'v:filetype || v:bufname || v:syntax || v:expr'
    "       - and    : 'v:filetype && v:bufname && v:syntax && v:expr'
    "       - string : similar to v:val for map()
    "
    " Return  : normalized rules
    " Raise   :
    "
    " Example : >
    "
    " Refer   :
    "--------- ------------------------------------------------

    let nrule = {
              \ 'eval_order' : ['filetype', 'bufname', 'syntax', 'expr'],
              \ 'logic'      : 'or',
              \ 'rule'       : {},
              \ }
    if a:0 >= 1 && zlib#var#is_dict(a:1)
        call extend(nrule, a:1)
    endif

    for type in ['filetype', 'bufname', 'syntax']
        if has_key(a:urule, type)
            let nrule.rule[type] = '\%(' . join(a:urule[type], '\|') . '\)'
        endif
    endfor
    for type in ['expr']
        if has_key(a:urule, type)
            let nrule.rule[type] =
            \ join(
            \   map(
            \     map(
            \       a:urule[type]
            \       ,"join(v:val,' || ')"
            \     )
            \     , "'('.v:val.')'"
            \   )
            \   ,' && '
            \ )
        endif
    endfor

    call filter(nrule['eval_order'], 'has_key(nrule.rule, v:val)')

    return nrule
endfunction


function! zlib#rule#is_true(nrule, ...)
    try
        return call('zlib#rule#logic_'.a:nrule['logic'], [a:nrule] + a:000)
    catch /^Vim\%((\a\+)\)\=:E129/
        throw 'zlib: undefined logic funcref'
    endtry
endfunction


function! zlib#rule#is_false(nrule, ...)
    return !call('zlib#rule#is_true', [a:nrule] + a:000)
endfunction


function! zlib#rule#logic_or(nrule, ...)
    let opts = {}
    if a:0 >= 1 && zlib#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    for type in a:nrule['eval_order']
        if s:eval_{type}(a:nrule['rule'], opts)
            return 1
        endif
    endfor
    return 0
endfunction

function! zlib#rule#logic_and(nrule, ...)
    let opts = {}
    if a:0 >= 1 && zlib#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    for type in a:nrule['eval_order']
        if !s:eval_{type}(a:nrule['rule'], opts)
            return 0
        endif
    endfor
    return 1
endfunction

function! zlib#rule#logic_expr(nrule, ...)
    let opts = {}
    if a:0 >= 1 && zlib#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let str = a:nrule['expr']
    for type in a:nrule['eval_order']
        let str = substitute(str
                \ , 'v:'.type
                \ , string(s:eval_{type}(a:nrule['rule'], opts))
                \ , 'ge'
                \ )
    endfor
    " should contain only numbers and logic operators now
    if match(str, '\a') != -1
        throw 'zlib: invalid logic expr ' . str
    endif
    return eval(str)
endfunction



function! s:eval_filetype(rule, ...)
    return call('s:eval_match', ['filetype', &ft, a:rule] + a:000)
endfunction

function! s:eval_bufname(rule, ...)
    return call('s:eval_match', ['bufname', bufname('%'), a:rule] + a:000)
endfunction

function! s:eval_syntax(rule, ...)
    let pat = get(a:rule, 'syntax', '')

    let opts = {}
    if a:0 >= 1 && zlib#var#is_dict(a:1)
        call extend(opts, a:1)
    endif
    let syn_names = zlib#syntax#synstack_names(opts)

    return !empty(filter(syn_names, 'match(v:val, pat) != -1'))
endfunction


function! s:eval_expr(rule, ...)
    try
        return eval(get(a:rule, 'expr', 1))
    catch /^Vim\%((\a\+)\)\=:E/
        return 0
    endtry
endfunction


function! s:eval_match(type, default, rule, ...)
    let pat = get(a:rule, a:type, '')
    let exp = a:0 >= 1 && zlib#var#is_dict(a:1)
            \ ? get(a:1, a:type, a:default)
            \ : a:default
    return (match(exp, pat) != -1)
endfunction

" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
