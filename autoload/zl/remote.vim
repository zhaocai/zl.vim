" =============== ============================================================
" Synopsis       : vim library for remote servers
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Mon 03 Sep 2012 09:05:14 AM EDT
" Last Modified  : Wed 03 Apr 2013 01:03:36 AM EDT
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


"===  ENVIRONMENT  ===                                                    [[[1
" Note: 1. Mac Users: make a symlink gvim to mvim
"
"---  FUNCTION  --------------------------------------------------------------
" Function: zl#remote#open_server((servername,rc)                       [[[2
"     Desc: Open a remote vim server
" Argument: servername
"			server rc
"   Return: 0 - fail || 1 - succeed
"
"  Example: if !zl#remote#open_server("ZREMOTE")
"				finish
"			endif

func zl#remote#open_remoteserver(servername,...)
	if !has("clientserver") || !executable("gvim")
		return 0
	endif

	if a:servername == ''
		return 0
	endif

    let l:rc =  a:0 >= 1  ? " -u " . a:1  :  ''

	if zl#sys#ostype() == "Windows"
		if ! executable("start")
			return 0
		endif
		call system("start gvim " . l:rc . " --servername" . a:servername)
	else
		call system("gvim" . l:rc ." --servername " . a:servername)
	endif

	return 1
endf

"---  FUNCTION  --------------------------------------------------------------
" Function: zl#remote#exists_server                                     [[[2
"     Desc:
" Argument: servername
"   Return: 0 - fail || 1 - succeed
"
"  Example: if !zl#remote#exists_server("ZREMOTE")
"				finish
"			endif

func zl#remote#exists_server(servername)
	return (index(split(serverlist(), '\n'), a:servername) == -1) ? 0 : 1
endf

"===  COMMUNICATION  ===                                                  [[[1
"
func zl#remote#client_id(servername)
	return remote_expr(a:servername, 'expand("<client>")')
endf








" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :

