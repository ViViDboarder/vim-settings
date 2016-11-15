" Settings to keep gitgutter fast
let g:gitgutter_enabled = 1
" Will toggle signs when I want them
let g:gitgutter_signs = 0
" Already using Fugitive, don't need more mappings
let g:gitgutter_map_keys = 0
" Make it more passive
let g:gitgutter_eager = 0
let g:gitgutter_realtime = 0
" Quick leader command to toggle git-gutter
nmap <leader>gg :GitGutterSignsToggle<CR>
