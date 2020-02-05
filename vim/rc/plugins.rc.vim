" Functions {{
function! s:smart_source_rc(name)
    call s:source_rc(a:name . '.rc.vim')
    call s:source_rc(a:name . '.local.rc.vim')
endfunction

function! s:source_rc(path)
  let l:f_path = fnameescape(expand('~/.vim/rc/' . a:path))
  if filereadable(l:f_path)
      execute 'source' . l:f_path
  endif
endfunction
" }} Functions

" Saving and loading specific versions of plugins
call s:source_rc('plug-snapshot')
function! s:save_snapshot()
  let l:f_path = fnameescape(expand('~/.vim/rc/plug-snapshot.rc.vim'))
  execute 'PlugSnapshot!' . l:f_path
endfunction
command! SavePlugSnapshot call s:save_snapshot()


" Navigation {{
Plug 'vim-scripts/file-line'
Plug 'tpope/vim-vinegar'
" }} Navigation

" Git {{
call s:smart_source_rc('plugins/fugitive')
call s:smart_source_rc('plugins/gitgutter')
" }} Git

" Searching {{
if !exists('g:gui_oni')
    if !executable('fzf')
        call s:smart_source_rc('plugins/ctrlp')
    endif
    call s:smart_source_rc('plugins/fzf')
    call s:smart_source_rc('plugins/vim-grepper')
endif
" }} Searching

" Programming {{
Plug 'FooSoft/vim-argwrap'
Plug 'tomtom/tcomment_vim', { 'on': ['TComment', 'TCommentBlock'] }
nnoremap // :TComment<CR>
vnoremap // :TCommentBlock<CR>

" Install ALE
if !g:vim_as_an_ide || g:gui.has_linter_features
    " We'll keep skip adding any of these features
elseif has('nvim') || v:version >= 800
    Plug 'dense-analysis/ale'
    let g:airline#extensions#ale#enabled = 1
    " Speed up first load time
    let g:ale_lint_on_enter = 0

    " NOTE: Some of these are installed when bootstrapping environment, outside of vim setup
    let g:ale_linters = {
        \ 'go': ['gopls', 'golint', 'gometalinter'],
        \ 'python': ['pyls', 'flake8', 'mypy', 'pylint'],
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
        \ 'go': ['gofmt', 'goimports'],
        \ 'json': s:ale_pretty_trim_fixer,
        \ 'rust': ['rustfmt'],
        \ 'markdown': s:ale_pretty_trim_fixer,
        \ 'yaml': ['prettier', 'remove_trailing_lines'],
        \ 'css':  s:ale_pretty_trim_fixer,
        \ 'javascript': s:ale_pretty_trim_fixer,
    \}

    " Create shortcut for ALEFix
    nnoremap <F4> :ALEFix<CR>

    " Set ale completion as omni-func
    set omnifunc=ale#completion#OmniFunc
    " Enable asyncomplete
    Plug 'prabirshrestha/asyncomplete.vim'
    " Add ALE to asyncomplete
    augroup acomp_setup
        au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ale#get_source_options({
            \ 'priority': 10,
        \ }))
    augroup end

    " let g:asyncomplete_auto_popup = 0
    " Make asyncomplete manually triggered
    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~? '\s'
    endfunction

    inoremap <silent><expr> <C-Space>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ asyncomplete#force_refresh()
end

" TODO: Figure out if this is needed or if the ale completions are sufficient
" call s:smart_source_rc('plugins/omnicompletion')

if g:vim_as_an_ide && (v:version > 703) && !g:gui.has_ctags_features
    call s:smart_source_rc('plugins/tagbar')
    Plug 'ludovicchabant/vim-gutentags' " Auto generate tags files
    command! TagsUpdate :GutentagsUpdate
end
" }}

" GUI {{
Plug 'gregsexton/MatchTag'
call s:smart_source_rc('plugins/dash')
if !g:gui.has_buffer_features
    call s:smart_source_rc('plugins/airline')
    call s:smart_source_rc('plugins/startify')
endif
" Plug 'edkolev/tmuxline.vim' " Removed because this can fail on some machines
" let g:tmuxline_powerline_separators = 0

" }} GUI

" Filetypes {{

" Languages with custom configuration
" Custom go
let g:go_def_mapping_enabled = 0
let g:go_version_warning = 0
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
" Custom rust
let g:rustfmt_autosave = 1
Plug 'rust-lang/rust.vim'
" Lots of custom python
call s:smart_source_rc('plugins/python')

" Disable polyglog for languages with more robust plugins
let g:polyglot_disabled = ['python', 'go', 'rust']
Plug 'sheerun/vim-polyglot'

" Languages not in polyglot
Plug 'ViViDboarder/force-vim', { 'for': ['apex', 'visualforce'] }
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'hsanson/vim-android'
Plug 'pdurbin/vim-tsv'
" }}

" Themes {{
Plug 'altercation/vim-colors-solarized'
Plug 'vim-scripts/wombat256.vim'
call s:smart_source_rc('plugins/goyo-limelight') " Distraction free editing
" }}

" System {{
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi' " emacs bindinds in insert
Plug 'godlygeek/tabular' " Tabular spacing

Plug 'milkypostman/vim-togglelist'
nnoremap <silent> <F6> :call ToggleQuickfixList()<CR>
nnoremap <silent> <F7> :call ToggleLocationList()<CR>
" }}
