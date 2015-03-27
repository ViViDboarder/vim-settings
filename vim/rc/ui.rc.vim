" Display filename at bottom of window
set ls=2
"enable line numbers
set nu

" Highlights the line the cursor is on
set cursorline
:hi CursorLine   cterm=NONE ctermbg=darkred guibg=darkred guifg=white

" Syntax Hightlighting
syntax on

" Enable search highlighting
set hls


" Color Schemes {{
" Set theme based on $VIM_COLOR variable
try
    if !empty($VIM_COLOR)
        colorscheme $VIM_COLOR
    else
        if has("gui_running")
            colorscheme wombat256mod
        else
            colorscheme vividchalk
        endif
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " Colorschemes not installed yet
    " This happens when first installing bundles
    colorscheme default
endtry

" Set Airline theme
if g:colors_name == 'github'
    let g:airline_theme = 'solarized'
endif
" }}

" Set gui fonts {{
if has("gui_running")
    if has("gui_win32")
        set guifont=Consolas:h10:b
    elseif IsMac() && (has("gui_macvim") || has('nvim'))
        try
            " set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h11
        catch
            " Failed to set font
        endtry
    endif
endif
" }}

" Set xterm and screen/tmux's title {{
set titlestring=vim\ %{expand(\"%t\")}
if &term =~ "^screen"
    " pretend this is xterm.  it probably is anyway, but if term is left as
    " `screen`, vim doesn't understand ctrl-arrow.
    if &term == "screen-256color"
        set term=xterm-256color
    else
        set term=xterm
    endif

    " gotta set these *last*, since `set term` resets everything
    set t_ts=k
    set t_fs=\
    set t_ut=
endif
set notitle
" set title
" }}
