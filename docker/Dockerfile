FROM alpine:3.18

RUN apk add --no-cache \
    bash \
    cargo \
    ctags \
    curl \
    git \
    go \
    luarocks \
    make \
    neovim \
    npm \
    py3-pip \
    py3-pynvim \
    python3 \
    ;

# Install shellcheck from edge repo because aarch64 build does not exist on main
RUN apk add --no-cache shellcheck --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community || true
# Try to install rustup
RUN apk add --no-cache rustup || true

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

# Add personal user bin path
RUN mkdir $HOME/bin
ENV PATH $HOME/bin:$PATH

# Install Language servers
COPY --chown=vividboarder:users ./install-language-servers.sh ./
RUN ./install-language-servers.sh

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
ENTRYPOINT ["/docker-entry.sh"]
