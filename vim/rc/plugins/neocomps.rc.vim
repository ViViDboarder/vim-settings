" Shared plugin configuration for Shougo/neocomplete and Shougo/neocomplcache
if exists('loaded_neocomplete')
    let g:acp_enableAtStartup = 0
    let g:neocomplete#enable_at_startup = 1
    "let g:neocomplete#enable_smart_case = 1
    let g:neocomlete#max_list=10
elseif exists('loaded_neocomplcache')
    let g:neocomplcache_enable_at_startup = 1
    "let g:neocomplcache_enable_smart_case = 1
    let g:neocomplcache_max_list = 10
    "let g:neocomplcache_enable_camel_case_completion = 1
    let g:neocomplcache_enable_fuzzy_completion = 1
    if !exists('g:neocomplcache_force_omni_patterns')
        let g:neocomplcache_force_omni_patterns = {}
    endif
    let g:neocomplcache_force_omni_patterns.python =
        \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
        " alternative pattern: '\h\w*\|[^. \t]\.\w*'
endif

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" Skip python because we have jedi-vim
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal omnifunc=jedi#completions
autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
