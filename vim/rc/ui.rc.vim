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
        " Prefered default colorscheme
        colorscheme wombat256mod
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " Colorschemes not installed yet
    " This happens when first installing bundles
    colorscheme default
endtry

" Override gui colorscheme
if IsGuiApp()
    colorscheme wombat256mod
endif

" Set Airline theme
if g:colors_name == 'github'
    let g:airline_theme = 'solarized'
endif
" }}

" Set gui fonts {{
if IsGuiApp()
    if IsWindows()
        set guifont=Consolas:h10:b
    elseif IsMac()
        try
            set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h11
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

" Function and command to update colors based on light and dark mode
function! UpdateColors()
    "If not a mac, let's get out of here
    if !IsMac()
        return
    endif
    " Get the light color or default to VIM_COLOR
    let light_color = $VIM_COLOR
    if !empty($VIM_COLOR_LIGHT)
        let light_color = $VIM_COLOR_LIGHT
    endif
    " Get the dark color or default to VIM_COLOR
    let dark_color = $VIM_COLOR
    if !empty($VIM_COLOR_DARK)
        let dark_color = $VIM_COLOR_DARK
    endif
    " Find out if macOS is in dark mode
    let cmd = "osascript
        \ -e 'tell application \"System Events\"'
            \ -e 'tell appearance preferences'
                \ -e 'return dark mode'
            \ -e 'end tell'
        \ -e 'end tell'"
    let dark_mode = substitute(system(cmd), '\n', '', 'g')
    " Set colorscheme and background based on mode
    if dark_mode == 'true'
        execute 'colorscheme ' . dark_color
        set background=dark
    else
        execute 'colorscheme ' . light_color
        set background=light
    endif
endfunction
command! UpdateColors call UpdateColors()
call UpdateColors()
