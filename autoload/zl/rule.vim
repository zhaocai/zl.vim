" =============== ============================================================
" Name           : rule.vim
" Synopsis       : vim script library: rule
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Thu 20 Sep 2012 07:24:11 PM EDT
" Tag            : [ vim, rule ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



" ============================================================================
" Rule:                                                                   [[[1
" ============================================================================
function! zl#rule#norm(urule, ...)
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
    "     - eval_order : ['filetype', 'mode', 'bufname', 'syntax', 'expr'],
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
              \ 'eval_order' : [
              \   'filetype' , 'mode' , 'bufname' ,
              \   'syntax'   , 'expr' ,
              \ ],
              \ 'logic'      : 'or',
              \ 'rule'       : {}  ,
              \ }
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(nrule, a:1)
    endif

    for type in ['filetype', 'bufname', 'syntax']
        if has_key(a:urule, type)
            let nrule.rule[type] = '\%(' . join(a:urule[type], '\|') . '\)'
        endif
    endfor

    for type in ['mode']
        if has_key(a:urule, type)
            let nrule.rule[type] = a:urule[type]
        endif
    endfor

    for type in ['expr']
        if has_key(a:urule, type)
            try | let nrule.rule[type] =
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
            catch /^Vim\%((\a\+)\)\=:E714/ " E714: List required
                throw 'GoldenView: expr rule should be written as list of lists.'
            endtry
        endif
    endfor

    call filter(nrule['eval_order'], 'has_key(nrule.rule, v:val)')

    return nrule
endfunction


function! zl#rule#is_true(nrule, ...)
    try
        return call('zl#rule#logic_'.a:nrule['logic'], [a:nrule] + a:000)
    catch /^Vim\%((\a\+)\)\=:E129/
        throw 'zl: undefined logic funcref'
    endtry
endfunction


function! zl#rule#is_false(nrule, ...)
    return !call('zl#rule#is_true', [a:nrule] + a:000)
endfunction


function! zl#rule#logic_or(nrule, ...)
    let opts = {}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    for type in a:nrule['eval_order']
        if s:eval_{type}(a:nrule['rule'], opts)
            return 1
        endif
    endfor
    return 0
endfunction

function! zl#rule#logic_and(nrule, ...)
    let opts = {}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    for type in a:nrule['eval_order']
        if !s:eval_{type}(a:nrule['rule'], opts)
            return 0
        endif
    endfor
    return 1
endfunction

function! zl#rule#logic_expr(nrule, ...)
    let opts = {}
    if a:0 >= 1 && zl#var#is_dict(a:1)
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
        throw 'zl: invalid logic expr ' . str
    endif
    return eval(str)
endfunction



function! s:eval_filetype(rule, ...)
    return call('s:eval_match', ['filetype', &ft, a:rule] + a:000)
endfunction

function! s:eval_bufname(rule, ...)
    return call('s:eval_match', ['bufname', bufname('%'), a:rule] + a:000)
endfunction

function! s:eval_mode(rule, ...)
    let rule_mode    = get(a:rule, 'mode', [])
    let current_mode =
    \ a:0 >= 1 && zl#var#is_dict(a:1)
    \ ? get(a:1, 'mode', mode())
    \ : mode()

    return
    \ !empty(
    \   filter(
    \     rule_mode
    \     , 'stridx(current_mode, v:val) == -1'
    \   )
    \ )
endfunction

function! s:eval_syntax(rule, ...)
    let pat = get(a:rule, 'syntax', '')

    let opts = {}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif
    let syn_names = zl#syntax#synstack_names(opts)

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
    let exp = a:0 >= 1 && zl#var#is_dict(a:1)
            \ ? get(a:1, a:type, a:default)
            \ : a:default
    return (match(exp, pat) != -1)
endfunction

" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
