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
