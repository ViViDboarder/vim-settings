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

" TODO: Maybe replace with coc.nvim. If I'm doing a lot of development, I will
" have latest versions of vim or nvim
" Only need one fallback, maybe neocomplcache
call s:smart_source_rc('plugins/omnicompletion')
if !g:vim_as_an_ide || g:gui.has_autocomplete_features
    " We'll keep Oni's autocomplete with Language Server
elseif (has('nvim') || v:version >= 800) && has('python3')
    call s:smart_source_rc('plugins/deoplete')
else
    call s:smart_source_rc('plugins/neocomplcache')
end

call s:smart_source_rc('plugins/tcomment_vim')

if g:vim_as_an_ide && (v:version > 703) && !g:gui.has_ctags_features
    call s:smart_source_rc('plugins/tagbar')
    Plug 'ludovicchabant/vim-gutentags' " Auto generate tags files
    command! TagsUpdate :GutentagsUpdate<CR>
end

" TODO: Maybe ALE. Similar reason as coc.nvim. Probably only using latest vim
" if developing seriously
if !g:vim_as_an_ide
    " Do nothing
elseif (has('nvim') || v:version >= 800)
    call s:smart_source_rc('plugins/neomake')
else
    call s:smart_source_rc('plugins/syntastic')
endif
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
Plug 'ViViDboarder/force-vim', { 'for': ['apex', 'visualforce'] }
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'avakhov/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'hsanson/vim-android'
Plug 'keith/swift.vim'
Plug 'pangloss/vim-javascript'
Plug 'pdurbin/vim-tsv'
Plug 'tfnico/vim-gradle'
Plug 'tmux-plugins/vim-tmux'
Plug 'udalov/kotlin-vim'
Plug 'vim-scripts/groovy.vim'
Plug 'leafgarland/typescript-vim'
Plug 'rust-lang/rust.vim'
let g:go_def_mapping_enabled = 0
let g:go_version_warning = 0
let g:rustfmt_autosave = 1
" }}

" Python {{
call s:smart_source_rc('plugins/python')
" }}

" Themes {{
Plug 'altercation/vim-colors-solarized'
Plug 'vim-scripts/vividchalk.vim'
Plug 'vim-scripts/wombat256.vim'
call s:smart_source_rc('plugins/goyo-limelight') " Distraction free editing
" }}

" System {{
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi' " emacs bindinds in insert
call s:smart_source_rc('plugins/vim-togglelist')
" }}
