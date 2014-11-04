" Install Vundle Packages
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Plugin 'gmarik/vundle'

" Rest of my bundles

" -- File Nav --
"Plugin 'scrooloose/nerdtree' " File tree navigation
Plugin 'tpope/vim-vinegar' " Simple file navigation
Plugin 'a.vim' " Switch to alternate file
Plugin 'file-line' " Allow opening to a line from file name using :
Plugin 'tpope/vim-fugitive' " Git integration

" -- Fuzzy Finders --
Plugin 'ctrlpvim/ctrlp.vim' " Quick find files in project

" -- Buffer Nav --
Plugin 'sandeepcr529/Buffet.vim' " Quick buffer switching

" -- Nav in file --
Plugin 'majutsushi/tagbar' " Ctags file parsing
Plugin 'scrooloose/syntastic' " Syntax checking
Plugin 'ViViDboarder/QFixToggle' " Easy Toggle of QuickFix window
" TODO: detect if Ag or Ack is installed
Plugin 'rking/ag.vim' " Project searching
"Plugin 'mileszs/ack.vim' " Project Searching

" -- Text Manipulation --
" Easy comments
Plugin 'tomtom/tcomment_vim'
Plugin 'tpope/vim-surround' " Surround for wrapping text
"Plugin 'terryma/vim-multiple-cursors' " Multi cursor

" -- GUI --
Plugin 'gregsexton/MatchTag'
Plugin 'bling/vim-airline' " Custom Status Line
"Powerline Config
"If using a patched font: https://github.com/Lokaltog/vim-powerline/wiki/Patched-fonts
"let g:airline_powerline_fonts = 1

" -- System --
Plugin 'tpope/vim-dispatch' " Allow async make
Plugin 'tpope/vim-rsi' " emacs bindinds in insert
Plugin 'tpope/vim-repeat' " Repeat mapped commands with .
" Needs to be compiled
Plugin 'Shougo/vimproc.vim' " Async for plugins

if has('lua')
    Plugin 'Shougo/neocomplete.vim' " Autocomplete
else
    Plugin 'Shougo/neocomplcache.vim' " Autocomplete
end

" -- Themes --
Plugin 'vividchalk.vim'
Plugin 'wombat256.vim'
Plugin 'nanotech/jellybeans.vim'
Plugin 'candy.vim'
Plugin 'therubymug/vim-pyte'
Plugin 'eclipse.vim'
Plugin 'summerfruit256.vim'
Plugin 'nuvola.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'morhetz/gruvbox'
"Plugin 'BusyBee.vim'
"Plugin 'github.vim'

" -- Filetypes --
Plugin 'ViViDboarder/vim-forcedotcom'
Plugin 'pdurbin/vim-tsv'
Plugin 'pangloss/vim-javascript'
Plugin 'fatih/vim-go'
Plugin 'PreserveNoEOL'
Plugin 'ViViDboarder/vim-android'
Plugin 'groovy.vim'
Plugin 'tfnico/vim-gradle'
Plugin 'dart-lang/dart-vim-plugin'
"Plugin 'ViViDboarder/vim-abuse-the-force'
"Plugin 'chrisbra/csv.vim'

" ***************************
" Built in settings
" ***************************

"Allows filetype detection
filetype on

" Set settings values
filetype plugin indent on

" Allow arrow keys
set nocompatible

" Use more convenient leader
let mapleader=","

" Enable mouse input
set mousehide
set mouse=a

" Tab functionality
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
" Ensure backspace actually works
set backspace=2
"
" allow for cursor beyond last character
set virtualedit=onemore
" lines to scroll when cursor leaves screen
set scrolljump=5
" minimum lines to keep above and below cursor
set scrolloff=3

" Display filename at bottom of window
set ls=2

" Set backup dirs
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

"enable line numbers
set nu

" Highlights the line the cursor is on
set cursorline
:hi CursorLine   cterm=NONE ctermbg=darkred guibg=darkred guifg=white

" Syntax Hightlighting
syntax on

" Enable search highlighting
set hls

" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" ********************************
" GUI SETTINGS
" *****************************

" Set theme based on $VIM_COLOR variable
try
    if !empty($VIM_COLOR)
        colorscheme $VIM_COLOR
    else
        if has("gui_running")
            colorscheme wombat256mod
        else
            colorscheme vividchalk
        endif
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " Colorschemes not installed yet
    " This happens when first installing bundles
    colorscheme default
endtry

" Set Airline theme
if g:colors_name == 'github'
    let g:airline_theme = 'solarized'
endif

" Set gui fonts
if has("gui_running")
    if has("gui_win32")
        set guifont=Consolas:h10:b
    elseif has("gui_macvim")
        try
            set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h11
        catch
            " Failed to set font
        endtry
    endif
