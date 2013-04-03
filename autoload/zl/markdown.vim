"=============================================================================
"     FileName: markdown.vim
"       Author: Zhao Cai
"        Email: caizhaoff@gmail.com
"     HomePage:
" Date Created: Sun 09 Oct 2011 04:21:00 PM EDT
"Last Modified: Thu 20 Sep 2012 04:28:32 PM EDT
"
"	 Copyright: (C) 2010-2011 Zhao Cai
"=============================================================================
"===  Load Guard  ===                                                     [[[1
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif
let s:save_cpo = &cpo
set cpo&vim

"===  HEADER  ===                                                         [[[1

"---  FUNCTION  --------------------------------------------------------------




function! zl#markdown#add_header_level()
  let lnum = line('.')
  let line = getline(lnum)

  if line =~ '^\s*$'
    return
  endif

  if line =~ '^\s*\(#\+\).\+\1\s*$'
    let level = zl#string#count_first_nonwhite(line)
    if level < 6
      let line = substitute(line, '\(#\+\).\+\1', '#&#', '')
      call setline(lnum, line)
    endif
  else
      let line = substitute(line, '^\s*', '&# ', '')
      let line = substitute(line, '\s*$', ' #&', '')
      call setline(lnum, line)
  endif
endfunction

function! zl#markdown#dec_header_level()
  let lnum = line('.')
  let line = getline(lnum)

  if line =~ '^\s*$'
    return
  endif

  if line =~ '^\s*\(#\+\).\+\1\s*$'
    let level = zl#string#count_first_nonwhite(line)
    let old = repeat('#', level)
    let new = repeat('#', level - 1)

    let chomp = line =~ '#\s'

    let line = substitute(line, old, new, 'g')

    if level == 1 && chomp
      let line = substitute(line, '^\s', '', 'g')
      let line = substitute(line, '\s$', '', 'g')
    endif
    call setline(lnum, line)
  endif
endfunction



"===  LINK  ===                                                           [[[1

let &cpo = s:save_cpo
unlet s:save_cpo


" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=0 :
