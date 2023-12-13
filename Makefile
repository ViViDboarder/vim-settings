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

.PHONY: install-coding-helpers
install-coding-helpers:
	sh ./install-coding-helpers.sh

.PHONY: install-language-servers
install-language-servers: install-coding-helpers
	@echo "Using obsolete make target. Change to install-coding-helpers"

.PHONY: uninstall
uninstall:
	rm ~/.vimrc
	rm -fr ~/.vim
	rm -fr ~/.config/nvim

.PHONY: clean
clean:
	# Clean vim-plug
	rm -fr ./vim/plugged ./vim/autoload/plug.vim
	# Clean LspInstall
	rm -fr ~/.local/share/nvim/lsp_servers
	# Clean Packer
	rm -fr ~/.local/share/nvim/site/pack/packer

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
		-f ./docker/Dockerfile \
		--tag vividboarder/my-neovim .

# Build Docker images
.PHONY: docker-build-all
docker-build-all:
	docker buildx build \
		-f ./docker/Dockerfile \
		--platform linux/arm,linux/arm64,linux/amd64 \
		--tag vividboarder/my-neovim .

# Build Docker images
.PHONY: docker-build-push
docker-build-push:
	docker buildx build \
		-f ./docker/Dockerfile \
		--push \
		--platform linux/arm,linux/arm64,linux/amd64 \
		--tag vividboarder/my-neovim .

.PHONY: docker-clean
docker-clean:
	docker volume rm nvim-$(USER)-home
