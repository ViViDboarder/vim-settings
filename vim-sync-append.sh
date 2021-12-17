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
[ -e "$XDG_CONFIG_HOME/nvim" ] || ln -s "$VIM_SYNC_DIR/neovim" "$XDG_CONFIG_HOME/nvim"

# Install all bundles
echo "Install all bundles"
if hash nvim 2>/dev/null; then
    echo "If using Neovim, install the python modules in your environment"
    nvim --headless -c PlugInstall -c qall
    nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerBootstrap"
    nvim --headless -c "TSUpdateSync" -c "quitall"
fi
if hash vim 2>/dev/null; then
    vim +PlugInstall +qall
fi


echo "All done!"
exit 0
