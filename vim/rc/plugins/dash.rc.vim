" Install plugin
Plug 'rizzatti/dash.vim', { 'on': 'DashSearch' }
" Set config"
nmap <silent> <leader>d <Plug>DashSearch
let g:dash_map = {
    \ 'apex' : 'apex',
    \ 'visualforce' : 'vf',
    \ }
