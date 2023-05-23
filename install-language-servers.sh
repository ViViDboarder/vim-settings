#! /bin/bash

# Clear explicit PYTHONPATH since this gets confused between py2 and py3
export PYTHONPATH=""

# Languages to install helpers for
declare -a VIM_LANGS

# Read flag for ignore missing and args for languages
while [[ $# -gt 0 ]]; do
    case "$1" in
        --ignore-missing)
            VIM_IGNORE_MISSING=true
            ;;
        *)
            VIM_LANGS+=("$1")
            echo "Read arg $1"
            ;;
    esac
    shift
done

echo "Langs! ${VIM_LANGS[*]}"

function want_lang() {
    if [ "${#VIM_LANGS[@]}" -eq 0 ]; then
        return 0
    fi

    for l in "${VIM_LANGS[@]}"; do
        if [ "$l" == "$1" ]; then
            return 0
        fi
    done

    return 1
}

# Ignore failed installs
if [ -z "$VIM_IGNORE_MISSING" ]; then
    set -e
else
    set +e
fi

# Determines if a command exists or not
function command_exist() {
    command -v "$1" > /dev/null 2>&1;
}

# Runs a command or spits out the output
function maybe_run() {
    if command_exist "$1" ;then
        echo "> $*"
        # shellcheck disable=2048,2086
        eval $*
    else
        echo "ERROR: $1 does not exist. Could not run $*"
    fi
}

## Language servers
function install_language_servers() {
    echo "### Installing language servers..."

    # bash
    if want_lang bash ;then
        maybe_run npm install -g bash-language-server
    fi

    # Kotlin
    # https://github.com/fwcd/kotlin-language-server/blob/master/BUILDING.md

    # Python
    if want_lang python ;then
        maybe_run npm install -g pyright
    fi

    # Rust
    if want_lang rust ;then
        maybe_run rustup component add rls rustfmt rust-analysis rust-src clippy rustfmt
    fi

    # Go
    if want_lang go ;then
        maybe_run env GO111MODULE=on go install golang.org/x/tools/gopls@latest
    fi

    echo ""
}

## Linters
function install_linters() {
    echo "### Installing linters..."

    # Python
    if want_lang python ;then
        maybe_run pip install --user --upgrade flake8
        maybe_run pip install --user --upgrade mypy || echo "WARNING: mypy is py3 only"
        maybe_run pip3 install --user --upgrade flake8 mypy
    fi

    # CSS
    if want_lang css || want_lang web ;then
        maybe_run npm install -g csslint
    fi

    # Vim
    if want_lang vim || want_lang neovim ;then
        maybe_run pip install --user --upgrade vim-vint
        maybe_run pip3 install --user --upgrade vim-vint
    fi

    # YAML
    if want_lang yaml ;then
        maybe_run pip install --user --upgrade yamllint
        maybe_run pip3 install --user --upgrade yamllint
    fi

    # Text / Markdown
    if want_lang text || want_lang prose ;then
        maybe_run npm install -g alex write-good
        maybe_run pip install --user --upgrade proselint
        maybe_run pip3 install --user --upgrade proselint
    fi

    # Makefile
    # maybe_run go install github.com/mrtazz/checkmake@latest

    # Go
    if want_lang go ;then
        maybe_run release-gitter --git-url "https://github.com/golangci/golangci-lint" \
            --map-system Windows=windows --map-system Linux=linux --map-system Darwin=darwin \
            --map-arch x86_64=amd64 --map-arch armv7l=armv7 --map-arch aarch64=arm64 \
            --extract-files golangci-lint \
            --exec "'chmod +x ~/bin/golangci-lint'" \
            "golangci-lint-{version}-{system}-{arch}.tar.gz" ~/bin
    fi

    # Lua
    if want_lang lua || want_lang neovim ;then
        maybe_run luarocks --local install luacheck
    fi

    # Docker
    if want_lang docker ;then
        hadolint_arm64=arm64
        if [ "$(uname -s)" == "Darwin" ]; then
            hadolint_arm64=x86_64
        fi
        maybe_run release-gitter --git-url "https://github.com/hadolint/hadolint" \
            --map-arch arm64=$hadolint_arm64 \
            --exec "'mv ~/bin/{} ~/bin/hadolint && chmod +x ~/bin/hadolint'" \
            "hadolint-{system}-{arch}" ~/bin
    fi

    # Terraform
    if want_lang terraform ;then
        maybe_run release-gitter --git-url "https://github.com/aquasecurity/tfsec" \
            --map-arch x86_64=amd64 \
            --map-system Linux=linux --map-system Darwin=darwin \
            --exec "'mv ~/bin/{} ~/bin/tfsec && chmod +x ~/bin/tfsec'" \
            "tfsec-{system}-{arch}" ~/bin
        maybe_run release-gitter --git-url "https://github.com/terraform-linters/tflint" \
            --map-arch x86_64=amd64 \
            --map-system Linux=linux --map-system Darwin=darwin \
            --extract-all --exec "'chmod +x ~/bin/tflint'" \
            "tflint_{system}_{arch}.zip" ~/bin
    fi

    echo ""
}

## Fixers
function install_fixers() {
    echo "### Installing fixers..."

    # CSS/JS/HTML/JSON/YAML/Markdown/and more!
    if want_lang javascript || want_lang html || want_lang css || want_lang web || want_lang json ;then
        maybe_run npm install -g prettier
    fi

    # Python
    if want_lang python ;then
        maybe_run pip install --user --upgrade "'autopep8<1.7.0'" reorder-python-imports
        maybe_run pip install --user --upgrade autopep8 reorder-python-imports black pyls-black python-lsp-black pyls-isort pyls-mypy || echo "WARNING: black is py3 only"
        maybe_run pip3 install --user --upgrade black pyls-black python-lsp-black pyls-isort pyls-mypy autopep8 reorder-python-imports
    fi

    # Rust
    if want_lang rust ;then
        maybe_run rustup component add rustfmt
    fi

    # Lua
    if want_lang lua || want_lang neovim ;then
        if ! release-gitter --git-url "https://github.com/JohnnyMorganz/StyLua" \
            --map-arch arm64=aarch64 \
            --map-system Windows=windows --map-system Linux=linux --map-system Darwin=macos \
            --extract-all --exec "chmod +x ~/bin/stylua" \
            "stylua-{system}-{arch}.zip" ~/bin ; then
            maybe_run cargo install stylua
        fi
    fi

    echo ""
}

function main() {
    maybe_run pip3 install --user --upgrade release-gitter

    install_language_servers
    install_linters
    install_fixers

    echo ""
    echo "DONE"
}

main
