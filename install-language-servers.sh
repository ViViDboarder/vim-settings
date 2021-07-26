#! /bin/bash
set -e

# Clear explicit PYTHONPATH since this gets confused between py2 and py3
export PYTHONPATH=""

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
    maybe_run npm install -g bash-language-server

    # Kotlin
    # https://github.com/fwcd/kotlin-language-server/blob/master/BUILDING.md

    # Python
    maybe_run pip install --user --upgrade python-language-server
    maybe_run pip3 install --user --upgrade python-language-server

    # Rust
    maybe_run rustup component add rls rustfmt rust-analysis rust-src

    echo ""
}

## Linters
function install_linters() {
    echo "### Installing linters..."

    # Python
    maybe_run pip install --user --upgrade flake8
    maybe_run pip install --user --upgrade mypy || echo "WARNING: mypy is py3 only"
    maybe_run pip3 install --user --upgrade flake8 mypy

    # CSS
    maybe_run npm install -g csslint

    # Vim
    maybe_run pip install --user --upgrade vim-vint
    maybe_run pip3 install --user --upgrade vim-vint

    # YAML
    maybe_run pip install --user --upgrade yamllint
    maybe_run pip3 install --user --upgrade yamllint

    # Text / Markdown
    maybe_run npm install -g alex
    maybe_run pip install --user --upgrade proselint
    maybe_run pip3 install --user --upgrade proselint

    # Makefile
    maybe_run go get -u github.com/mrtazz/checkmake

    echo ""
}

## Fixers
function install_fixers() {
    echo "### Installing fixers..."
    # CSS/JS/HTML/JSON/YAML/Markdown/and more!
    maybe_run npm install -g prettier

    # Python
    maybe_run pip install --user --upgrade autopep8 reorder-python-imports
    maybe_run pip install --user --upgrade black pyls-black || echo "WARNING: black is py3 only"
    maybe_run pip3 install --user --upgrade black pyls-black autopep8 reorder-python-imports

    # Rust
    maybe_run rustup component add rustfmt

    echo ""
}

function main() {
    install_language_servers
    install_linters
    install_fixers

    echo ""
    echo "DONE"
}

main
