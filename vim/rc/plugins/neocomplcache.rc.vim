let g:neocomplcache_enable_at_startup = 1
"let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_max_list = 10
"let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_fuzzy_completion = 1
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 0

" omni_patterns
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif

" omni_functions
if !exists('g:neocomplcache_omni_functions')
  let g:neocomplcache_omni_functions = {}
endif

" force_omni_patterns
if !exists('g:neocomplcache_force_omni_patterns')
  let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns['c'] = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns['go'] = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns['python'] =
    \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

" keyword_patterns
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '[0-9a-zA-Z:#_]\+'

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" Skip python because we have jedi-vim
" autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal omnifunc=jedi#completions
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
