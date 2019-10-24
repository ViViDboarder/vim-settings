Plug 'neomake/neomake'
nnoremap <F5> :Neomake<CR>

let g:neomake_python_enabled_makers = ['flake8']
let g:neomake_python_pytest_maker = {
    \ 'exe': 'py.test',
    \ 'errorformat': &errorformat,
    \ }
let g:neomake_python_tox_maker = {
    \ 'exe': 'tox',
    \ 'errorformat': &errorformat,
    \ }
