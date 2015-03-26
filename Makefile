.PHONY: clean install

default: install

install:
	./vim-sync-append.sh

clean:
	rm -fr ./vim/plugged
	rm -fr ./vim/autoload/plug.vim
