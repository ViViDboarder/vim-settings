let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
"let g:neocomplete#enable_smart_case = 1
let g:neocomlete#max_list=10
let g:neocomplete#auto_completion_start_length = 2
let g:neocomplete#manual_completion_start_length = 0

if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'
" let g:neocomplete#keyword_patterns['python'] =
"     \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns['cpp'] = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
let g:neocomplete#force_omni_input_patterns['go'] = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#force_omni_input_patterns['python'] =
    \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" Skip python because we have jedi-vim
" autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal omnifunc=jedi#completions
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
