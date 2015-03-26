" Navigation {{
Plug 'file-line'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive', { 'on': ['Gblame', 'Gdiff', 'Gcommit', 'Gstatus', 'Gwrite'] } " {{
    nnoremap <leader>gb :Gblame<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gd :Gdiff<CR>
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gw :Gwrite<CR>
    " }}
Plug 'sandeepcr529/Buffet.vim', { 'on': 'Bufferlist' }
" {{
    nnoremap <silent> <F2> :Bufferlist<CR>
" }}
Plug 'ctrlpvim/ctrlp.vim'
" {{
    " Ensure max height isn't too large. (for performance)
    let g:ctrlp_max_height = 10
    " Conditional Mappings
    let g:ctrlp_map = '<C-t>'
    " Allow ctrl p to open over the initial nerdtree window
    let g:ctrlp_dont_split = 'netrw'
    " Support tag jumping
    let g:ctrlp_extensions = ['tag', 'buffertag']
    " Support Apex language
    let g:ctrlp_buftag_types = {
            \ 'apex'  : '--language-force=c#',
            \ 'go'    : {
                \ 'bin' : 'gotags',
                \ 'args' : '-sort -silent',
            \}
        \}
    " Leader Commands
    nnoremap <leader>b :CtrlPBuffer<CR>
    nnoremap <leader>t :CtrlPBufTag<CR>
    nnoremap <leader>r :CtrlPTag<CR>
    nnoremap <leader>u :CtrlPCurFile<CR>
    nnoremap <leader>m :CtrlPMRUFiles<CR>

    " Special stuff for The Silver Searcher
    if executable('ag')
        " use ag
        set grepprg=ag\ --nogroup\ --nocolor
        " use ag for CtrlP
        let g:ctrlp_user_command = 'ag %s -l --nocolor --nogroup -g ""'
        " ag is fast enough we don't need cache
        let g:ctrlp_use_caching = 0
    endif
    " }}
" }}

" Search {{
if executable('ag')
    Plug 'rking/ag.vim'
    " {{
        nmap <leader>a :Ag<Space>
        nmap <leader>i* :Ag<Space>-i<Space>'\b<c-r><c-W>\b'<CR>
        nmap <leader>* :Ag<Space>'\b<c-r><c-W>\b'<CR>
    " }}
else
    Plug 'mileszs/ack.vim'
    " {{
        nmap <leader>a :Ack<Space>
        nmap <leader>i* :Ack<Space>-i<Space>'\b<c-r><c-W>\b'<CR>
        nmap <leader>* :Ack<Space>'\<<c-r><c-W>\>'<CR>
    " }}
endif
" }}

" Autocomplete {{
if has('lua')
    Plug 'Shougo/neocomplete.vim'
    " {{
        let g:acp_enableAtStartup = 0
        let g:neocomplete#enable_at_startup = 1
        "let g:neocomplete#enable_smart_case = 1
        let g:neocomlete#max_list=10
    " }}
else
    Plug 'Shougo/neocomplcache.vim'
    " {{
        let g:neocomplcache_enable_at_startup = 1
        "let g:neocomplcache_enable_smart_case = 1
        let g:neocomplcache_max_list = 10
        "let g:neocomplcache_enable_camel_case_completion = 1
        let g:neocomplcache_enable_fuzzy_completion = 1
        if !exists('g:neocomplcache_force_omni_patterns')
            let g:neocomplcache_force_omni_patterns = {}
        endif
        let g:neocomplcache_force_omni_patterns.python =
            \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
            " alternative pattern: '\h\w*\|[^. \t]\.\w*'
    " }}
end
" {{
    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    " Skip python because we have jedi-vim
    "autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType python setlocal omnifunc=jedi#completions
    autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" }}

" Programming {{
Plug 'majutsushi/tagbar' " {{
    nnoremap <silent> <F8> :TagbarToggle<CR>
    " Autofocus tagbar
    let g:tagbar_autofocus = 1
    " }}
