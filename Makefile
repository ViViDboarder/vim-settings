.PHONY: all test
PRE_COMMIT_ENV ?= .pre_commit_env
PRE_COMMIT_ENV_BIN ?= $(PRE_COMMIT_ENV)/bin

.PHONY: default
default: check

.PHONY: install
install:
	sh ./vim-sync-append.sh

.PHONY: update
update:
	sh ./update-plugins.sh

.PHONY: install-language-servers
install-language-servers:
	sh ./install-language-servers.sh

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
	$(PRE_COMMIT_ENV_BIN)/pre-commit install --install-hooks

# Checks files for encryption
.PHONY: check
check: $(PRE_COMMIT_ENV_BIN)/pre-commit
	$(PRE_COMMIT_ENV_BIN)/pre-commit run --all-files

# Build Docker images
.PHONY: docker-build
docker-build:
	docker build \
		--tag vividboarder/my-neovim .

# Build Docker images
.PHONY: docker-build-all
docker-build-all:
	docker buildx build \
		--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
		--tag vividboarder/my-neovim .

# Build Docker images
.PHONY: docker-build-push
docker-build-push:
	docker buildx build \
		--push \
		--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
		--tag vividboarder/my-neovim .

.PHONY: docker-clean
docker-clean:
	docker volume rm nvim-$(USER)-home
