" All Python plugins and settings
Plug 'alfredodeza/coveragepy.vim', { 'for': 'python' }
Plug 'alfredodeza/pytest.vim', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
nmap <silent><leader>ptp <Esc>:Pytest project<CR>
nmap <silent><leader>ptf <Esc>:Pytest file<CR>
nmap <silent><leader>ptm <Esc>:Pytest method<CR>
