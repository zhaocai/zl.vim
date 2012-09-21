" =============== ============================================================
" Name           : rule.vim
" Synopsis       : vim script library: rule
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Fri 21 Sep 2012 06:08:00 PM EDT
" Tag            : [ vim, rule ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



" ============================================================================
" Rule:                                                                   [[[1
" ============================================================================
let s:rule_types =  [
    \   'at'     , 'filetype', 'mode',
    \   'bufname', 'syntax'  , 'expr',
    \ ]
let s:nrule = {
    \ 'eval_order' : s:rule_types ,
    \ 'logic'      : 'or'         ,
    \ 'rule'       : {}           ,
    \ }

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
    "     - eval_order : order in s:rule_types,
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
    let nrule = deepcopy(s:nrule)

    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(nrule, a:1)
    endif

    let type_expr = {
                  \   'filetype' : '&ft'          ,
                  \   'bufname'  : "bufname('%')" ,
                  \ }

    let type_pat = {}
    for type in ['filetype', 'bufname', 'syntax']
        if has_key(a:urule, type)
            let type_pat[type] = '\%(' . join(a:urule[type], '\|') . '\)'
        endif
    endfor


    " normalize each type of rules
    for type in ['mode']
        if has_key(a:urule, type)
            let nrule.rule[type] = a:urule[type]
        endif
    endfor

    for type in ['filetype', 'bufname']
        if has_key(a:urule, type)
            let nrule.rule[type] =
                \ {
                \ 'eval_expr' : 1               ,
                \ 'expr'      : type_expr[type] ,
                \ 'pat'       : type_pat[type]  ,
                \ }
        endif
    endfor


    for type in ['syntax']
        if has_key(a:urule, type)
            let nrule.rule[type] = type_pat[type]
        endif
    endfor

    for type in ['mode', 'at']
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
                \       copy(a:urule[type])
                \       ,"join(v:val,' || ')"
                \     )
                \     , "'('.v:val.')'"
                \   )
                \   ,' && '
                \ )
            catch /^Vim\%((\a\+)\)\=:E714/ " E714: List required
                throw 'zl(rule): expr rule should be written as list of lists.'
            endtry
        endif
    endfor

    call filter(
    \   nrule['eval_order']
    \   , 'has_key(nrule.rule, v:val) && !empty(nrule.rule[v:val])'
    \ )

    return nrule
endfunction


function! zl#rule#is_true(nrule, ...)
    try
        return call('zl#rule#logic_'.a:nrule['logic'], [a:nrule] + a:000)
    catch /^Vim\%((\a\+)\)\=:E129/
        throw 'zl(rule): undefined logic funcref'
    endtry
endfunction


function! zl#rule#is_false(nrule, ...)
    return !call('zl#rule#is_true', [a:nrule] + a:000)
endfunction


" rule logic
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

    try
        return eval(str)
    catch /^Vim\%((\a\+)\)\=:E/
        throw printf('zl(rule): eval(%s) raises %s', str, v:exception)
    endtry
endfunction



" nrule eval
function! s:eval_filetype(nrule, ...)
    return call('s:_eval_match', ['filetype', a:nrule] + a:000)
endfunction

function! s:eval_bufname(nrule, ...)
    return call('s:_eval_match', ['bufname', a:nrule] + a:000)
endfunction


function! s:eval_at(nrule, ...)
    return search(get(a:nrule, 'at', '\%#'), 'bcnW')
endfunction


function! s:eval_mode(nrule, ...)
    let mode_pat  = get(a:nrule, 'mode', [])
    let mode_expr =
    \ a:0 >= 1 && zl#var#is_dict(a:1)
    \ ? get(a:1, 'mode', mode())
    \ : mode()

    return
    \ !empty(
    \   filter(
    \     mode_pat
    \     , 'stridx(mode_expr, v:val) == -1'
    \   )
    \ )
endfunction

function! s:eval_syntax(nrule, ...)
    let pat = get(a:nrule, 'syntax', '')

    let opts = {}
    if a:0 >= 1 && zl#var#is_dict(a:1)
        call extend(opts, a:1)
    endif
    let syn_names = zl#syntax#synstack_names(opts)

    return !empty(filter(syn_names, 'match(v:val, pat) != -1'))
endfunction

function! s:eval_expr(nrule, ...)
    try
        return eval(get(a:nrule, 'expr', 1))
    catch /^Vim\%((\a\+)\)\=:E/
        return 0
    endtry
endfunction

function! s:_eval_match(type, nrule, ...)
    "--------- ------------------------------------------------
    " Desc    : internal match evluation
    " Rule    :
    "   { 'type' :
    "     {
    "       'eval_expr' : (1|0)  ,
    "       'expr'      : {expr} ,
    "       'pat'       : {pat}  ,
    "     }
    "   }
    "
    " Args    : [{type}, {nrule}[, {opts}]]
    " Return  :
    "   - 0 : false
    "   - 1 : true
    " Raise   : zl(rule)
    "
    " Refer   : vimhelp:match()
    "--------- ------------------------------------------------

    let rule = copy(get(a:nrule, a:type, {}))
    if empty(rule)
        throw 'zl(rule): ' . v:exception
    endif

    " opt for {expr} from runtime opts
    if a:0 >= 1 && zl#var#is_dict(a:1) && has_key(a:1, a:type)
        let rt_rule = a:1[a:type]
        if zl#var#is_dict(rt_rule)
            call extend(rule, rt_rule)
        elseif zl#var#is_string(rt_rule)
            let rule['expr']      = rt_rule
            let rule['eval_expr'] = 0
        endif
    endif
    if rule['eval_expr']
        let rule['expr'] = eval(rule['expr'])
    endif
    try
        return call('match', [rule['expr'], rule['pat']]) != -1
    catch /^Vim\%((\a\+)\)\=:E/
        throw 'zl(rule): ' . v:exception
    endtry
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
