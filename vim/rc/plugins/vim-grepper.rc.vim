Plug 'mhinz/vim-grepper'
" Grepper settings and shortcuts
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
    command -nargs=+ Ag :GrepperAg <args>
    set grepprg=ag\ --nogroup\ --nocolor
endif
if executable('ack')
    set grepprg=ack
    command -nargs=+ Ack :GrepperAck <args>
endif
" TODO: Add rg
