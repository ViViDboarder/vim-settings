.PHONY: default
default: install

.PHONY: install
install:
	sh ./vim-sync-append.sh

.PHONY: update
update:
	sh ./update-plugins.sh

.PHONY: uninstall
uninstall:
	rm ~/.vimrc
	rm ~/.nvimrc
	rm -fr ~/.vim
	rm -fr ~/.nvim
	rm -fr ~/.config/nvim

.PHONY: clean
clean:
	rm -fr ./vim/plugged
	rm -fr ./vim/autoload/plug.vim
