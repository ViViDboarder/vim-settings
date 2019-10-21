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

" Enable mouse input
set mousehide
set mouse=a

" Use more convenient leader
let mapleader="\<Space>"

" Remap jk to esc
inoremap jk <esc>
" Easy esc on TEX Yoda
inoremap `` <esc>
vnoremap `` <esc>

" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Bind Make to F5 like other IDEs
nnoremap <F5> :make<CR>

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
cmap Qa<CR> qa<CR>
cmap Qa!<CR> qa!<CR>
cmap QA<CR> qa<CR>
cmap QA!<CR> qa!<CR>
" Stupid semicolon files
cnoremap w; w
cnoremap W; w
cnoremap q; q
cnoremap Q; q
" Avoid accidental Ex-mode
:map Q <Nop>

" Clearing highlighted search
nmap <silent> <leader>/ :set hlsearch! hlsearch?<CR>
" Clear search
nmap <silent> <leader>cs :nohlsearch<CR>

" Code fold
nmap <leader>cf va{<ESC>zf%<ESC>:nohlsearch<CR>

" Paste over
vnoremap pp p
vnoremap po "_dP

" TODO: Versions of this for vim8
if has('nvim')
    " make term exiting easier
    tnoremap <c-W> <c-\><c-n>
    tnoremap <c-W>. <c-W>
    tnoremap <c-\><c-\> <c-\><c-n>

    " Add bash related term commands
    command Bash e term://bash
    command VBash vsp term://bash
    command SBash sp term://bash
    command TBash tabedit term://bash

    " Add fish related term commands
    command Fish e term://fish
    command VFish vsp term://fish
    command SFish sp term://fish
    command TFish tabedit term://fish
endif

" Buffer nav
nmap gb :bn<CR>
nmap gB :bp<CR>

" Command to display TODO tags in project
command Todo grep TODO

" Easy update tags
command TagsUpdate !ctags -R .

" Set grepprg
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')
    set grepprg=ag\ --vimgrep\ --nogroup\ --nocolor
elseif executable('ack')
    set grepprg=ack
endif
