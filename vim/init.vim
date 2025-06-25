" A lot of inspiration from Shougo

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" Don't use fish as the default shell. This makes things weird
if &shell =~# 'fish$'
    set shell=bash
endif

" Don't use sh if we have bash
if &shell =~# '/sh$' || &shell =~# '^sh$' && executable('bash')
  set shell=bash
endif

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

let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_sudo = $SUDO_USER !=# '' && $USER !=# $SUDO_USER
      \ && $HOME !=# expand('~'.$USER)
      \ && $HOME ==# expand('~'.$SUDO_USER)


" IsWindows determines if this instances is running on Windows
function! IsWindows()
  return s:is_windows
endfunction

" IsMac determines if this instance is running on macOS
function! IsMac()
  return !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))
endfunction

" IsGuiApp determines if (n)vim is running in a GUI
function! IsGuiApp()
    return has('gui_running') || exists('neovim_dot_app')
                \ || has('gui_win32') || has('gui_macvim')
                \ || has('gui_vimr') || exists('g:gui_oni')
endfunction

" Auto install vim-blink
let data_dir = expand('~/.vim')
if empty(glob(data_dir . '/autoload/blink.vim'))
    call mkdir(expand(data_dir.'/autoload'),'p')
    silent execute '!curl -fLo ' . data_dir . '/autoload/blink.vim --create-dirs  https://raw.githubusercontent.com/IamTheFij/vim-blink/cmd-array/blink.vim'
    augroup blinkinstall
        autocmd VimEnter * BlinkUpdate
    augroup end
endif
call blink#init()

call s:smart_source_rc('init')
call s:smart_source_rc('input')
call s:smart_source_rc('plugins')
call s:smart_source_rc('ui')
