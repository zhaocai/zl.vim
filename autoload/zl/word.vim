" =============== ============================================================
" Name           : word
" Synopsis       : vim library related to (current) word
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 03 Apr 2013 12:58:16 AM EDT
" Tag            : [ vim, library, filetype ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================






" ============================================================================
" Word Count:                                                             [[[1
" ============================================================================

function! zl#word#word_count() "                                          [[[2
"----------------------%>----------------------
" Word count of the current buffer
"
" Usage:
"   set statusline+=%{zl#word#word_count()}
"----------------------%<----------------------
    if exists("b:Global_Word_Count") == 0
        let b:Global_Word_Count = 0
        let b:Current_Line_Word_Count = 0
        let b:Current_Line_Number = line(".")
        call zl#word#other_line_word_count()
    endif
    call zl#word#current_line_word_count()
    return b:Global_Word_Count + b:Current_Line_Word_Count
endfunction

function! zl#word#other_line_word_count() "                               [[[2
" returns the count of how many words are in the entire file excluding the
" current line updates the buffer variable Global_Word_Count to reflect this

    let data = []
    "get lines above and below current line unless current line is first or last
    if line(".") > 1
        let data = getline(1, line(".")-1)
    endif
    if line(".") < line("$")
        let data = data + getline(line(".")+1, "$")
    endif
    let count_words = 0
    let pattern = "\\<\\(\\w\\|-\\|'\\)\\+\\>"
    for str in data
        let count_words = count_words + zl#word#num_patterns_in_string(str, pattern)
    endfor
    let b:Global_Word_Count = count_words
    return count_words
endfunction

function! zl#word#current_line_word_count() "                             [[[2
"returns the word count for the current line
"updates the buffer variable Current_Line_Number
"updates the buffer variable Current_Line_Word_Count
    if b:Current_Line_Number != line(".") "if the line number has changed then add old count
        let b:Global_Word_Count = b:Global_Word_Count + b:Current_Line_Word_Count
    endif
    "calculate number of words on current line
    let line = getline(".")
    let pattern = "\\<\\(\\w\\|-\\|'\\)\\+\\>"
    let count_words = zl#word#num_patterns_in_string(line, pattern)
    let b:Current_Line_Word_Count = count_words "update buffer variable with current line count
    if b:Current_Line_Number != line(".") "if the line number has changed then subtract current line count
        let b:Global_Word_Count = b:Global_Word_Count - b:Current_Line_Word_Count
    endif
    let b:Current_Line_Number = line(".") "update buffer variable with current line number
    return count_words
endfunction


function! zl#word#num_patterns_in_string(str, pat) "                      [[[2
"returns the number of patterns found in a string
    let i = 0
    let num = -1
    while i != -1
        let num = num + 1
        let i = matchend(a:str, a:pat, i)
    endwhile
    return num
endfunction



" ============================================================================
" Cursor Variable:                                                        [[[1
" ============================================================================

function! zl#word#cvar() "                                                [[[2
    " -------- - -----------------------------------------------
    "  Desc    : include the prefix like s:,g:,... into
    "            the <cword> expanstion
    "
    "  Args    : none
    "  Return  : current cursor varible name
    "  Raise   :
    "
    "  Example : > echo zl#word#cvar()
    "
    "  Refer   :
    " -------- - -----------------------------------------------

	let l:saved_isk = s:cvar_pre()

	let l:cword =  expand("<cword>")

	call s:cvar_post(l:saved_isk)
	return l:cword
endfunction

function! s:cvar_pre() "                                                  [[[2
	let l:saved_isk = &l:iskeyword
	if &ft == 'vim'
		setlocal iskeyword+=:,#,.,_
	elseif &ft == 'cpp'
		setlocal iskeyword+=:,.
	elseif &ft == 'perl'
		setlocal iskeyword+=$,:
	elseif &ft =~ 'sh\|bash'
		setlocal iskeyword+=$,{,}
	elseif &ft =~ 'snippet'
		setlocal iskeyword+=$,:,{,}
	endif
	return l:saved_isk
endfunction


function! s:cvar_post(saved_isk) "                                        [[[2
	let &l:iskeyword = a:saved_isk
endfunction




" ============================================================================
" Current Word:                                                           [[[1
" ============================================================================
function! zl#word#current_keyword() "                                     [[[2
    let cur_text = matchstr(getline('.'), '^.*\%'
                \ . (col('.')-1) . 'c.')

    return matchstr(cur_text, '\<\k*\>\s*$')
endfunction

function! zl#word#last_whitespace_col(...) "                              [[[2
"---------------%>---------------
"  opts = {
"       \ 'base_line'  : line('.') ,
"       \ 'bash_col'   : col('.')  ,
"       \ 'is_virtcol' : 1         ,
"  \ }
"
"  [TODO]( is_virtcol ) @zhaocai @start(2012-01-16 21:07)
"---------------%<---------------
    let opts = a:0 >= 1 && type(a:1) == type({})  ?  a:1  :  {}
    let base_line = has_key(opts,'base_line') ? opts['base_line'] : line('.')
    " let is_virtcol = has_key(opts,'is_virtcol') ? opts['is_virtcol'] : 1
    " let default_col =
    let base_col = has_key(opts,'base_col') ? opts['base_col'] : col('.')

    let line = getline(base_line)
    let i = base_col - 1
    while i >= 0
        if line[i] =~ '\s'
            return (i+1)
        endif
        let i -= 1
    endwhile
    return 1 " return the first column if not found
endfunction

function! zl#word#visual_selection()
    let a_save = @a
    try
        normal! gv"ay
        return @a
    finally
        let @a = a_save
    endtry
endfunction

" ============================================================================
" Case:                                                                   [[[1
" ============================================================================
" Refer: neat#case



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :
