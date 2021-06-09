FROM ubuntu:hirsute

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    golang \
    gopls \
    make \
    neovim \
    npm \
    python3-autopep8 \
    python3-flake8 \
    python3-mypy \
    python3-neovim \
    python3-pip \
    python3-proselint \
    python3-pyls-black \
    python3-venv \
    universal-ctags \
    yamllint \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash vividboarder

RUN mkdir -p /go/bin
ENV PATH $PATH:/go/bin
RUN GOPATH=/go go get -u github.com/davidrjenni/reftools/cmd/fillstruct@master \
    && GOPATH=/go go get -u github.com/fatih/gomodifytags@latest \
    && GOPATH=/go go get -u github.com/fatih/motion@latest \
    # && GOPATH=/go go get -u github.com/go-delve/delve/cmd/dlv@latest \
    && GOPATH=/go go get -u github.com/josharian/impl@master \
    && GOPATH=/go go get -u github.com/jstemmer/gotags@master \
    && GOPATH=/go go get -u github.com/kisielk/errcheck@latest \
    && GOPATH=/go go get -u github.com/klauspost/asmfmt/cmd/asmfmt@latest \
    && GOPATH=/go go get -u github.com/koron/iferr@master \
    && GOPATH=/go go get -u github.com/rogpeppe/godef@latest \
    && GOPATH=/go go get -u golang.org/x/lint/golint@master \
    && GOPATH=/go go get -u golang.org/x/tools/cmd/goimports@master \
    && GOPATH=/go go get -u golang.org/x/tools/cmd/gorename@master \
    && GOPATH=/go go get -u golang.org/x/tools/cmd/guru@master \
    && GOPATH=/go go get -u honnef.co/go/tools/cmd/keyify@master \
    && GOPATH=/go go get -u honnef.co/go/tools/cmd/staticcheck@latest \
    && GOPATH=/go go get -u github.com/mrtazz/checkmake \
    && rm -fr /go/src /go/pkg

RUN pip install --no-cache-dir \
    reorder-python-imports \
    vim-vint

RUN npm install -g \
    alex \
    bash-language-server \
    csslint \

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /go/bin v1.35.2
# RUN GOPATH=/go go get -u github.com/golangci/golangci-lint/cmd/golangci-lint@latest

USER vividboarder
VOLUME /home/vividboarder
WORKDIR /home/vividboarder
ENV HOME /home/vividboarder
ENV XDG_CONFIG_HOME $HOME/.config
RUN mkdir -p $XDG_CONFIG_HOME

COPY --chown=vividboarder:vividboarder . /vim-settings

# RUN ln -s $HOME/settings/vim "$XDG_CONFIG_HOME/nvim"
# RUN ln -s $HOME/settings/vim "$HOME/.vim"
# RUN ln -s $HOME/settings/vim/init.vim "$HOME/.vimrc"

ENV NPM_PACKAGES $HOME/.npm-packages
# RUN mkdir $NPM_PACKAGES
RUN npm config set prefix $NPM_PACKAGES
ENV PATH $PATH:$NPM_PACKAGES
ENV PATH $HOME/.local/bin:$PATH
# RUN ./settings/install-language-servers.sh

RUN mkdir data
