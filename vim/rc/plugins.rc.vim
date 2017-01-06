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
Plug 'file-line'
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
call s:smart_source_rc('plugins/incsearch')
call s:smart_source_rc('plugins/vim-grepper')
" }} Searching

" Autocomplete {{
call s:smart_source_rc('plugins/omnicompletion')
if (has('lua') && (v:version > 703 || v:version == 703 && has('patch885')))
    call s:smart_source_rc('plugins/neocomplete')
elseif has('nvim') && has('python3')
    call s:smart_source_rc('plugins/deoplete')
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
else
    " Only use if not neovim, on neovim we have Neomake
    call s:smart_source_rc('plugins/syntastic')
endif
" }}

" GUI {{
Plug 'gregsexton/MatchTag'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
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
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'fatih/vim-go'
Plug 'groovy.vim'
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
call s:smart_source_rc('plugins/goyo-limelight') " Distraction free editing

" System {{

" neomake / vim-dispatch {{
if has('nvim')
    call s:smart_source_rc('plugins/neomake')
else
    call s:smart_source_rc('plugins/vim-dispatch')
endif
" }}
"
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rsi' " emacs bindinds in insert
call s:smart_source_rc('plugins/vim-togglelist')
" }}
