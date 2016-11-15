" All Python plugins and settings
Plug 'alfredodeza/coveragepy.vim'
Plug 'alfredodeza/pytest.vim'
" pytest.vim {{
nmap <silent><leader>ptp <Esc>:Pytest project<CR>
nmap <silent><leader>ptf <Esc>:Pytest file<CR>
nmap <silent><leader>ptm <Esc>:Pytest method<CR>
" }} pytest.vim
Plug 'davidhalter/jedi-vim'
" jedi-vim {{
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 0
" }} jedi-vim
Plug 'klen/python-mode'
" python-mode {{
let g:pymode_breakpoint = 0
let g:pymode_lint = 0
let g:pymode_lint_checkers = ['flake8']
let g:pymode_lint_on_write = 0
let g:pymode_rope = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0
" }} python-mode
