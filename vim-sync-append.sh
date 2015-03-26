############################
# Vim Settings Setup script by ViViDboarder (Ian)
# http://github.com/ViViDboarder/Vim-Settings
############################
#! /bin/bash

if [ -d ~/.vim  ] || [ -f ~/.vimrc ]; then
    echo "Vim files already exist. Please backup or remove .vim and .vimrc"
    exit 1
fi

# Try to load .bashrc to load rvm functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Get current directory for future use in links
VIM_SYNC_DIR=$(dirname $0)
cd $VIM_SYNC_DIR
VIM_SYNC_DIR=$(pwd)


ln -s $VIM_SYNC_DIR/vimrc ~/.vimrc
ln -s $VIM_SYNC_DIR/vim ~/.vim

# # Download and install vim-plug
# curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install all bundles
echo "Install all bundles"
vim +PlugInstall +qall

vim --version | grep -q '\+ruby' || { echo "Warning: Default vim does not include ruby."; }
vim --version | grep -q '\+python' || { echo "Warning: Default vim does not include python"; }

echo "All done!"
exit 0

