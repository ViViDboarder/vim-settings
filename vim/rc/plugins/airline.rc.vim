Blink 'vim-airline/vim-airline'
Blink 'vim-airline/vim-airline-themes'
" Use short-form mode text
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ 't'  : 'T',
    \ }
" abbreviate trailing whitespace and mixed indent
let g:airline#extensions#whitespace#trailing_format = 'tw[%s]'
let g:airline#extensions#whitespace#mixed_indent_format = 'i[%s]'
" Vertical separators for all
let g:airline_left_sep=''
let g:airline_left_alt_sep=''
let g:airline_right_sep=''
let g:airline_right_alt_sep=''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" Slimmer section z
let g:airline_section_z = '%2l/%L:%2v'
" Skip most common encoding
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
" If UTF-8 symbols don't work, use ASCII
" let g:airline_symbols_ascii = 1
