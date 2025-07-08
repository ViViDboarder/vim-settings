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

" General
Blink 'gregsexton/MatchTag'
Blink 'tpope/vim-endwise'
Blink 'tpope/vim-eunuch'
Blink 'tpope/vim-repeat'
Blink 'tpope/vim-rsi'
Blink 'tpope/vim-surround'
Blink 'tpope/vim-vinegar'
Blink 'vim-scripts/file-line'
call s:smart_source_rc('plugins/airline')
call s:smart_source_rc('plugins/startify')
call s:smart_source_rc('plugins/goyo-limelight')
Blink 'milkypostman/vim-togglelist'
nnoremap <silent> <F6> :call ToggleQuickfixList()<CR>
nnoremap <silent> <F7> :call ToggleLocationList()<CR>
" Blink 'edkolev/tmuxline.vim' " Removed because this can fail on some machines
" let g:tmuxline_powerline_separators = 0

" Searching
if executable('fzf')
    call s:smart_source_rc('plugins/fzf')
else
    call s:smart_source_rc('plugins/ctrlp')
endif
call s:smart_source_rc('plugins/vim-grepper')

" Git / Version control
call s:smart_source_rc('plugins/fugitive')
call s:smart_source_rc('plugins/gitgutter')

" Programming
Blink 'FooSoft/vim-argwrap'
nnoremap <silent> <leader>a :ArgWrap<CR>
Blink 'tomtom/tcomment_vim'
nnoremap // :TComment<CR>
vnoremap // :TCommentBlock<CR>

" IDE stuff

" Lint and completion
if has('nvim') || v:version >= 800
    " let g:ale_completion_enabled = 1
    call s:smart_source_rc('plugins/ale')
    set omnifunc=ale#completion#OmniFunc

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~? '\s'
    endfunction

    set completeopt+=preview
    imap <silent> <C-Space> <Blink>(ale_complete)
    " inoremap <silent><expr> <C-Space>
    "             \ pumvisible() ? "\<C-n>" :
    "             \ <SID>check_back_space() ? "\<TAB>" :
    "             \ <Blink>(ale_complete)
end

" Programming Tag navigation
call s:smart_source_rc('plugins/tagbar')
Blink 'ludovicchabant/vim-gutentags'
command! TagsUpdate :GutentagsUpdate

" Filetype configuration

" Languages with custom configuration
" Custom Go
let g:go_version_warning = 0  " Since I can't pin to specific tags, hide the warning
Blink 'fatih/vim-go'
" Custom rust
let g:rustfmt_autosave = 1
Blink 'rust-lang/rust.vim'
" Lots of custom python
call s:smart_source_rc('plugins/python')
" Disable polyglot for languages with more robust plugins
let g:polyglot_disabled = ['go', 'rust']
Blink 'sheerun/vim-polyglot'
" Custom rule for ansible playbook detection
augroup ansible_playbook
    au BufRead,BufNewFile */playbooks/*.yml set filetype=yaml.ansible
    au BufRead,BufNewFile */playbooks/*.yaml set filetype=yaml.ansible
augroup end

" Languages not in polyglot
Blink 'ViViDboarder/force-vim'
Blink 'ViViDboarder/vim-forcedotcom'
Blink 'hsanson/vim-android'
Blink 'pdurbin/vim-tsv'

" Themes
Blink 'altercation/vim-colors-solarized'
Blink 'vim-scripts/wombat256.vim'
