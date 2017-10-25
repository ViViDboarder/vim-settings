#! /bin/bash

echo "Update vim-plug"
vim +PlugUpgrade +qall
vim +PlugClean! +qall

# Install all bundles
echo "Install all bundles"
if hash nvim 2>/dev/null; then
    if hash pip 2>/dev/null; then
        echo 'Installing neovim python module in $HOME'
        pip install --user neovim
    fi
    echo "If using Neovim, install the python modules in your environment"
    nvim +PlugUpdate +PlugInstall +qall
fi
vim +PlugUpdate +PlugInstall +qall

vim --version | grep -q '\+lua' || { echo "Warning: Default vim does not include lua"; }
vim --version | grep -q '\+ruby' || { echo "Warning: Default vim does not include ruby."; }
vim --version | grep -q '\+python' || { echo "Warning: Default vim does not include python"; }

echo "All done!"
exit 0
