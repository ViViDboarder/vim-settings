PRE_COMMIT_ENV ?= .pre_commit_env
PRE_COMMIT_ENV_BIN ?= $(PRE_COMMIT_ENV)/bin

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

# Installs pre-commit hooks
$(PRE_COMMIT_ENV):
	virtualenv $(PRE_COMMIT_ENV)

$(PRE_COMMIT_ENV_BIN)/pre-commit: $(PRE_COMMIT_ENV)
	$(PRE_COMMIT_ENV_BIN)/pip install pre-commit

.PHONY: install-hooks
install-hooks: $(PRE_COMMIT_ENV_BIN)/pre-commit
	$(PRE_COMMIT_ENV_BIN)/pre-commit install-hooks

# Checks files for encryption
.PHONY: check
check: $(PRE_COMMIT_ENV_BIN)/pre-commit
	$(PRE_COMMIT_ENV_BIN)/pre-commit run --all-files
