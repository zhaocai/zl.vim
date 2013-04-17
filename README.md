# zl.vim library

This library provides vim utility functions.

The library is included in autoload files. No autocommands are automatically
created.


## Installation

## How to use?

## Highlight

1. build sophisticated rules
1. find project root with confidence
1. optimized foldtext


## Example Usage:

```vim
    NeoBundle 'zhaocai/zl.vim'

    call zl#rc#init()
    let g:os_type = zl#sys#ostype()

    " Reload Script:
    " --------------
    autocmd FileType vim call <SID>my_vim_settings()
    function! s:my_vim_settings()
        command! -buffer -nargs=0 ZreloadScript  call zl#rc#script_force_reload()
        nnoremap <buffer> <leader>rs :<C-u>ZreloadScript<CR>
        command! -buffer ZautoReloadScript autocmd BufWritePost <buffer> call zl#rc#script_force_reload()
    endfunction

    " Cword Highlight:
    " ----------------
    command! -nargs=0 ZhlCwordToggle call zl#syntax#hl_cword_toggle()

    " Auto Highlight Cursor Word
    " let g:zl_hl_cword_syngroup = 'SpellCap'
    nnoremap <silent> <C-h>h :<C-u>call zl#syntax#hl_cword_toggle()<CR>

    " Syntax Highlight Info:
    " ----------------------
    "Show cword syntax group and color info
    nnoremap [get]a :call zl#syntax#cursor_hl_echo()<CR>
    nnoremap <silent> [do]ca :call setreg('*', zl#syntax#cursor_hlgroup())<CR>

```

## Erb Escaping

1. `#syntax#range_syntax_ignore` line 6

## License

Copyright (c) 2012 Zhao Cai <caizhaoff@gmail.com>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.




