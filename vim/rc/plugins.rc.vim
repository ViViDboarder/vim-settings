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
Plug 'sandeepcr529/Buffet.vim', { 'on': 'Bufferlist' }
" Buffet {{
nnoremap <silent> <F2> :Bufferlist<CR>
" }} Buffet
" }} Navigation

" Git {{
Plug 'tpope/vim-fugitive', { 'on': ['Gblame', 'Gdiff', 'Gcommit', 'Gstatus', 'Gwrite'] }
call s:smart_source_rc('plugins/fugitive')
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterSignsToggle'] }
call s:smart_source_rc('plugins/gitgutter')
" }} Git


" Searching {{
Plug 'ctrlpvim/ctrlp.vim'
call s:smart_source_rc('plugins/ctrlp')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
let g:fzf_command_prefix = 'Fzf'
Plug 'mhinz/vim-grepper'
call s:smart_source_rc('plugins/grepper')
" }} Fuzzy Find

" Autocomplete {{
call s:smart_source_rc('plugins/omnicompletion')
if (has('lua') && (v:version > 703 || v:version == 703 && has('patch885')))
    Plug 'Shougo/neocomplete.vim'
    call s:smart_source_rc('plugins/neocomplete')
elseif has('nvim') && has('python3')
    Plug 'Shougo/deoplete.nvim'
    Plug 'Shougo/neoinclude.vim'
    Plug 'Shougo/neco-syntax'
    Plug 'zchee/deoplete-jedi'
    Plug 'zchee/deoplete-go'
    call s:smart_source_rc('plugins/deoplete')
    " Remember :UpdateRemotePlugins
else
    Plug 'Shougo/neocomplcache.vim'
    call s:smart_source_rc('plugins/neocomplcache')
end
" }} Autocomplete

" Programming {{
if has('nvim')
    Plug 'kassio/neoterm'
endif
Plug 'majutsushi/tagbar'
" tagbar {{
nnoremap <silent> <F8> :TagbarToggle<CR>
let g:tagbar_autofocus = 1 " Autofocus tagbar
" }} tagbar
if (v:version > 703)
    Plug 'ludovicchabant/vim-gutentags' " Auto generate tags files
end
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim' " , { 'on': ['TComment', 'TCommentBlock'] }
" tcomment_vim {{
nnoremap // :TComment<CR>
vnoremap // :TCommentBlock<CR>
" }} tcomment_vim
if !has('nvim')
    " Only use if not neovim, on neovim we have Neomake
    Plug 'scrooloose/syntastic'
    call s:smart_source_rc('plugins/syntastic')
endif
" }}

" GUI {{
Plug 'mhinz/vim-startify'
call s:smart_source_rc('plugins/startify')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Plug 'edkolev/tmuxline.vim' " Removed because this can fail on some machines
" let g:tmuxline_powerline_separators = 0
call s:smart_source_rc('plugins/airline')
" Highlight matching tags
Plug 'gregsexton/MatchTag'
" Integrate with Dash
Plug 'rizzatti/dash.vim'
" dash.vim {{
nmap <silent> <leader>d <Plug>DashSearch
let g:dash_map = {
    \ 'apex' : 'apex',
    \ 'visualforce' : 'vf',
    \ }
" }} dash.vim

" }} GUI

" Filetypes {{
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'avakhov/vim-yaml'
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'groovy.vim'
Plug 'hsanson/vim-android'
Plug 'udalov/kotlin-vim'
Plug 'pangloss/vim-javascript'
Plug 'pdurbin/vim-tsv'
Plug 'tfnico/vim-gradle'
Plug 'tmux-plugins/vim-tmux'
Plug 'fatih/vim-go'
" vim-go {
let g:go_def_mapping_enabled = 0
" }
" }}

" Python {{
call s:smart_source_rc('plugins/python')
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
" neomake / vim-dispatch {{
if has('nvim')
    Plug 'benekastah/neomake'
    nnoremap <F5> :Neomake<CR>
    let g:neomake_python_enabled_makers = ['flake8']
    command! TagsUpdate NeomakeSh ctags -R .
else
    Plug 'tpope/vim-dispatch'
    nnoremap <F5> :Make<CR>
    command! TagsUpdate Dispatch ctags -R .
endif
" }}
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-repeat'
" emacs bindinds in insert
Plug 'tpope/vim-rsi'
Plug 'milkypostman/vim-togglelist'
" vim-togglelist {{
nnoremap <silent> <F6> :call ToggleQuickfixList()<CR>
nnoremap <silent> <F7> :call ToggleLocationList()<CR>
" }} vim-togglelist
" }}
