" --------------- ------------------------------------------------------------
" Name           : date
" Synopsis       : date related functions
" Author         : Zhao Cai <caizhaoff@gmail.com>
" HomePage       : https://github.com/zhaocai/zl.vim
" Version        : 0.1
" Date Created   : Thu 05 Jan 2012 12:01:46 AM EST
" Last Modified  : Thu 20 Sep 2012 04:28:30 PM EDT
" Tag            : [ vim, lib, date ]
" Copyright      : (c) 2012 by Zhao Cai,
"                  Released under current GPL license.
" --------------- ------------------------------------------------------------


" ============================================================================
" Convert:                                                                [[[1
" ============================================================================

function! zl#date#convert_format(date,format)"                            [[[2
    return strftime(a:format,zl#date#2time(a:date))
endfunction

function! zl#date#2time(date)"                                            [[[2
perl << EOF
    use strict;
    use warnings FATAL => 'all';
    use warnings NONFATAL => 'redefine';

    use Date::Parse qw ( str2time );
    my $date = VIM::Eval('a:date');
    VIM::DoCommand "let stdtime=". str2time($date);
EOF
    return stdtime
endfunction



" ============================================================================
" Modeline:                                                               [[[1
" ============================================================================
" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :

