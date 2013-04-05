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



" ============================================================================
" Project Root Path:                                                      [[[1
" ============================================================================

function! s:calc_confidence(base_confidence, path)
    return a:base_confidence * zl#path#level(a:path)
endfunction

" confidence on a scale of 1-10
call zl#rc#set_default({
\ 'g:zl_root_markers' : [
\ {
\    'confidence' : 9,
\    'dir'        : ['.git' ,'.svn' ,'_darcs' , '.hg' ,'.bzr' ,'nbproject']
\ },
\ {
\    'confidence' : 7,
\    'file'       : [
\      'build.xml' , 'prj.el'    ,'.project'  ,'pom.xml'  , 'Makefile'   ,
\      'Gemfile'   , 'Guardfile' ,'configure' ,'Rakefile' , 'NAnt.build'
\    ]
\ },
\ {
\    'confidence' : 5        ,
\    'file'       : [ 'tags' ,'gtags' ] ,
\    'dir'        : [ 'src'  ,'lib'     ,'bin' , 'doc' ,'include' ]
\ },
\
\ ]})

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

		let d = Fn(d, a:path . ';')
		if d != ''
            if a:type == 'dir'
                let d = fnamemodify(d, ':p:h:h')
            elseif a:type == 'file'
                let d = fnamemodify(d, ':p:h')
            endif
            call add(directories, d)
		endif
	endfor
    return directories
endfunction

function! zl#path#project_root_candidates(...) "                                [[[2
    let search_directory =  a:0 >= 1  ?  zl#path#2dir(a:1)  : expand("%:p:h")

    if search_directory == ''
        call zl#print#warning('empty or nonexisting path!')
        return {'most_possible' : '', 'candidates' : {}}
    endif

    " Ignore remote/virtual filesystem like netrw, fugitive,...
    if match(search_directory, '^\<.\+\>://.*') != -1
        return {'most_possible' : search_directory, 'candidates' : {}}
    endif

    let found = {}
    for mark in g:zl_root_markers
        let confidence = 6
        for [k, v] in items(mark)
            if k == 'confidence'
                let confidence = v
            elseif k == 'dir' || k == 'file'
                let candidates = zl#path#findup(k, v, search_directory)
            endif
            unlet v " Fix E706: Variable type mismatch
        endfor
        if !empty(candidates)
            let found[confidence] = candidates
        endif
    endfor

    let most_possbile_found = search_directory
    let most_possbile_confidence = 0

    let possible_candidates = {}
    for [base_confidence, candidates] in items(found)
        for c in candidates
            let confidence = s:calc_confidence(base_confidence, c)
            let possible_candidates[c] = confidence
            if confidence > most_possbile_confidence
                let most_possbile_found = c
                let most_possbile_confidence = confidence
            endif
        endfor
    endfor

    return {'most_possible' : most_possbile_found, 'candidates' : possible_candidates}
endfunction

function! zl#path#find_project_root(...) "                                [[[2
    let candidates = call('zl#path#project_root_candidates', a:000)

    return candidates['most_possible']
endfunction


function! zl#path#goto_project_root(...) "                                [[[2
    let opts = {
                \ 'path' : expand("%:p"),
                \ 'cd'   : 'cd',
                \}
    if a:0 >= 1 && type(a:1) == type({})
        call extend(opts, a:1)
    endif

    let root = zl#path#find_project_root(opts.path)
    if &l:autochdir
        setl noautochdir
    endif
    exec opts['cd'] . " " . zl#path#search_escape(root)
    return root
endfunction

" ============================================================================
" Utility:                                                                [[[1
" ============================================================================

let s:path_sep_char = (exists('+shellslash') ? '[\\/]' : '/')
let s:path_sep_pattern = s:path_sep_char . '\+'

" Convert all directory separators to "/".
function! zl#path#unify_separator(path)
    return substitute(a:path, s:path_sep_pattern, '/', 'g')
endfunction

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

function! zl#path#search_escape(name) "                              [[[2
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
    return zl#string#count(a:path, s:path_sep_char)
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

" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=syntax fmr=[[[,]]] fdl=1 :

