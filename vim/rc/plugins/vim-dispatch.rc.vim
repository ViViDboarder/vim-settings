Plug 'tpope/vim-dispatch'
nnoremap <F5> :Make<CR>
command! TagsUpdate Dispatch ctags -R .
