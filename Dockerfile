FROM alpine:3.15

RUN apk add \
    bash \
    cargo \
    ctags \
    curl \
    git \
    go \
    make \
    neovim \
    npm \
    py3-pip \
    python3 \
    rustup \
    ;

# Try to install shellcheck
RUN test "$(uname -m)" = "x86_64" && apk add shellcheck || true

# Install dependencies for python-language-server
RUN apk add gcc g++ python3-dev

# Install neovim python client
RUN pip3 install pynvim

# Create user
RUN adduser -D -h /home/vividboarder -s /bin/bash vividboarder
USER vividboarder

WORKDIR /home/vividboarder
ENV HOME /home/vividboarder
ENV XDG_CONFIG_HOME $HOME/.config
RUN mkdir -p $XDG_CONFIG_HOME

# Create persistent data dir
RUN mkdir -p /home/vividboarder/.data
VOLUME /home/vividboarder/.data

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
COPY --chown=vividboarder:vividboarder ./install-language-servers.sh ./
RUN ./install-language-servers.sh
# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $GOPATH/bin v1.43.0

# Add config
COPY --chown=vividboarder:vividboarder ./neovim $HOME/.config/nvim

# Sync packer plugins
RUN nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerBootstrap"
# This may not actually do anyting. Haven't figured out how to get compiled ts files into the image
RUN nvim --headless -c "TSUpdateSync" -c "quitall"

# Generate workdir
RUN mkdir /home/vividboarder/data
WORKDIR /home/vividboarder/data

COPY docker-entry.sh /docker-entry.sh
ENTRYPOINT /docker-entry.sh
