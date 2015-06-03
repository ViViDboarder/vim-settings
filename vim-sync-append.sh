############################
# Vim Settings Setup script by ViViDboarder (Ian)
# http://github.com/ViViDboarder/Vim-Settings
############################
#! /bin/bash

if [ -d ~/.vim  ] || [ -f ~/.vimrc ] || [ -d ~/.nvim  ] || [ -f ~/.nvimrc ]; then
    echo "Vim files already exist. Please backup or remove .(n)vim and .(n)vimrc"
    exit 1
fi

# Try to load .bashrc to load rvm functions
# if [ -f ~/.bashrc ]; then
    # . ~/.bashrc
# fi

# Get current directory for future use in links
VIM_SYNC_DIR=$(dirname $0)
cd $VIM_SYNC_DIR
VIM_SYNC_DIR=$(pwd)


# Vim
ln -s $VIM_SYNC_DIR/vimrc ~/.vimrc
ln -s $VIM_SYNC_DIR/vim ~/.vim

# Neovim
ln -s $VIM_SYNC_DIR/vimrc ~/.nvimrc
ln -s $VIM_SYNC_DIR/vim ~/.nvim

# Install all bundles
echo "Install all bundles"
vim +PlugInstall +qall
if hash nvim 2>/dev/null; then
    nvim +PlugInstall +qall
fi

vim --version | grep -q '\+ruby' || { echo "Warning: Default vim does not include ruby."; }
vim --version | grep -q '\+python' || { echo "Warning: Default vim does not include python"; }

echo "All done!"
exit 0

