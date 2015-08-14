" Configurationf or ctrlp.vim

" Ensure max height isn't too large. (for performance)
let g:ctrlp_max_height = 10
" Conditional Mappings
let g:ctrlp_map = '<C-t>'
" Allow ctrl p to open over startify
let g:ctrlp_reuse_window = 'startify'
" Support tag jumping
let g:ctrlp_extensions = ['tag', 'buffertag']
" Support Apex language
let g:ctrlp_buftag_types = {
        \ 'go'    : {
            \ 'bin' : 'gotags',
            \ 'args' : '-sort -silent',
        \}
    \}
" Leader Commands
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>t :CtrlPBufTag<CR>
nnoremap <leader>r :CtrlPTag<CR>
nnoremap <leader>u :CtrlPCurFile<CR>
nnoremap <leader>m :CtrlPMRUFiles<CR>

" Special stuff for The Silver Searcher
if executable('ag')
    " use ag
    set grepprg=ag\ --nogroup\ --nocolor
    " use ag for CtrlP
    let g:ctrlp_user_command = 'ag %s -l --nocolor --nogroup -g ""'
    " ag is fast enough we don't need cache
    let g:ctrlp_use_caching = 0
endif
