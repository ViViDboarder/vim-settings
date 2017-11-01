" Install plugins
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neoinclude.vim'
Plug 'Shougo/neco-syntax'
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'zchee/deoplete-go', { 'do': 'make' }

" Auto complete with C-Space
inoremap <silent><expr> <C-Space>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<C-Space>" :
        \ deoplete#manual_complete()

function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction
"}}}

" Auto close preview when done
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

if !exists('g:deoplete#sources')
    let g:deoplete#sources = {}
endif
if !exists('g:deoplete#keyword_patterns')
    let g:deoplete#keyword_patterns = {}
endif
if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif

" Set allowed sources
let g:deoplete#sources._ = ['buffer', 'member', 'file', 'tag'] ", 'omni']
let g:deoplete#sources.go = ['buffer', 'member', 'file', 'omni']
let g:deoplete#sources.python = ['buffer', 'member', 'file', 'omni']
" Set default keyword pattern (vim regex)
let g:deoplete#keyword_patterns['default'] = '\h\w*'
" Set omni patters for deoplete (python3 regex)
let g:deoplete#omni#input_patterns.go = '([^. \t](\.|->))\w*'
let g:deoplete#omni#input_patterns.python = '([^. \t]\.|^\s*@|^\s*from\s.+ import |^\s*from |^\s*import )\w*'

" Default settings
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#auto_completion_start_length = 2
let g:deoplete#manual_completion_start_length = 0

" Be extra sure that jedi works
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0
let g:jedi#popup_on_dot = 0
let g:jedi#popup_select_first = 0
let g:jedi#show_call_signatures = 0
let g:jedi#smart_auto_mappings = 0
