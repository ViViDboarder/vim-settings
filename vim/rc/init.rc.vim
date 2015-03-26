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
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" Filetype extension
au BufRead,BufNewFile *.md set syntax=markdown
