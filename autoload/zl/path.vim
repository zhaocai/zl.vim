" =============== ============================================================
" Name           : path
" Synopsis       : path related functions
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Date Created   : Thu 05 Jan 2012 12:01:46 AM EST
" Last Modified  : Wed 03 Apr 2013 01:09:04 AM EDT
" Tag            : [ vim, lib, path ]
" Copyright      : (c) 2012 by Zhao Cai,
"                  Released under current GPL license.
" =============== ============================================================

" ============================================================================
" Load Guard:                                                             [[[1
" ============================================================================
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp'])
    finish
endif


">=< Settings [[[1 ===========================================================

call zl#rc#set_default({
\ 'g:zl_root_markers' : [
\ {
\    'dir' : ['.git', '.svn', '_darcs', '.hg', '.bzr', 'nbproject']
\ },
\ {
\    'file' : [ 'build.xml', 'prj.el', '.project', 'pom.xml', 'Makefile',
\               'Gemfile'  , 'Guardfile', 'configure', 'Rakefile', 'NAnt.build'
\             ]
\ },
\ {
\    'file' : [ 'tags'  , 'gtags' ],
\    'dir' : ['src', 'lib', 'bin', 'doc', 'include' ]
\ },
\
\ ]})

call zl#rc#set_default("g:zl_scm_dirs",
\ ['.git', '.svn' , '_darcs', '.hg', '.bzr'])

call zl#rc#set_default("g:zl_project_identifier_files",
\ [
\   'build.xml', 'prj.el', '.project', 'pom.xml', 'Makefile',
\   'Gemfile'  , 'Guardfile',
\   'configure', 'Rakefile', 'NAnt.build', 'tags', 'gtags'
\ ]
\)

call zl#rc#set_default("g:zl_project_identifier_dirs",
\ ['src', 'lib', 'bin', 'doc', 'include' ] )


">=< Path [[[1 ===============================================================
function! zl#path#substitute_separator(path) "                            [[[2
    return zl#sys#is_win()
                \ ? substitute(a:path, '\\', '/', 'g') : a:path
endfunction

function! zl#path#2dir(path) "                                            [[[2
    return zl#path#substitute_separator(isdirectory(a:path)
                \ ? a:path : filereadable(a:path)
                \ ? fnamemodify(a:path, ':p:h') : ''
                \ )
endfunction

function! zl#path#escape_file_search(name) "                              [[[2
    return escape(a:name, '*[]?{}, ')
endfunction

function! zl#path#smart_quote(path) "                                     [[[2
    """ DO NOT quote if
    " (1) it is quoted already
    " (2) it does not contain space
    """
    return (a:path =~# '\s' && a:path !~# '^\([''"]\).*\1$') ? string(a:path) : a:path
endfunction

function! zl#path#level(path) "                                           [[[2

    let full_path = fnamemodify(a:path, ':p')

    let l:parent = fnamemodify(a:path, ":p" . repeat(':h',a:level))

    return zl#path#substitute_separator(strpart(l:full_path,len(l:parent)))
endfunction

function! zl#path#tail(path,level,...) "                                  [[[2
    let l:opts =  a:0 >= 1  ?  a:1  :  {}
	if type(l:opts) != type({})
		call zl#print#warning('optional opts should be a dictionary!')
    endif

    let l:modifier = has_key(l:opts,'modifier') ? l:opts.modifier : ''

    let l:full_path = fnamemodify(a:path,':p'.l:modifier)
    let l:parent = fnamemodify(a:path, ":p" . repeat(':h',a:level))

    return zl#path#substitute_separator(strpart(l:full_path,len(l:parent)))
endfunction

function! zl#path#findup(type, namelist, path) "                          [[[2
    if a:type == 'dir'
        let Fn = function("finddir")
    elseif a:type == 'file'
        let Fn = function("findfile")
    else
        throw 'Wrong type to search:' . a:type
    endif

    let directories = []
	for d in a:namelist
		let d = Fn(d, zl#path#escape_file_search(a:path) . ';')
		if d != ''
            call add(directories, d)
		endif
	endfor
    return map(directories, "fnamemodify(v:val, ':p:h')")
endfunction

function! s:most_possible_root(found)

endfunction

function! zl#path#find_project_root(...) "                                [[[2
    " [TODO]( use confidence rating ) @zhaocai @start(2012-09-15 11:09)
	let search_directory =  a:0 >= 1  ?  zl#path#2dir(a:1)  : expand("%:p:h")

	if search_directory == ''
		call zl#print#warning('empty or nonexisting path!')
		return ''
	endif

	" Ignore remote/virtual filesystem like netrw, fugitive,...
	if match(search_directory, '^\<.\+\>://.*') != -1
		return search_directory
	endif
    
    " let found = {}
    " let i     = 1
    " for m in values(g:zl_root_markers)
    "     for [k, v] in items(m)
    "         let found[i] = zl#path#findup(k, v, search_directory)
    "         let i += 1
    "     endfor
    " endfor

	" Search SCM directory.
    let directories = zl#path#findup('file', g:zl_scm_dirs, search_directory)
    if ! empty(directories)
        return fnamemodify(sort(directories)[-1], ':p:h:h')
    endif

	" Search project identifier files
    let directories = zl#path#findup('file', g:zl_project_identifier_files, search_directory)
    if ! empty(directories)
        return fnamemodify(sort(directories)[-1], ':p:h:h')
    endif

	" Search project identifier dirs
    let directories = zl#path#findup('dir', g:zl_project_identifier_dirs, search_directory)
    if ! empty(directories)
        return fnamemodify(sort(directories)[-1], ':p:h:h')
    endif

    return ''
endfunction


function! zl#path#goto_project_root(...) "                                [[[2
    let opts = {
                \ 'path' : expand("%:p:h"),
                \ 'cd'   : 'cd',
                \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    let root = zl#path#find_project_root(opts.path)
    if &l:autochdir
        setl noautochdir
    endif
    exec opts['cd'] . " " . zl#path#escape_file_search(root)
    return root
endfunction


" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :

