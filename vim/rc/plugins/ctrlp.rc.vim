Plug 'ctrlpvim/ctrlp.vim'
" Configuration for ctrlp.vim

let g:ctrlp_in_use = 1

" Ensure max height isn't too large. (for performance)
let g:ctrlp_max_height = 10
" Conditional Mappings
let g:ctrlp_map = '<C-t>'
" Allow ctrl p to open over startify
let g:ctrlp_reuse_window = 'startify'
" Support tag jumping
let g:ctrlp_extensions = ['tag', 'buffertag']
" Don't search right away
let g:ctrlp_lazy_update = 50
" Quick exiting with <bs>
let g:ctrlp_brief_prompt = 1
" Support golang tags
let g:ctrlp_buftag_types = {
        \ 'go'    : {
            \ 'bin' : 'gotags',
            \ 'args' : '-sort -silent',
        \}
    \}
" When using slow built in search, limit max depth
let g:ctrlp_max_depth = 4
" When using slow built in search, limit max files
let g:ctrlp_max_files = 1000
" Use git ls-files when in a git project
let g:ctrlp_user_command = {
        \ 'types': {
            \ 1: ['.git', 'cd %s && git ls-files'],
        \}
    \}
" Leader Commands
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>m :CtrlPMRUFiles<CR>
nnoremap <leader>p :CtrlP<CR>
nnoremap <leader>r :CtrlPTag<CR>
nnoremap <leader>t :CtrlPBufTag<CR>
nnoremap <leader>u :CtrlPCurFile<CR>
nnoremap <silent> <F2> :CtrlPBuffer<CR>

" Use custom search command
if executable('rg')
    let g:ctrlp_user_command['fallback'] = 'rg %s --files --color=never --glob ""'
    " rg is fast enough we don't need cache
    let g:ctrlp_use_caching = 0
elseif executable('ag')
    let g:ctrlp_user_command['fallback'] = 'ag %s -l --depth 5 --nocolor --nogroup -g ""'
    " ag is fast enough we don't need cache
    let g:ctrlp_use_caching = 0
endif
