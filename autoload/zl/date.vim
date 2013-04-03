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

">=< Load Guard [[[1 =========================================================
if !zl#rc#load_guard('zl_' . expand('<sfile>:t:r'), 700, 100, ['!&cp','has("perl")'])
    finish
endif
let s:save_cpo = &cpo
set cpo&vim

">=< Convert [[[1 ============================================================

fun! zl#date#convert_format(date,format)"                           [[[2
    return strftime(a:format,zl#date#2time(a:date))
endf

fun! zl#date#2time(date)"                                    [[[2
perl << EOF
    use strict;
    use warnings FATAL => 'all';
    use warnings NONFATAL => 'redefine';

    use Date::Parse qw ( str2time );
    my $date = VIM::Eval('a:date');
    VIM::DoCommand "let stdtime=". str2time($date);
EOF
    return stdtime
endf



"▲ Modeline ◀ & cpo [[[1 =====================================================
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set ft=vim ts=4 sw=4 tw=78 fdm=marker fmr=[[[,]]] fdl=1 :

