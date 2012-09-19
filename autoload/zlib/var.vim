" =============== ============================================================
" Name           : var.vim
" Synopsis       : vim script library: variable
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified  : Tue 18 Sep 2012 07:33:57 PM EDT
" Tag            : [ vim, variable ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



" ============================================================================
" Set Options With Undo Command:                                          [[[1
" ============================================================================
function! zlib#var#set_undo_command(opts)

    "--------- ------------------------------------------------
    " Desc    : set options and return undo command
    "
    " Args    :
    "
    "   - opts : >
    "   {
    "      'set'           : {} ,
    "      'set_bang'      : [] ,
    "      'setlocal'      : {} ,
    "      'setlocal_bang' : [] ,
    "   }
    "
    " Return  : undo command for zlib#var#exe_undo_command
    "
    " Raise   :
    "
    " Example : >
    "   let b:undo_fold_settings = zlib#var#set_undo_command({
    "       \ 'setlocal' : {
    "       \   'foldexpr'     : '(getline(v:lnum)=~@/)?0:1' ,
    "       \   'foldmethod'   : 'expr'                      ,
    "       \   'foldlevel'    : 0                           ,
    "       \   'foldcolumn'   : 1                           ,
    "       \   'foldminlines' : 0                           ,
    "       \ },
    "       \ })
    "
    "   " do something ...
    "   call zlib#var#exe_undo_command('b:undo_fold_settings')
    "--------- ------------------------------------------------

    let undo_command = ''
    let cmds = ['set', 'setlocal']

    for c in cmds
        for _ in get(a:opts ,c.'_bang', [])
            let set_command = c . ' ' . _ . '!'
            let undo_command .= ' | ' . set_command
            exe set_command
        endfor
    endfor

    for c in cmds
        for [key, val] in items(get(a:opts,c,{}))
            let undo_command .= ' | ' . c . ' ' . key
                        \ . '=' . eval('&' . key)
            exec c . ' ' . key . '=' . val
        endfor
    endfor

    return undo_command
endfunction

function! zlib#var#exe_undo_command(var)
    try
        exec {a:var}
    catch /^Vim\%((\a\+)\)\=:E/
        throw 'zlib: undo command error! ' . v:exception
    finally
        unlet {a:var}
    endtry
endfunction


" ============================================================================
" Type:                                                                   [[[1
" ============================================================================


"--------- ------------------------------------------------
" Desc    : Wrapper functions for type()
"
" Refer   : vital.vim
"--------- ------------------------------------------------

let [
\   s:__TYPE_NUMBER,
\   s:__TYPE_STRING,
\   s:__TYPE_FUNCREF,
\   s:__TYPE_LIST,
\   s:__TYPE_DICT,
\   s:__TYPE_FLOAT
\] = [
\   type(3),
\   type(""),
\   type(function('tr')),
\   type([]),
\   type({}),
\   has('float') ? type(str2float('0')) : -1
\]
" __TYPE_FLOAT = -1 when -float
" This doesn't match to anything.

" Number or Float
function! zlib#var#is_numeric(Value)
  let _ = type(a:Value)
  return _ ==# s:__TYPE_NUMBER
  \   || _ ==# s:__TYPE_FLOAT
endfunction
" Number
function! zlib#var#is_integer(Value)
  return type(a:Value) ==# s:__TYPE_NUMBER
endfunction
function! zlib#var#is_number(Value)
  return type(a:Value) ==# s:__TYPE_NUMBER
endfunction
" Float
function! zlib#var#is_float(Value)
  return type(a:Value) ==# s:__TYPE_FLOAT
endfunction
" String
function! zlib#var#is_string(Value)
  return type(a:Value) ==# s:__TYPE_STRING
endfunction
" Funcref
function! zlib#var#is_funcref(Value)
  return type(a:Value) ==# s:__TYPE_FUNCREF
endfunction
" List
function! zlib#var#is_list(Value)
  return type(a:Value) ==# s:__TYPE_LIST
endfunction
" Dictionary
function! zlib#var#is_dict(Value)
  return type(a:Value) ==# s:__TYPE_DICT
endfunction





" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
