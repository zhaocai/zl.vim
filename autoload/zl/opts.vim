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
" Parse Options:                                                          [[[1
" ============================================================================
function! zl#opts#parse(argline, option_list) "                              [[[2
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
    "   let [args, options] = zl#util#parse_options(argline, opts)
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
