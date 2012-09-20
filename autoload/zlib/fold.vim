" =============== ============================================================
" Name           : fold
" Description    : vim script library: fold
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zlib.vim
" Date Created   : Thu 30 Aug 2012 10:56:47 PM EDT
" Last Modified  : Wed 19 Sep 2012 07:06:20 PM EDT
" Tag            : [ vim, fold ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================




" ============================================================================
" Check Status:                                                           [[[1
" ============================================================================

function! zlib#fold#has_fold() "                                          [[[2
    "--------- ------------------------------------------------
    " Desc    : check if current file has fold!
    "
    " Args    : > opts
    "
    " Return  :
    "   - 1 : true
    "   - 0 : false
    "
    " Raise   :
    "
    "
    " Detail  : use random_check mode for large file which has
    "           no foldings.
    "
    " Example : > autocmd to set foldcolumn to 0 if !has_fold()
    "--------- ------------------------------------------------

    let last_line = line('$')
    let opts = {
             \ 'start_line' : 1              ,
             \ 'end_line'   : last_line      ,
             \ 'mode'       : 'random_check' ,
             \ }
    if a:0 >= 1 && zlib#var#is_dict(a:1)
        call extend(opts, a:1)
    endif

    let check_lines = []
    if opts['mode'] == 'random_check'
        let times = last_line > 9 ? 9 : last_line
        while times > 0
            call add(check_lines, float2nr(zlib#math#rand()*last_line))
            let times -= 1
        endwhile
    else
        let check_lines = range(opts['start_line'], opts['end_line'])
    endif

    for lnum in check_lines
        if (foldlevel(lnum) > 0)
            return 1
        endif
        let lnum += 1
    endfor
    return 0
endfunction


" ============================================================================
" Foldtext:                                                               [[[1
" ============================================================================

function! zlib#fold#foldtext(...) "                                       [[[2
    "--------- ------------------------------------------------
    " Desc    : foldtext func
    "
    " Args    :
    "   - opts : {
    "     line                : first non blank line
    "     fold_bullet         : ''
    "     fold_level          : v:foldlevel
    "     fold_indent         : 2
    "     hide_foldmarker     : 1
    "     hide_commentmarker  : 1
    "     extra_textwidth     : 25
    "   }
    " Return  : Aligned foldtext
    " Raise   :
    "
    "--------- ------------------------------------------------

    let opts = a:0 >= 1 && zlib#var#is_dict(a:1) ?  a:1  :  {}

    " process options
    " ---------------
    if !has_key(opts,'line')
         "get first non-blank line
        let fold_start = v:foldstart
        while getline(fold_start) =~ '^\s*$' && fold_start != 0
            let fold_start = nextnonblank(fold_start + 1)
        endwhile
        let line = getline(v:foldstart)
    else
        let line = opts.line
    endif


    let fold_bullet = has_key(opts,'bullet') ? opts.bullet . ' ' : ''


    let fold_level = has_key(opts,'level') ? opts.level : v:foldlevel
    let fold_level_str = repeat("+--", fold_level)


    let fold_indent = has_key(opts,'fold_indent') ? opts['fold_indent'] : 2
    if fold_indent > 0
        " remove leading whitespace
        let line           = substitute(line, '^\s*', '', '')
        let fold_indent_str = repeat(repeat(" ", fold_indent), (fold_level - 1))
    else
        let fold_indent_str = ''
    endif


    let extra_textwidth = has_key(opts,'extra_textwidth')
                \ ? opts.extra_textwidth : 25


    let is_hide_commentmarker = has_key(opts,'hide_commentmarker')
                \ ? opts.hide_commentmarker : 1
    if is_hide_commentmarker
        let [cm_l, cm_r] = split(substitute(
                    \ substitute(&commentstring,'\S\zs%s','%s','')
                    \ , '%s\ze\S','%s ','')
                    \ , '%s',1)

        let line = substitute(line, '^\s*' . cm_l, '', '')
        let line = substitute(line, cm_r . '\s*$', '', '')
    endif

    let is_hide_foldmarker = has_key(opts,'hide_foldmarker')
                \ ? opts.hide_foldmarker : 1
    if is_hide_foldmarker
        let [fmr_l, fmr_r] = split(&foldmarker, ',')

        let line = substitute(line, '\s*' . fmr_l . '\d\=' . '.*$', '', 'g')
        let line = substitute(line, '\s*' . '\d\=' . fmr_r . '.*$', '', 'g')
    endif




    " calculate align width, fold percentage, ...
    " -------------------------------------------
    let align_width = &textwidth == 0 ? 78 : &textwidth
    let align_width += extra_textwidth
                \ + &foldcolumn
                \ + (&number ? strdisplaywidth(&number) : 0)

    let line_count = line("$")

    let fold_size = 1 + v:foldend - v:foldstart
    let fold_size_str = " " . fold_size . " "
    let fold_size_str =
                \ printf(" %" . strdisplaywidth(line_count) . 'd ', fold_size)

    let fold_percentage =
                \ printf("[%4.1f", (fold_size*1.0)/line_count*100) . "%] "

    let align_space = repeat(" ",
                \ align_width
                \- strdisplaywidth(fold_size_str
                    \.fold_indent_str
                    \.line
                    \.fold_level_str
                    \.fold_percentage)
            \)


    " concatenate foldtext
    " --------------------
    let line = fold_bullet
            \ . fold_indent_str
            \ . line
            \ . align_space
            \ . fold_level_str
            \ . fold_size_str
            \ . fold_percentage
    " let line .= repeat(' ', winwidth(0) - strdisplaywidth(line))
    let line .= "              <"
    return line
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :
