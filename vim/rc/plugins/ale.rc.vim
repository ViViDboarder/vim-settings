" Install ALE
Plug 'dense-analysis/ale'
let g:airline#extensions#ale#enabled = 1
" Speed up first load time for quick editing
let g:ale_lint_on_enter = 0

" NOTE: Some of these are installed when bootstrapping environment, outside of vim setup
let g:ale_linters = {
            \ 'go': ['gopls', 'golint', 'golangci-lint'],
            \ 'python': ['pyls', 'mypy'],
            \ 'rust': ['rls', 'cargo'],
            \ 'sh': ['language_server', 'shell', 'shellcheck'],
            \ 'text': ['proselint', 'alex'],
            \}
let g:ale_linter_aliases = {
            \ 'markdown': ['text'],
            \}
" More than a few languages use the same fixers
let s:ale_pretty_trim_fixer = ['prettier', 'trim_whitespace', 'remove_trailing_lines']
let g:ale_fixers = {
            \ '*': ['trim_whitespace', 'remove_trailing_lines'],
            \ 'go': ['gofmt', 'goimports'],
            \ 'json': s:ale_pretty_trim_fixer,
            \ 'rust': ['rustfmt'],
            \ 'python': [ 'black', 'autopep8', 'reorder-python-imports', 'remove_trailing_lines', 'trim_whitespace'],
            \ 'markdown': s:ale_pretty_trim_fixer,
            \ 'yaml': ['prettier', 'remove_trailing_lines'],
            \ 'css':  s:ale_pretty_trim_fixer,
            \ 'javascript': s:ale_pretty_trim_fixer,
            \}

" Language specific options
let g:ale_python_flake8_options = '--max-line-length 88'
let g:ale_go_golangci_lint_options = ''
let g:ale_go_golangci_lint_package = 1

" Create shortcut for ALEFix
nnoremap <F4> :ALEFix<CR>
