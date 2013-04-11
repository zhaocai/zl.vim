" =============== ============================================================
" Name           : opts.vim
" Description    : vim library: options
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Thu 20 Sep 2012 04:25:11 PM EDT
" Tag            : [ vim, library, options ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================





" ============================================================================
" Set Undo Vim Options:                                                   [[[1
" ============================================================================
let s:undo_options = {}

function! zl#opts#undo_options()
    return s:undo_options
endfunction

function! zl#opts#set(id, options)

    "--------- ------------------------------------------------
    " Desc    : set options and return undo command
    "
    " Args    :
    "   - id      : unique id for zl#opts#undo(id)
    "   - options : list of options to save , use '&l :'
    "               prefix for local options
    "
    " Return  :
    "
    " Example : >

    "     let options =
    "     \ { '&foldcolumn' : 4
    "     \ , '&foldlevel'  : 4
    "     \ , '&guifont'    : 'Menlo for Powerline:h13'
    "     \ }
    "     call zl#opts#set('Some Option Profile', options)
    "
    "     " do something ...
    "
    "     call zl#opts#undo('Some Option Profile')
    "--------- ------------------------------------------------

    let saved_options = {}

    for [key, val] in items(a:options)
        let saved_options[key] = eval(key)
        exec 'let ' . key . ' = val'
    endfor
    let s:undo_options[a:id] = saved_options
endfunction


function! zl#opts#undo(id)
    if !has_key(s:undo_options, a:id)
        zl#print#error('zl: undo option for key ' . a:id . ' was not set!')
        return
    endif
    let saved_options = get(s:undo_options, a:id)

    " global
    for [key, val] in items(saved_options)
        exec 'let ' . key . ' = val'
    endfor

    unlet s:undo_options[a:id]
endfunction


" ============================================================================
" Parse Options:                                                          [[[1
" ============================================================================
function! zl#opts#parse(argline, option_list) "                           [[[2
    "--------- ------------------------------------------------
    " Desc    : parse command line options
    "
    " Args    :
    "   - argline from <q-args>
    "   - option_list for known options
    " Return  : [args, options -> [ [] , {} ]
    " Raise   :
    "
    " Example : >
    "   let argline = 'Cmd abc def -a -b -c=c_value -d'
    "   let opts = ['-a', '-b', '-c=']
    "   let [args, options] = zl#util#parse_options(argline, options)
    "
    " Refer   : Unite.vim
    "--------- ------------------------------------------------
    let args = []
    let options = {}
    for arg in split(a:argline, '\%(\\\@<!\s\)\+')
        let arg = substitute(arg, '\\\( \)', '\1', 'g')

        let matched_list = filter(copy(a:option_list),
                    \  'stridx(arg, v:val) == 0')
        for option in matched_list
            let key = substitute(substitute(option, '-', '_', 'g'), '=$', '', '')
            let [underlines, key] = matchlist(key,'\v^(_{0,2})(.*)$')[1:2]

            let options[key] = (option =~ '=$') ?
                        \ arg[len(option) :] : 1
            break
        endfor

        if empty(matched_list)
            call add(args, arg)
        endif
    endfor

    return [args, options]
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
