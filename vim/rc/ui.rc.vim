" Add encoding for multibyte chars
scriptencoding utf-8

" Display filename at bottom of window
set laststatus=2
"enable line numbers
set number

" Highlights the line the cursor is on
set cursorline
:hi CursorLine   cterm=NONE ctermbg=darkred guibg=darkred guifg=white

" Syntax Hightlighting
syntax on

" Enable search highlighting
set hlsearch

" Set fonts for gui apps {{
if IsGuiApp()
    if IsWindows()
        set guifont=Consolas:h10:b
    endif
endif
" }}

" Color Schemes {{

" Set a default color scheme to use
let g:default_color = 'wombat256mod'

" Gets the value of an env or returns a default
function! s:val_default(env, default)
    return !empty(a:env) ? a:env : a:default
endfunction

" Get color schemes from env variables
let s:env_color = s:val_default($VIM_COLOR, g:default_color)
let s:env_color_light = s:val_default($VIM_COLOR_LIGHT, s:env_color)
let s:env_color_dark = s:val_default($VIM_COLOR_DARK, s:env_color)

" Override colors for gui apps
if IsGuiApp()
    let g:default_color = 'solarized'
    let s:env_color = 'solarized'
    let s:env_color_light = 'solarized'
    let s:env_color_dark = 'solarized'
endif

" Set the colorscheme if it's different than the current
function! s:maybe_set_color(colorscheme_name)
    " On some versions of vim, g:colors_name doesn't seem to exist on start
    if !exists('g:colors_name') || g:colors_name !=# a:colorscheme_name
        execute 'colorscheme ' . a:colorscheme_name
    endif
endfunction

" Function and command to update colors based on light and dark mode
function! UpdateColors()
    " Detect using an env variable
    let cmd = 'echo $IS_DARKMODE'
    " On macOS we can do something a bit more fancy
    if IsMac()
        let cmd = 'defaults read -g AppleInterfaceStyle'
    endif
    let dark_mode = substitute(system(cmd), '\n', '', 'g')
    " Set colorscheme and background based on mode
    if dark_mode ==# 'Dark'
        if &background !=# 'dark'
            set background=dark
        endif
        call s:maybe_set_color(s:env_color_dark)
    else
        if &background !=# 'light'
            set background=light
        endif
        call s:maybe_set_color(s:env_color_light)
    endif
endfunction
command! UpdateColors call UpdateColors()
nnoremap <leader>cc :UpdateColors<CR>

augroup AutoColors
    autocmd FocusGained * call UpdateColors()
augroup END

try
    execute 'colorscheme ' . s:env_color
    " Disabled because this slows startup
    call UpdateColors()
catch /^Vim\%((\a\+)\)\=:E185/
    " Colorschemes not installed yet
    " This happens when first installing bundles
endtry
" }}

" Set xterm and screen/tmux's title {{
set titlestring=vim\ %{expand(\"%t\")}
if &term =~# '^screen'
    " pretend this is xterm.  it probably is anyway, but if term is left as
    " `screen`, vim doesn't understand ctrl-arrow.
    if &term ==# 'screen-256color'
        set term=xterm-256color
    else
        set term=xterm
    endif

    if exists('+termguicolors')
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        set termguicolors
    endif

    " gotta set these *last*, since `set term` resets everything
    set t_ts=k
    set t_fs=\
    set t_ut=
endif
set notitle
" }}
