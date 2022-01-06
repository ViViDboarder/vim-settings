FROM alpine:3.15

RUN apk add \
    bash \
    cargo \
    ctags \
    curl \
    git \
    go \
    luarocks \
    make \
    npm \
    py3-pip \
    python3 \
    ;

# Install neovim from edge repo for latest
RUN apk add neovim --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

# Try to install shellcheck
RUN test "$(uname -m)" = "x86_64" && apk add shellcheck || true
# Try to install rustup
RUN apk add rustup || true

# Install dependencies for python-language-server
RUN apk add gcc g++ python3-dev

# Install neovim python client
RUN pip3 install pynvim

# Create user
RUN adduser -D -h /home/vividboarder -s /bin/bash --ingroup users vividboarder
USER vividboarder

WORKDIR /home/vividboarder
ENV HOME /home/vividboarder
ENV XDG_CONFIG_HOME $HOME/.config
RUN mkdir -p $XDG_CONFIG_HOME

# Configure go path
ENV GOPATH $HOME/go
RUN mkdir -p $GOPATH/bin
ENV PATH $PATH:$GOPATH/bin

# Configure npm path
ENV NPM_PACKAGES $HOME/.npm-packages
RUN npm config set prefix $NPM_PACKAGES
ENV PATH $PATH:$NPM_PACKAGES/bin
ENV PATH $HOME/.local/bin:$PATH

# Install Language servers
COPY --chown=vividboarder:users ./install-language-servers.sh ./
RUN ./install-language-servers.sh
# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $GOPATH/bin v1.43.0

# Add config
COPY --chown=vividboarder:users ./neovim $HOME/.config/nvim

# Sync packer plugins
RUN nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerBootstrap"
# Bootstrap treesitter parsers
RUN nvim --headless -c "lua require('plugins.treesitter').bootstrap()" -c quitall

# Create persistent data dir
RUN mkdir -p /home/vividboarder/.data

# Generate workdir
RUN mkdir /home/vividboarder/data
WORKDIR /home/vividboarder/data

COPY ./docker/docker-entry.sh /docker-entry.sh
ENTRYPOINT /docker-entry.sh
