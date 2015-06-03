" Remap jk to esc
inoremap jk <esc>
" Easy esc on TEX Yoda
inoremap `` <esc>
vnoremap `` <esc>

" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Bind Make to F5 like other IDEs
nnoremap <F5> :make<CR>

" Remap Ctrl+Space for auto Complete
inoremap <C-Space> <C-n>
inoremap <Nul> <C-n>

" Toggle highlighting with \hr (highlight row)
nnoremap <leader>hr :set cursorline!<CR>

" Toggle Line numbers with Ctrl+N double tap
nmap <C-N><C-N> :set invnumber<CR>
nmap <leader>ln :set invnumber<CR>

" Toggle line wrap with Ctrl+L double tap
nmap <C-L><C-L> :set wrap!<CR>
nmap <leader>lw :set wrap!<CR>

" Toggle White Space
nmap <leader>ws :set list!<CR>

" Map Shift+U to redo
nnoremap <S-u> <C-r>

" Stupid shift key fixes
cmap WQ<CR> wq<CR>
cmap Wq<CR> wq<CR>
cmap W<CR> w<CR>
cmap Q<CR> q<CR>
cmap Q!<CR> q!<CR>
" Stupid semicolon files
cnoremap w; w
cnoremap W; w
cnoremap q; q
cnoremap Q; q
" Avoid accidental Ex-mode
:map Q <Nop>

" Clearing highlighted search
nmap <silent> <leader>/ :set hlsearch! hlsearch?<CR>
noremap <C-h><C-s> :set hlsearch! hlsearch?<CR>
" Clear search
nmap <silent> <leader>cs :nohlsearch<CR>

" Code fold
nmap <leader>cf va{<ESC>zf%<ESC>:nohlsearch<CR>

" Paste over
vnoremap pp p
vnoremap po "_dP

" Buffer nav
nmap gb :bn<CR>
nmap gB :bp<CR>

" Command to display TODO tags in project
command Todo grep TODO

" Easy update tags
command TagsUpdate !ctags -R .
