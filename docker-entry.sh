#! /bin/bash

set -ex

# VIM_SYNC_DIR=$HOME/vim-settings
# # copy settings to volume
# [ -d "$VIM_SYNC_DIR" ] || cp -r /vim-settings "$VIM_SYNC_DIR"
#
# # Link config files
# [ -d "$XDG_CONFIG_HOME" ] || mkdir -p "$XDG_CONFIG_HOME"
# [ -d "$XDG_CONFIG_HOME/nvim" ] || ln -s "$VIM_SYNC_DIR/vim" "$XDG_CONFIG_HOME/nvim"
# [ -d "$XDG_CONFIG_HOME/nvim/backup" ] || mkdir -p "$XDG_CONFIG_HOME/nvim/backup"
# [ -d "$HOME/.vim" ] || ln -s "$VIM_SYNC_DIR/vim" "$HOME/.vim"
# [ -f "$HOME/.vimrc" ] || ln -s "$VIM_SYNC_DIR/vim/init.vim" "$HOME/.vimrc"

VOLUME_DATA=/home/vividboarder/.data
[ -d "$VOLUME_DATA/nvim/backup" ] || mkdir -p "$VOLUME_DATA/nvim/backup"
[ -d "$XDG_CONFIG_HOME/nvim/backup" ] || ln -s "$VOLUME_DATA/nvim/backup" "$XDG_CONFIG_HOME/nvim/backup"

TS_PARSERS="share/nvim/site/pack/packer/start/nvim-treesitter/parser"
[ -d "$VOLUME_DATA/ts-parsers" ] || mkdir -p "$VOLUME_DATA/ts-parsers"
rm -fr "$HOME/.local/$TS_PARSERS" || ln -s "$VOLUME_DATA/ts-parsers" "$HOME/.local/$TS_PARSERS"

if [ "$1" == "bash" ]; then
    exec "$@"
else
    exec nvim "$@"
fi
