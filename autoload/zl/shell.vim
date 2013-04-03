"=============================================================================
" Synopsis       : vim library related to shell
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 03 Apr 2013 01:02:06 AM EDT
" Tag            : [ vim, library, filetype ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================


" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif




" ============================================================================
" Path:                                                                   [[[1
" ============================================================================

" -------- - -----------------------------------------------
"  Desc    : Short path based on predefined dictionary. It is useful when you
"			get tired of seeing the long prefix of /Users/username,...
"  Raise   :
"
"  Example : > echo zl#shell#shorten_path(getcwd())
"
"  Refer   :
" -------- - -----------------------------------------------

if !exists("g:zl_path_mapping")
	" Note: longest match first
	let g:zl_path_mapping = [
				\ [expand('/Volumes' . "$HOME") , '~'],
				\ [expand("$HOME") , '~'],
				\ [expand("$VIM") , '$VIM']
				\]
endif

function! zl#shell#shorten_path(path)
	let l:path = a:path

	for item in g:zl_path_mapping
		let l:path = substitute(l:path, '\V'.escape(item[0],'\'), item[1], 'ge' )
	endfor

	return l:path
endfunction

function! zl#shell#range_shorten_path(...) range
	let l:save_cursor =  a:0 >= 1  ?  a:1  :  getpos(".")

	for l:line in range(a:firstline,a:lastline)
		let l:line_string = getline(l:line)
		call setline(l:line, zl#shell#shorten_path(l:line_string))
	endfor

	call setpos('.', l:save_cursor)
endfunction












" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :

