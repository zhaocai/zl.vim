" =============== ============================================================
" Name           : rc.vim
" Description    : vim library rc
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Mon 03 Sep 2012 09:45:33 AM EDT
" Tag            : [ vim, library ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================

let s:save_cpo = &cpo
set cpo&vim

" ============================================================================
" Initialization:                                                         [[[1
" ============================================================================

let s:ZLIB_VERSION_CURRENT = 100

let s:VERSION_FACTOR = str2float('0.01')


function! zlib#rc#init() abort "                                          [[[2

    if v:version < 700
        echoerr "zlib requires Vim >= 7"
        return
    endif

    if !exists("g:zlib_force_reload")
        let g:zlib_force_reload = 0
    endif

    if !exists("g:zlib_debug_mode")
        let g:zlib_debug_mode = 0
    endif


    let g:loaded_zlib = s:ZLIB_VERSION_CURRENT * s:VERSION_FACTOR


    " Public Interface
    " ----------------
    command! -nargs=0 ZReloadScript call zlib#rc#script_force_reload()

endfunction



function! zlib#rc#load_guard(prefix, vim_version, zlib_version,exprs,...)"[[[2
    "--------- ------------------------------------------------
    " Desc    : gereric script load guard function
    "
    " Args    :
    "   - prefix       : to generate loaded_var_name
    "   - vim_version  : minmium vim version requirement
    "   - zlib_version : minmium zlib version requirement.
    "                    set 0 to ignore.
    "   - exprs        : assert list of expresses to be true
    "   - ... scope    : 'g' , 'b', ...
    "
    " Return  :
    "   - 1 : unloaded
    "   - 0 : already loaded
    "
    " Raise   :
    "
    " Example : >
    "   if !zlib#rc#load_guard('x_' . expand('<sfile>:t:r'), 702, 100, ['!&cp'])
    "       finish
    "   endif
    "
    " Details :
    "   1. g:loaded_xlib_{script name} is loaded if pass:
    "   2. vim version > 702
    "   3. zlib version > 100
    "   4. test !&cp is true
    "
    " Refer   :
    "--------- ------------------------------------------------

"   call Dfunc('zlib#rc#load_guard(' . a:prefix .' '. a:vim_version .' '. a:zlib_version .' '. join(a:exprs))

    let l:scope =  a:0 >= 1  ?  a:1  :  'g'

    let l:loaded_var_name = l:scope . ':loaded_'
                \ . substitute(a:prefix, '[^0-9a-zA-Z_]', '_', 'g')
"    call Decho("loaded_var_name: " . l:loaded_var_name)

    if exists(l:loaded_var_name) && g:zlib_force_reload == 0
"       call Decho(l:loaded_var_name . ' loaded: return 0')
"       call Dret('zlib#rc#load_guard')
        return 0
    endif

    if a:vim_version > 0 && a:vim_version > v:version
        echoerr l:loaded_var_name . ' requires Vim version '
                    \ . string(a:vim_version * s:VERSION_FACTOR)
        return 0
    elseif a:zlib_version > 0
        if !exists("g:loaded_zlib")
            echoerr 'zlib is required but not loaded'
            return 0
        endif

        if (a:zlib_version > s:ZLIB_VERSION_CURRENT)
            echoerr l:loaded_var_name . ' requires zlib library version '
                        \ . string(a:zlib_version * s:VERSION_FACTOR)
            return 0
        endif
    endif
    for expr in a:exprs
        if !eval(expr)
            echoerr l:loaded_var_name . ' requires: ' . expr
"           call Dret('zlib#rc#load_guard')
            return 0
        endif
    endfor
    let {l:loaded_var_name} = 1
"   call Dret('zlib#rc#load_guard')
    return 1
endfunction

function! zlib#rc#script_force_reload(...) " (script)                     [[[2
    "--------- ------------------------------------------------
    " Desc    : Call to ignore zlib#rc#load_guard() and source.
    "
    " Args    : script path or current script by default
    " Return  :
    " Raise   :
    "
    "--------- ------------------------------------------------
    let script = a:0 >= 1 ? a:1 : '%'

    let l:saved = g:zlib_force_reload
    let g:zlib_force_reload = 1

    exec "so " . script

    let g:zlib_force_reload = l:saved
endfunction





" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================

if !zlib#rc#load_guard('zlib_' . expand('<sfile>:t:r'), 700, 0, ['!&cp'])
    finish
endif








" ============================================================================
" Set Initialization Default Variables:                                   [[[1
" ============================================================================
function! zlib#rc#set_default(var, ...) "  ('var', val) || ( {dict} )     [[[2
    "--------- ------------------------------------------------
    " Desc    : Set Initialization Default Variables
    "
    " Args    : ('var', val) || ( {dict} )
    " Return  :
    " Raise   : 'zlib: ***'
    "
    " Example : >
    "   call zlib#rc#set_default({
    "             \ 'g:xxx_yyy'    : {
    "             \     'abc'        : 1,
    "             \ }
    "             \
    "             \ , 'g:yyy_zzz' : 'bcd'
    "         \ })
    "--------- ------------------------------------------------

    if type(a:var) == type({})
        for key in keys(a:var)
            call <SID>set_default(key, a:var[key])
        endfor
    elseif type(a:var) == type("")
        if a:0 >= 1
            call <SID>set_default(a:var, a:1)
        else
            throw "zlib: should call with default value for " . a:var
        endif
    else
        throw "zlib: unsupported type for a:var"
    endif
endfunction

function! s:set_default(var,val)
    if !exists(a:var) || type({a:var}) != type(a:val)
        let {a:var} = a:val
    endif
endfunction










" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
