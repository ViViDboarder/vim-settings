Plug 'tpope/vim-dispatch', { 'on': 'Dispatch' }
nnoremap <F5> :Make<CR>
command! TagsUpdate Dispatch ctags -R .
