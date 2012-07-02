#! /bin/bash

# Get current directory for future use in links
VIM_SYNC_DIR=${PWD}

# Clone vundle
mkdir -p ~/.vim/bundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# Make backup and tmp dirs
mkdir -p ~/.vim/backup
mkdir -p ~/.vim/tmp
mkdir -p ~/.vim/doc

# If a .vimrc_sync doesn't exist, link it
if [[ ! ( -f ~/.vimrc_sync ) ]]; then
	ln -s $VIM_SYNC_DIR/vim/dot_vimrc ~/.vimrc_sync
fi

# If a .vim_drpobox dir doesn't exist, link it
if [[ ! ( -d ~/.vim_sync ) ]]; then
	ln -s $VIM_SYNC_DIR/vim/dot_vim ~/.vim_sync
fi

# if there is no .vimrc file already, make a blank one
if [[ ( ! -f ~/.vimrc ) ]]; then
	touch ~/.vimrc
fi

# if not already sourcing the synced version, source it
if ! ( grep -q 'source .vimrc_sync' ~/.vimrc ); then
	echo '' >> ~/.vimrc
	echo '"import vimrc from synced' >> ~/.vimrc
	echo 'source ~/.vimrc_sync' >> ~/.vimrc
fi

if ! ( grep -q 'set runtimepath+=$HOME/.vim_sync' ~/.vimrc ); then
	echo '' >> ~/.vimrc
	echo '"add vim directory from synced' >> ~/.vimrc
	echo 'set runtimepath+=$HOME/.vim_sync' >> ~/.vimrc
fi

# Install all bundles
vim +BundleInstall! +qall

# Execute vim's update of the helptags
vim +"helptags ~/.vim/doc" +"q"

echo "Should install ctags with sudo apt-get install ctags"

