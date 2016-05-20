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
Plug 'tpope/vim-fugitive' " , { 'on': ['Gblame', 'Gdiff', 'Gcommit', 'Gstatus', 'Gwrite'] }
" vim-fugitive {{
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gw :Gwrite<CR>
" }} vim-fugitive

Plug 'airblade/vim-gitgutter'
" vim-gitgutter {{
let g:gitgutter_enabled = 1
" Will toggle signs when I want them
let g:gitgutter_signs = 0
" Already using Fugitive, don't need more mappings
let g:gitgutter_map_keys = 0
" Make it more passive
let g:gitgutter_eager = 0
let g:gitgutter_realtime = 0
" Quick leader command to toggle git-gutter
nmap <leader>gg :GitGutterSignsToggle<CR>
" }} vim-gitgutter

" }} Git


" Searching {{
Plug 'ctrlpvim/ctrlp.vim'
call s:smart_source_rc('plugins/ctrlp')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'mhinz/vim-grepper'
" vim-grepper {{
let g:grepper = {
            \ 'dispatch': 1,
            \ 'quickfix': 1,
            \ 'open': 1,
            \ 'switch': 0,
            \ 'jump': 0,
            \ 'tools': ['ag', 'ack', 'git', 'pt', 'grep']
            \ }
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
nmap <leader>* :Grepper -cword -noprompt<cr>
command! Todo Grepper -noprompt -query TODO
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
endif
if executable('ack')
    set grepprg=ack
endif
" }} vim-grepper
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
" vim-airline {{
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
    \ 't'  : 'T',
    \ }
" abbreviate trailing whitespace and mixed indent
let g:airline#extensions#whitespace#trailing_format = 'tw[%s]'
let g:airline#extensions#whitespace#mixed_indent_format = 'i[%s]'
" Vertical separators for all
let g:airline_left_sep=''
let g:airline_left_alt_sep=''
let g:airline_right_sep=''
let g:airline_right_alt_sep=''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" }} vim-airline
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
" Plug 'PreserveNoEOL'
" noeol {{
" let g:PreserveNoEOL = 1
" }} noeol
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'avakhov/vim-yaml'
Plug 'dag/vim-fish'
Plug 'dart-lang/dart-vim-plugin'
Plug 'fatih/vim-go'
Plug 'groovy.vim'
Plug 'hsanson/vim-android'
Plug 'udalov/kotlin-vim'
Plug 'pangloss/vim-javascript'
Plug 'pdurbin/vim-tsv'
Plug 'tfnico/vim-gradle'
Plug 'tmux-plugins/vim-tmux'
" }}

" Python {{
Plug 'alfredodeza/coveragepy.vim'
Plug 'alfredodeza/pytest.vim'
" pytest.vim {{
nmap <silent><leader>ptp <Esc>:Pytest project<CR>
nmap <silent><leader>ptf <Esc>:Pytest file<CR>
nmap <silent><leader>ptm <Esc>:Pytest method<CR>
" }} pytest.vim
Plug 'davidhalter/jedi-vim'
" jedi-vim {{
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 0
" }} jedi-vim
Plug 'klen/python-mode'
" python-mode {{
let g:pymode_breakpoint = 0
let g:pymode_lint = 0
let g:pymode_lint_checkers = ['flake8']
let g:pymode_lint_on_write = 0
let g:pymode_rope = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0
" }} python-mode

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
    " neomake {{
    nmap <leader>nm :Neomake<CR>
    nnoremap <F5> :Neomake<CR>
    let g:neomake_python_enabled_makers = ['flake8']
    " }} neomake
else
    Plug 'tpope/vim-dispatch'
    nnoremap <F5> :Make<CR>
    command! TagsUpdate Dispatch ctags -R .
endif
" }}
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-endwise'
" emacs bindinds in insert
Plug 'tpope/vim-rsi'
Plug 'milkypostman/vim-togglelist'
" vim-togglelist {{
nnoremap <silent> <F6> :call ToggleQuickfixList()<CR>
nnoremap <silent> <F7> :call ToggleLocationList()<CR>
" }} vim-togglelist

" }}
