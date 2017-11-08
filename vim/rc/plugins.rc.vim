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
call s:smart_source_rc('plugins/Buffet')
" }} Navigation

" Git {{
call s:smart_source_rc('plugins/fugitive')
call s:smart_source_rc('plugins/gitgutter')
" }} Git

" Searching {{
call s:smart_source_rc('plugins/ctrlp')
call s:smart_source_rc('plugins/fzf')
" call s:smart_source_rc('plugins/incsearch')
call s:smart_source_rc('plugins/vim-grepper')
" }} Searching

" Autocomplete {{
call s:smart_source_rc('plugins/omnicompletion')
if has('nvim') && has('python3')
    call s:smart_source_rc('plugins/deoplete')
elseif (has('lua') && (v:version > 703 || v:version == 703 && has('patch885')))
    call s:smart_source_rc('plugins/neocomplete')
else
    call s:smart_source_rc('plugins/neocomplcache')
end
" }} Autocomplete

" Programming {{
Plug 'tpope/vim-surround'
call s:smart_source_rc('plugins/tagbar')
call s:smart_source_rc('plugins/tcomment_vim')
if (v:version > 703)
    Plug 'ludovicchabant/vim-gutentags' " Auto generate tags files
end
if has('nvim')
    Plug 'kassio/neoterm'
    command! Tig :T tig<CR>
    command! Tox :T tox<CR>
endif
if (has('nvim') || v:version >= 800)
    call s:smart_source_rc('plugins/neomake')
else
    call s:smart_source_rc('plugins/vim-dispatch')
    call s:smart_source_rc('plugins/syntastic')
endif
" }}

" GUI {{
Plug 'gregsexton/MatchTag'
call s:smart_source_rc('plugins/airline')
call s:smart_source_rc('plugins/dash')
call s:smart_source_rc('plugins/startify')
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
Plug 'vim-scripts/groovy.vim'
Plug 'hsanson/vim-android'
Plug 'pangloss/vim-javascript'
Plug 'pdurbin/vim-tsv'
Plug 'tfnico/vim-gradle'
Plug 'tmux-plugins/vim-tmux'
Plug 'udalov/kotlin-vim'
let g:go_def_mapping_enabled = 0
" }}

" Python {{
call s:smart_source_rc('plugins/python')
" }}

" if (v:version > 703)
"     Plug 'Yggdroot/indentLine', { 'for': ['python', 'yaml'] }
" endif

" Themes {{
Plug 'altercation/vim-colors-solarized'
Plug 'vim-scripts/candy.vim'
Plug 'vim-scripts/eclipse.vim'
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'vim-scripts/nuvola.vim'
Plug 'vim-scripts/summerfruit256.vim'
Plug 'therubymug/vim-pyte'
Plug 'vim-scripts/vividchalk.vim'
Plug 'vim-scripts/wombat256.vim'
" }}
call s:smart_source_rc('plugins/goyo-limelight') " Distraction free editing

" System {{

Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi' " emacs bindinds in insert
call s:smart_source_rc('plugins/vim-togglelist')
" }}
