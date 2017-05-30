" All Python plugins and settings
Plug 'alfredodeza/coveragepy.vim', { 'for': 'python' }
Plug 'alfredodeza/pytest.vim', { 'for': 'python' }
" pytest.vim {{
nmap <silent><leader>ptp <Esc>:Pytest project<CR>
nmap <silent><leader>ptf <Esc>:Pytest file<CR>
nmap <silent><leader>ptm <Esc>:Pytest method<CR>
" }} pytest.vim
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
" jedi-vim {{
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 0
" }} jedi-vim
Plug 'klen/python-mode', { 'for': 'python' }
" python-mode {{
" A lot is disabled, what I'm using:
"   breakpoints, virtualenv, motions, syntax,
"   indent
let g:pymode_breakpoint = 1
let g:pymode_breakpoint_bind = '<leader>pb'
let g:pymode_folding = 1
let g:pymode_indent = 1
let g:pymode_lint = 0
let g:pymode_lint_checkers = ['flake8']
let g:pymode_lint_on_write = 0
let g:pymode_motion = 1
let g:pymode_rope = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0
let g:pymode_run = 1
let g:pymode_options_max_line_length = 80
let g:pymode_options_colorcolumn = 1
" }} python-mode
