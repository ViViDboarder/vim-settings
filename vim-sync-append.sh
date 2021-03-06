#! /bin/bash

############################
# Vim Settings Setup script by ViViDboarder (Ian)
# http://github.com/ViViDboarder/Vim-Settings
############################

if [ -d ~/.vim  ] || [ -f ~/.vimrc ] || [ -d ~/.nvim  ] || [ -f ~/.nvimrc ] || [ -d ~/.config/nvim  ]; then
    echo "Vim files already exist. Please backup or remove .(n)vim and .(n)vimrc and .config/nvim"
    exit 1
fi

# Get current directory for future use in links
VIM_SYNC_DIR=$(dirname $0)
cd $VIM_SYNC_DIR
VIM_SYNC_DIR=$(pwd)


# Vim
ln -s $VIM_SYNC_DIR/vim/init.vim ~/.vimrc
ln -s $VIM_SYNC_DIR/vim ~/.vim

# Neovim legacy
ln -s $VIM_SYNC_DIR/vim/init.vim ~/.nvimrc
ln -s $VIM_SYNC_DIR/vim ~/.nvim

# Neovim new
mkdir -p ${XDG_CONFIG_HOME:=$HOME/.config}
ln -s $VIM_SYNC_DIR/vim $XDG_CONFIG_HOME/nvim

# Install all bundles
echo "Install all bundles"
if hash nvim 2>/dev/null; then
    if hash pip 2>/dev/null; then
        echo 'Installing neovim python module in $HOME'
        pip install --user neovim
    fi
    echo "If using Neovim, install the python modules in your environment"
    nvim +PlugInstall +qall
fi
vim +PlugInstall +qall

vim --version | grep -q '\+lua' || { echo "Warning: Default vim does not include lua"; }
vim --version | grep -q '\+ruby' || { echo "Warning: Default vim does not include ruby."; }
vim --version | grep -q '\+python' || { echo "Warning: Default vim does not include python"; }

echo "All done!"
exit 0
