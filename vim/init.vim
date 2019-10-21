" A lot of inspiration from Shougo

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if &shell =~# 'fish$'
    set shell=bash
endif

if &compatible
  set nocompatible
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

function! IsWindows()
  return s:is_windows
endfunction

function! IsMac()
  return !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))
endfunction

function! IsGuiApp()
    return has("gui_running") || exists("neovim_dot_app")
                \ || has("gui_win32") || has("gui_macvim")
                \ || has("gui_vimr") || exists('g:gui_oni')
endfunction

" Auto install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall
endif

call s:smart_source_rc('init')
call s:smart_source_rc('input')
call plug#begin()
call s:smart_source_rc('plugins')
call plug#end()
call s:smart_source_rc('ui')