endif

" Set xterm title, and inform vim of screen/tmux's syntax for doing the same
set titlestring=vim\ %{expand(\"%t\")}
if &term =~ "^screen"
    " pretend this is xterm.  it probably is anyway, but if term is left as
    " `screen`, vim doesn't understand ctrl-arrow.
    if &term == "screen-256color"
        set term=xterm-256color
    else
        set term=xterm
    endif

    " gotta set these *last*, since `set term` resets everything
    set t_ts=k
    set t_fs=\
    set t_ut=
endif
set title

" ********************************
" SET HOTKEYS
" ********************************

" Remap jk to esc
inoremap jk <esc>

" Bind Make to F5 like other IDEs
nnoremap <F5> :Make!<CR>

" Remap Ctrl+Space for auto Complete
inoremap <C-Space> <C-n>
inoremap <Nul> <C-n>

" Toggle highlighting with \hr (highlight row)
nnoremap <leader>hr :set cursorline!<CR>

" Toggle Line numbers with Ctrl+N double tap
nmap <C-N><C-N> :set invnumber<CR>
nmap <leader>ln :set invnumber<CR>

" Toggle line wrap with Ctrl+L double tap
nmap <C-L><C-L> :set wrap!<CR>
nmap <leader>lw :set wrap!<CR>

" Toggle White Space
nmap <leader>ws :set list!<CR>

" Map Shift+U to redo
nnoremap <S-u> <C-r>

" Stupid shift key fixes
cmap WQ<CR> wq<CR>
cmap Wq<CR> wq<CR>
cmap W<CR> w<CR>
cmap Q<CR> q<CR>
cmap Q!<CR> q!<CR>
" Stupid semicolon files
cnoremap w; w
cnoremap W; w
cnoremap q; q
cnoremap Q; q

" Clearing highlighted search
nmap <silent> <leader>/ :set hlsearch! hlsearch?<CR>
noremap <C-h><C-s> :set hlsearch! hlsearch?<CR>
" Clear search
nmap <silent> <leader>cs :nohlsearch<CR>

" Code fold
nmap <leader>cf va{<ESC>zf%<ESC>:nohlsearch<CR>

" Paste over
vnoremap pp p
vnoremap po "_dP

" ********************************
" PLUGIN SETTINGS
" ********************************

" Airline config
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

" AbuseTheForce
" Set foreground if using tmux, otherwise background
if exists("$TMUX") || ( has("gui_running") && has("gui_macvim") )
    let g:abusetheforce_dispatch_background = 0
else
    let g:abusetheforce_dispatch_background = 1
end

" Buffet shortcut
nnoremap <silent> <F2> :Bufferlist<CR>

" NERDTree
" nnoremap <silent> <F4> :NERDTreeToggle<CR>
"nnoremap <leader>nn :NERDTreeToggle<CR>
"nnoremap <leader>nf :NERDTreeFind<CR>

" TComment
nnoremap // :TComment<CR>
vnoremap // :TCommentBlock<CR>

" PreserveNoEOL
let g:PreserveNoEOL = 1

" CTags List
nnoremap <silent> <F8> :TagbarToggle<CR>
" Autofocus tagbar
let g:tagbar_autofocus = 1

" CtrlP settings
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
endif

" fugitive
" Add some shortcuts for git commands
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gw :Gwrite<CR>

" Toggle QuickFix window
nnoremap <silent> <F6> :QFix<CR>

" neocomplete / neocomplcache
if has('lua')
    let g:acp_enableAtStartup = 0
    let g:neocomplete#enable_at_startup = 1
    "let g:neocomplete#enable_smart_case = 1
    let g:neocomlete#max_list=10
else
    " NeoComplCache
    let g:neocomplcache_enable_at_startup = 1
    "let g:neocomplcache_enable_smart_case = 1
    let g:neocomplcache_max_list = 10
    "let g:neocomplcache_enable_camel_case_completion = 1
    let g:neocomplcache_enable_fuzzy_completion = 1
endif

nmap <leader>a :Ag<Space>
nmap <leader>i* :Ag<Space>-i<Space>'\b<c-r><c-W>\b'<CR>
nmap <leader>* :Ag<Space>'\b<c-r><c-W>\b'<CR>

" Syntastic settings
let g:syntastic_html_tidy_ignore_errors = [
    \ 'proprietary attribute "ng-show"',
    \ 'proprietary attribute "ng-controller"',
    \ 'proprietary attribute "ng-repeat"',
    \ 'proprietary attribute "ng-app"',
    \ 'proprietary attribute "ng-click"'
\ ]

" Command to display TODO tags in project
command Todo Ag! TODO

