############################
# Vim Settings Setup script by ViViDboarder (Ian)
# http://github.com/ViViDboarder/Vim-Settings
############################
#! /bin/bash

# Try to load .bashrc to load rvm functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Get current directory for future use in links
VIM_SYNC_DIR=$(dirname $0)
cd $VIM_SYNC_DIR
VIM_SYNC_DIR=$(pwd)

# Verify git is installed (although needed to checkout
command -v git >/dev/null 2>&1 || { 
    echo "Error: git required for install"; 
    exit 1;
}

# Clone vundle if not done already
if [ ! -d ~/.vim/bundle/vundle ]; then
    echo "Installing vundle"
    mkdir -p ~/.vim/bundle
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
fi

# Make backup and tmp dirs
echo "Building temp and backup dirs"
mkdir -p ~/.vim/backup
mkdir -p ~/.vim/tmp
mkdir -p ~/.vim/doc

# If a .vimrc_sync doesn't exist, link it
if [[ ! ( -f ~/.vimrc_sync ) ]]; then
    echo "Linking sync'd vimrc"
	ln -s $VIM_SYNC_DIR/vim/dot_vimrc ~/.vimrc_sync
fi

# If a .vim_drpobox dir doesn't exist, link it
if [[ ! ( -d ~/.vim_sync ) ]]; then
    echo "Linking sync'd vim runtime"
	ln -s $VIM_SYNC_DIR/vim/dot_vim ~/.vim_sync
fi

# if there is no .vimrc file already, make a blank one
if [[ ( ! -f ~/.vimrc ) ]]; then
    echo "No ~/.vimrc found, creating one"
	touch ~/.vimrc
fi

# if not already sourcing the synced version, source it
if ! ( grep -q 'source ~/.vimrc_sync' ~/.vimrc ); then
    echo "Source sync'd vimrc in vimrc"
	echo '' >> ~/.vimrc
	echo '"import vimrc from synced' >> ~/.vimrc
	echo 'source ~/.vimrc_sync' >> ~/.vimrc
fi

if ! ( grep -q 'set runtimepath+=$HOME/.vim_sync' ~/.vimrc ); then
    echo "Add sync'd vim dir to runtime"
	echo '' >> ~/.vimrc
	echo '"add vim directory from synced' >> ~/.vimrc
	echo 'set runtimepath+=$HOME/.vim_sync' >> ~/.vimrc
fi

# Install all bundles
echo "Install all bundles"
vim +BundleInstall! +qall

# Compile CommandT if possible
# See if ruby is installed
if command -v ruby >/dev/null 2>&1; then
    # Make sure GCC is installed
    if command -v gcc >/dev/null 2>&1; then
        # Use system ruby
        command -v rvm >/dev/null 2>&1 && { rvm use system; }
        echo "Compile Command T's C extension"
        cd ~/.vim/bundle/Command-T/ruby/command-t
        ruby extconf.rb
        make
    fi
fi

# Display warning methods related to Command T
vim --version | grep -q '\+ruby' || { echo "Warning: Default vim does not include ruby as needed for Command T"; }
command -v ruby >/dev/null 2>&1 || { echo "Warning: ruby required for Command T"; }
command -v gcc >/dev/null 2>&1 || { echo "Warning: gcc required for Command T"; }

# Execute vim's update of the helptags
vim +"helptags ~/.vim/doc" +"q"

# Warn if ctags does not exist
command -v ctags >/dev/null 2>&1 || { echo "Warning: ctags required for Tag List
--- Debian: apt-get install ctags
--- OSX (MacPorts): port install ctags"; }

echo "All done!"
exit 0

