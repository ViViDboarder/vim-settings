"Allows filetype detection
filetype on
filetype plugin indent on

" Use more convenient leader
let mapleader="\<Space>"

" Enable mouse input
set mousehide
set mouse=a

" Set backup dirs
set backup
if has('nvim')
    set backupdir=~/.config/nvim/backup
    set directory=~/.config/nvim/tmp
    set viminfo='100,n~/.config/nvim/tmp/viminfo.nvim
else
    set backupdir=~/.vim/backup
    set directory=~/.vim/tmp
    set viminfo='100,n~/.vim/tmp/viminfo.vim
endif

" Filetype extension
au BufRead,BufNewFile *.md set syntax=markdown
