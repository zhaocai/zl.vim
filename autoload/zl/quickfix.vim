" =============== ============================================================
" Name           : quickfix
" Synopsis       : vim quickfix library
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 03 Apr 2013 01:05:56 AM EDT
" Tag            : [ vim, library, filetype ]
" Copyright      : © 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================



"===  OPEN / CLOSE ===                                                    [[[1


"---  FUNCTION  --------------------------------------------------------------
" Function: zl#quickfix#is_open                                           [[[2
"     Desc:
" Argument: None
"   Return: non-zero if quickfix window is opened.
"
"  Example: if zl#quickfix#is_open()
"				...
"			endif

func zl#quickfix#is_open()
  return count(map(range(1, winnr('$')), 'getwinvar(v:val, "&buftype")'),
			  \'quickfix'
			  \) > 0
endf


"---  FUNCTION  --------------------------------------------------------------
" [TODO]( use opts dict args, 0,1,2,64 are vague ) @zhaocai @start(2013-04-03 01:05)
" Function: zl#quickfix#open                                              [[[2
"     Desc: Open quixkfix window with various options as below:
"
" Argument: a:is_empty_open: if opening empty quickfix window
"
"			a:is_noerror_open: if non-zero, opens only if quickfix has
"			recognized errors Return: non-zero if quickfix window is opened.
"
"			a:is_hold_cursor: if holding cursor in the quickfix window
"
"			a:min_width: resize quickfix windows if its width is less than
"			min_width
"
"  Example: call zl#quickfix#open(0,1,1,64)

func zl#quickfix#open(is_empty_open, is_noerror_open,
			\is_hold_cursor, min_width,...)
	let l:title =  a:0 >= 1  ?  a:1  :  ''

	let l:num_errors = len(filter(getqflist(), 'v:val.valid'))
	let l:num_others = len(getqflist()) - l:num_errors
    let saved_lazyredraw = &lazyredraw
	set lazyredraw


	if a:is_empty_open
				\|| l:num_errors > 0
				\|| (!a:is_noerror_open && l:num_others > 0)
		copen
		let w:quickfix_title = l:title

		if winwidth(0) < a:min_width
			exec 'wincmd J'
		endif

		if !a:is_hold_cursor
			wincmd p
		endif
	else
		cclose
	endif

    redraw
    let &lazyredraw = saved_lazyredraw
	if l:num_others > 0
		echo printf('Quickfix: %d(+%d)', l:num_errors, l:num_others)
	else
		echo printf('Quickfix: %d', l:num_errors)
	endif
endf


"===  FILTER  ===                                                         [[[1
func zl#quickfix#compare_entries(e0, e1)
  if a:e0.bufnr != a:e1.bufnr
    let i0 = bufname(a:e0.bufnr)
    let i1 = bufname(a:e1.bufnr)
  elseif a:e0.lnum != a:e1.lnum
    let i0 = a:e0.lnum
    let i1 = a:e1.lnum
  elseif a:e0.col != a:e1.col
    let i0 = a:e0.col
    let i1 = a:e1.col
  else
    return 0
  endif
  return (i0 > i1 ? +1 : -1)
endf


func zl#quickfix#sort()
  call setqflist(sort(getqflist(), 'zl#quickfix#compare_entries'), 'r')
endf

func zl#quickfix#sort_uniq()
  let l:sort_list = sort(getqflist(), 'zl#quickfix#compare_entries')
  let l:uniq_list = []
  let last = ''
  for item in l:sort_list
    let this = bufname(item.bufnr) . "\t" . item.lnum
    if this !=# last
      call add(l:uniq_list, item)
      let last = this
    endif
  endfor
  call setqflist(l:uniq_list)
endf

":TODO: Wed Sep 14, 2011  08:25PM, zhaocai
" quickfix filter duplicated file names
"func zl#quickfix#shorten_path()
	"let l:qflist = getqflist()
	"let l:short_path_qflist = []
	"for item in l:qflist
		"call add(l:short_path_qflist, zl#shell#shorten_path(item))
	"endfor
	"call setqflist(l:short_path_qflist)
"endf


"===  BROWSER  ===                                                        [[[1

"---  FUNCTION  --------------------------------------------------------------
" Function: zl#quickfix#circulate                                         [[[2
"     Desc: circulate :cnext and :cp
"           when hit :cn the bottom, instead of stopping and giving error
"           message, :cfirst and continue.
" Argument:
"   Return:
"
"  Example:
"       command! -nargs=0 -bang QFnext call zl#quickfix#circulate('<bang>','next')
"       command! -nargs=0 -bang QFprev call zl#quickfix#circulate('<bang>','prev')

"       noremap 99 :QFprev<CR>
"       noremap 00 :QFnext<CR>

"circulate errors
let s:qf_cmd_pair = {
            \   'next'	: ['cn','cfirst'],
            \   'prev'	: ['cp','clast'],
            \}

func zl#quickfix#circulate(bang,direction)
    let pair = get(s:qf_cmd_pair, a:direction, ['cn','cfirst'])
    let _shortmess = &shortmess
    try
        set shortmess=
        silent exec pair[0].a:bang
    catch /^Vim\%((\a\+)\)\=:E553/
        silent exec pair[1].a:bang
    catch /^Vim\%((\a\+)\)\=:E42/
		" No Error
		return
    finally
        let &shortmess = _shortmess
    endtry
endfunc


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :

