Blink 'mhinz/vim-grepper'
" Grepper settings and shortcuts
let g:grepper = {
            \ 'quickfix': 1,
            \ 'open': 1,
            \ 'switch': 0,
            \ 'jump': 0,
            \ 'tools': ['git', 'rg', 'ag', 'ack', 'pt', 'grep'],
            \ 'dir': 'repo,cwd'
            \ }
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
nmap <leader>* :Grepper -cword -noprompt<cr>

" Override Todo command to use Grepper
command! Todo :Grepper -noprompt -query TODO

" Make some shortands for various grep programs
if executable('rg')
    command -nargs=+ Rg :GrepperRg <args>
endif
if executable('ag')
    command -nargs=+ Ag :GrepperAg <args>
endif
if executable('ack')
    command -nargs=+ Ack :GrepperAck <args>
endif
