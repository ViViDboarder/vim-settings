"Allows filetype detection
filetype on
filetype plugin indent on

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

" Filetype extension overrides
augroup syntax_overrides
    au BufRead,BufNewFile *.md set syntax=markdown
augroup end

" Default to running vim like it's an IDE. To disable on a more restricted
" machine, override this to 0 using an init.local.rc.vim
let g:vim_as_an_ide = 1
