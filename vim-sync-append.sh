#! /bin/bash

############################
# Vim Settings Setup script by ViViDboarder (Ian)
# http://github.com/ViViDboarder/Vim-Settings
############################

set -ex

# Get current directory for future use in links
VIM_SYNC_DIR=$(dirname "$0")
cd "$VIM_SYNC_DIR"
VIM_SYNC_DIR=$(pwd)


# Vim
[ -d "$HOME/.vim" ] || ln -s "$VIM_SYNC_DIR/vim" "$HOME/.vim"
[ -f "$HOME/.vimrc" ] || ln -s "$VIM_SYNC_DIR/vim/init.vim" "$HOME/.vimrc"

# Neovim
mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}"
[ -f "$XDG_CONFIG_HOME/nvim" ] || ln -s "$VIM_SYNC_DIR/vim" "$XDG_CONFIG_HOME/nvim"

# Install all bundles
echo "Install all bundles"
if hash nvim 2>/dev/null; then
    echo "If using Neovim, install the python modules in your environment"
    nvim +PlugInstall +qall
fi
vim +PlugInstall +qall

vim --version | grep -q '\+lua' || { echo "Warning: Default vim does not include lua"; }
vim --version | grep -q '\+ruby' || { echo "Warning: Default vim does not include ruby."; }
vim --version | grep -q '\+python' || { echo "Warning: Default vim does not include python"; }

echo "All done!"
exit 0
