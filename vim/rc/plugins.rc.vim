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

" Navigation {{
Plug 'file-line'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive' " , { 'on': ['Gblame', 'Gdiff', 'Gcommit', 'Gstatus', 'Gwrite'] }
" {{
    nnoremap <leader>gb :Gblame<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gd :Gdiff<CR>
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gw :Gwrite<CR>
" }}
Plug 'sandeepcr529/Buffet.vim', { 'on': 'Bufferlist' }
" {{
    nnoremap <silent> <F2> :Bufferlist<CR>
" }}
" }}


Plug 'ctrlpvim/ctrlp.vim'
call s:smart_source_rc('plugins/ctrlp')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }

" ag / ack {{
if executable('ag')
    Plug 'rking/ag.vim'
    " {{
        nmap <leader>a :Ag<Space>
        nmap <leader>i* :Ag<Space>-i<Space>'\b<c-r><c-W>\b'<CR>
        nmap <leader>* :Ag<Space>'\b<c-r><c-W>\b'<CR>
        command! Todo Ag! TODO
    " }}
elseif executable('ack')
    Plug 'mileszs/ack.vim'
    " {{
        nmap <leader>a :Ack<Space>
        nmap <leader>i* :Ack<Space>-i<Space>'\b<c-r><c-W>\b'<CR>
        nmap <leader>* :Ack<Space>'\<<c-r><c-W>\>'<CR>
        command! Todo Ack! TODO
    " }}
endif
" }}

" Autocomplete {{
if has('lua')
    Plug 'Shougo/neocomplete.vim'
    call s:smart_source_rc('plugins/neocomps')
else
    Plug 'Shougo/neocomplcache.vim'
    call s:smart_source_rc('plugins/neocomps')
end

" Programming {{
Plug 'majutsushi/tagbar'
" {{
    nnoremap <silent> <F8> :TagbarToggle<CR>
    " Autofocus tagbar
    let g:tagbar_autofocus = 1
" }}
" syntastic {{
if !has('nvim')
    " Only use if not neovim, on neovim we have Neomake
    Plug 'scrooloose/syntastic'
    call s:smart_source_rc('plugins/syntastic')
endif
" }}
Plug 'tomtom/tcomment_vim'
" , { 'on': ['TComment', 'TCommentBlock'] }
" {{
    nnoremap // :TComment<CR>
    vnoremap // :TCommentBlock<CR>
" }}
" }}
Plug 'tpope/vim-surround'

" GUI {{
Plug 'bling/vim-airline'
" {{
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
" }}
Plug 'gregsexton/MatchTag'
Plug 'rizzatti/dash.vim', { 'on': 'Dash'}
" }}

" Filetypes {{
" Plug 'PreserveNoEOL'
" {{
    let g:PreserveNoEOL = 1
" }}
Plug 'ViViDboarder/vim-forcedotcom'
Plug 'avakhov/vim-yaml'
Plug 'dart-lang/dart-vim-plugin'
Plug 'fatih/vim-go'
Plug 'groovy.vim'
Plug 'hsanson/vim-android'
Plug 'pangloss/vim-javascript'
Plug 'pdurbin/vim-tsv'
Plug 'tfnico/vim-gradle'
Plug 'tmux-plugins/vim-tmux'
" }}

" Python {{
Plug 'alfredodeza/coveragepy.vim'
Plug 'alfredodeza/pytest.vim'
Plug 'davidhalter/jedi-vim'
" {{
    let g:jedi#completions_enabled = 0
    let g:jedi#auto_vim_configuration = 0
" }}
Plug 'klen/python-mode'
" {{
    let g:pymode_lint = 1
    let g:pymode_lint_on_write = 0
    let g:pymode_lint_checkers = ['flake8']
    let g:pymode_rope = 0
    let g:pymode_rope_completion = 0
    let g:pymode_rope_complete_on_dot = 0
    let g:pymode_breakpoint = 0
    "}}
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
    " {{
        nmap <leader>nm :Neomake<CR>
        nnoremap <F5> :Neomake<CR>
        let g:neomake_python_makers = ['flake8']

    " }}
else
    Plug 'tpope/vim-dispatch'
    nnoremap <F5> :Make<CR>
    command! TagsUpdate Dispatch ctags -R .
endif
" }}
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'tpope/vim-repeat'
" emacs bindinds in insert
Plug 'tpope/vim-rsi'
Plug 'ViViDboarder/QFixToggle'
" {{
    " Toggle QuickFix window
    nnoremap <silent> <F6> :QFix<CR>
" }}
" }}