Plug 'scrooloose/syntastic' " {{
    let g:syntastic_html_tidy_ignore_errors = [
        \ 'proprietary attribute "ng-show"',
        \ 'proprietary attribute "ng-controller"',
        \ 'proprietary attribute "ng-repeat"',
        \ 'proprietary attribute "ng-app"',
        \ 'proprietary attribute "ng-click"'
        \ ]
    let g:syntastic_python_checkers = ['flake8']
    let g:syntastic_python_flake8_args='--max-line-length=80'
    " let g:syntastic_python_checkers = ['pep8']
    " " let g:syntastic_python_pep8_args='--ignore=E501'
    " " let g:syntastic_python_checkers = ['jshint']
    " " let g:syntastic_javascript_jshint_args='--ignore=E501'
    "
" }}
Plug 'tomtom/tcomment_vim', { 'on': ['TComment', 'TCommentBlock'] } " {{
    nnoremap // :TComment<CR>
    vnoremap // :TCommentBlock<CR>
    " }}
Plug 'benekastah/neomake'
" }}

" GUI {{
Plug 'bling/vim-airline' " {{
    " Use short-form mode text
    let g:airline_mode_map = {
        \ '__' : '-',
        \ 'n'  : 'N',
        \ 'i'  : 'I',
        \ 'R'  : 'R',
        \ 'c'  : 'C',
        \ 'v'  : 'V',
        \ 'V'  : 'V',
        \ '' : 'V',
        \ 's'  : 'S',
        \ 'S'  : 'S',
        \ '' : 'S',
        \ }
    let g:airline#extensions#whitespace#trailing_format = 'tw[%s]'
    let g:airline#extensions#whitespace#mixed_indent_format = 'i[%s]'
    let g:airline_left_sep=''
    let g:airline_left_alt_sep=''
    let g:airline_right_sep=''
    let g:airline_right_alt_sep=''
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#left_sep = ' '
    let g:airline#extensions#tabline#left_alt_sep = '|'
    " }}
Plug 'gregsexton/MatchTag'
Plug 'rizzatti/dash.vim', { 'on': 'Dash'}
" }}

" Filetypes {{
Plug 'PreserveNoEOL' " {{
    let g:PreserveNoEOL = 1
    " }}
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'avakhov/vim-yaml'
Plug 'dart-lang/dart-vim-plugin'
Plug 'fatih/vim-go'
Plug 'groovy.vim'
Plug 'hsanson/vim-android'
Plug 'pangloss/vim-javascript'
Plug 'pdurbin/vim-tsv'
Plug 'tfnico/vim-gradle'
" Python {{
    Plug 'alfredodeza/coveragepy.vim'
    Plug 'alfredodeza/pytest.vim'
    Plug 'davidhalter/jedi-vim'
    " {{
        let g:jedi#completions_enabled = 0
        let g:jedi#auto_vim_configuration = 0
    " }}
    Plug 'klen/python-mode'
    " {{
        let g:pymode_lint = 1
        let g:pymode_lint_on_write = 0
        let g:pymode_lint_checkers = ['flake8']
        let g:pymode_rope = 0
        let g:pymode_rope_completion = 0
        let g:pymode_rope_complete_on_dot = 0
        let g:pymode_breakpoint = 0
        "}}
    " }}
" }}

" Themes {{
Plug 'altercation/vim-colors-solarized'
Plug 'candy.vim'
Plug 'eclipse.vim'
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'nuvola.vim'
Plug 'summerfruit256.vim'
Plug 'therubymug/vim-pyte'
Plug 'vividchalk.vim'
Plug 'wombat256.vim'
" }}

" System {{
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-repeat'
" emacs bindinds in insert
Plug 'tpope/vim-rsi'
Plug 'ViViDboarder/QFixToggle'
" {{
    " Toggle QuickFix window
    nnoremap <silent> <F6> :QFix<CR>
" }}
" }}
