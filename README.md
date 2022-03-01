## About

These are my Vim and Neovim settings that I like to keep synced between my computers for convenience. This bootstrap setup will support both Vim and Neovim and uses different plugins, where needed, to bridge gaps in functionality.

I use Neovim day to day, but there are times it is not available, so Vim and older Neovim installs are supported as well.

Vim and Neovim less than 0.5 support is really in maintanence mode now and not heavily maintained.

The bootstrap script included will set the proper symblinks and run package managers to install any plugins.

## Install

    git clone https://github.com/ViViDboarder/vim-settings.git
    cd vim-settings
    make install

You can also remove any installed plugins or uninstall this configuration using either `make clean` or `make uninstall` respectively.

## Project Layout

The `vim` directory here is what gets symblinked to `~/.vim`, and the `neovim` directory gets symblinked to `~/.config/nvim`. Inside, the `init.vim` file will also get symblinked to `~/.vimrc`. The `neovim/init.vim` file will dyanmically load the older non-Lua configs if Lua is not supported. The other included directories are mostly standard vim directories that provide some additional configuration files. The exceptions would be `backup`, which becomes the new default location for storing backup files while editing. The `tmp` directory is for storing session information. The `rc` directory is where all the `vimrc` work gets done.

## Neovim config

This config is in Lua with the philosopy of taking advantage of as much out of the box capaiblities as possible.

## Vim and old Nvim

### The rc Files

The `init.vim` file essentially sets vim up to import the rc files from the `rc` directory. The actual configuration exists almost entirely in the `rc` directory. Each file should be fairly self explanatory.

One problem with syncing rc file between different machines, is that you may have different usages. That is solved by this framework by making use of `local.rc` files. For every `*.rc.vim`, you may provide a `*.local.rc.vim` file which will be loaded after the shared one. Here you can override or add anything to the synced configuration without it causing problems on any other machine.

## Note

I am not the original creators of some of the files included in the vim directory and only vendor them out of convienince. If I am missing any licensing information I'd be happy to attach it.
