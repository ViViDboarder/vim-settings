.PHONY: clean install

default: install

install:
	sh ./vim-sync-append.sh

uninstall:
	rm ~/.vimrc
	rm ~/.nvimrc
	rm -fr ~/.vim
	rm -fr ~/.nvim
	rm -fr ~/.config/nvim

clean:
	rm -fr ./vim/plugged
	rm -fr ./vim/autoload/plug.vim
