Plug 'neomake/neomake'
nnoremap <F5> :Neomake<CR>
let g:neomake_python_enabled_makers = ['flake8']
command! TagsUpdate NeomakeSh ctags -R .
