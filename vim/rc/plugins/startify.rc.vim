Plug 'mhinz/vim-startify'
let g:startify_list_order = [
    \ ['   My Bookmarks'], 'bookmarks',
    \ ['   Most recently used files in the current directory'], 'dir',
    \ ['   Most recently used files'], 'files',
    \ ['   My Sessions'], 'sessions'
    \ ]

" Override in local rc
" let g:startify_bookmarks = [
"     \ '~/.vim',
"     \ '~/workspace/my-shoestrap'
"     \ ]
" let g:startify_custom_header =
"       \ map(split(system('fortune | cowsay'), '\n'), '"   ". v:val') + ['','']
