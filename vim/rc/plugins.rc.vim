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
call s:smart_source_rc('plug-snapshot')
function! s:save_snapshot()
    let l:f_path = fnameescape(expand('~/.vim/rc/plug-snapshot.rc.vim'))
    execute 'PlugSnapshot!' . l:f_path
endfunction
command! SavePlugSnapshot call s:save_snapshot()


" General
Plug 'godlygeek/tabular' " Tabular spacing
Plug 'gregsexton/MatchTag'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi' " emacs bindinds in insert
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'vim-scripts/file-line'
if !g:gui.has_buffer_features
    call s:smart_source_rc('plugins/airline')
    call s:smart_source_rc('plugins/startify')
endif
Plug 'milkypostman/vim-togglelist'
nnoremap <silent> <F6> :call ToggleQuickfixList()<CR>
nnoremap <silent> <F7> :call ToggleLocationList()<CR>
" Plug 'edkolev/tmuxline.vim' " Removed because this can fail on some machines
" let g:tmuxline_powerline_separators = 0
call s:smart_source_rc('plugins/goyo-limelight') " Distraction free editing

" Searching
if !exists('g:gui_oni')
    if !executable('fzf')
        call s:smart_source_rc('plugins/ctrlp')
    endif
    call s:smart_source_rc('plugins/fzf')
    call s:smart_source_rc('plugins/vim-grepper')
endif

" Git / Version control
call s:smart_source_rc('plugins/fugitive')
call s:smart_source_rc('plugins/gitgutter')

" Programming
Plug 'FooSoft/vim-argwrap'
nnoremap <silent> <leader>a :ArgWrap<CR>
Plug 'tomtom/tcomment_vim', { 'on': ['TComment', 'TCommentBlock'] }
nnoremap // :TComment<CR>
vnoremap // :TCommentBlock<CR>
Plug 'rizzatti/dash.vim', { 'on': 'DashSearch' }
nmap <silent> <leader>d <Plug>DashSearch
let g:dash_map = { 'apex' : 'apex', 'visualforce' : 'vf' }

" IDE stuff

" Lint and completion
if (g:vim_as_an_ide && !g:gui.has_linter_features) && (has('nvim') || v:version >= 800)
    call s:smart_source_rc('plugins/ale')

    " Enable autocomplete from ale and asyncomplete
    if !g:gui.has_autocomplete_features
        set omnifunc=ale#completion#OmniFunc
        " Set ale completion as omni-func
        " Enable asyncomplete
        Plug 'prabirshrestha/asyncomplete.vim'
        " Add ALE to asyncomplete
        augroup acomp_setup
            au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ale#get_source_options({
                        \ 'priority': 10,
                        \ }))
        augroup end

        let g:asyncomplete_auto_popup = 0
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
end

" Programming Tag navigation
if g:vim_as_an_ide && (v:version > 703) && !g:gui.has_ctags_features
    call s:smart_source_rc('plugins/tagbar')
    Plug 'ludovicchabant/vim-gutentags' " Auto generate tags files
    command! TagsUpdate :GutentagsUpdate
end

" Filetype configuration

" Languages with custom configuration
" Custom go
let g:go_def_mapping_enabled = 0
let g:go_version_warning = 0
let g:go_fmt_autosave = 0
let g:go_imports_autosave = 0
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
" Custom rust
let g:rustfmt_autosave = 1
Plug 'rust-lang/rust.vim'
" Lots of custom python
call s:smart_source_rc('plugins/python')

" Disable polyglog for languages with more robust plugins
let g:polyglot_disabled = ['go', 'rust']
Plug 'sheerun/vim-polyglot'
" Custom rule for ansible playbook detection
augroup ansible_playbook
    au BufRead,BufNewFile */playbooks/*.yml set filetype=yaml.ansible
    au BufRead,BufNewFile */playbooks/*.yaml set filetype=yaml.ansible
augroup end

" Languages not in polyglot
Plug 'ViViDboarder/force-vim', { 'for': ['apex', 'visualforce'] }
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'hsanson/vim-android'
Plug 'pdurbin/vim-tsv'
" }}

" Themes
Plug 'altercation/vim-colors-solarized'
Plug 'vim-scripts/wombat256.vim'
