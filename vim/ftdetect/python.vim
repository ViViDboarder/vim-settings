au VimEnter,BufRead,BufNewFile *.py
    \ if executable('ipython') |
    \   call neoterm#repl#set('ipython') |
    \ endif |
    \ if executable('pytest') |
    \   call neoterm#test#libs#add('pytest') |
    \ endif

let g:neomake_python_pytest_maker = {
    \ 'exe': 'py.test',
    \ 'errorformat': &errorformat,
    \ }

let g:neomake_python_tox_maker = {
    \ 'exe': 'tox',
    \ 'errorformat': &errorformat,
    \ }


