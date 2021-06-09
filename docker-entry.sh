#! /bin/bash

set -e

VIM_SYNC_DIR=$HOME/vim-settings
# copy settings to volume
[ -d "$VIM_SYNC_DIR" ] || cp -r /vim-settings "$VIM_SYNC_DIR"

# Link config files
[ -d "$XDG_CONFIG_HOME" ] || mkdir -p "$XDG_CONFIG_HOME"
[ -d "$XDG_CONFIG_HOME/nvim" ] || ln -s "$VIM_SYNC_DIR/vim" "$XDG_CONFIG_HOME/nvim"
[ -d "$XDG_CONFIG_HOME/nvim/backup" ] || mkdir -p "$XDG_CONFIG_HOME/nvim/backup"
[ -d "$HOME/.vim" ] || ln -s "$VIM_SYNC_DIR/vim" "$HOME/.vim"
[ -f "$HOME/.vimrc" ] || ln -s "$VIM_SYNC_DIR/vim/init.vim" "$HOME/.vimrc"

exec "$@"
