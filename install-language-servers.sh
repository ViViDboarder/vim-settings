#! /bin/bash

## Language servers

# bash
npm install -g bash-language-server

# Kotlin
# https://github.com/fwcd/kotlin-language-server/blob/master/BUILDING.md

# Python
pip install --user python-language-server
pip3 install --user python-language-server

# Rust
rustup component add rls rust-analysis rust-src

## Linters

# Python
pip install flake8 mypy

# CSS
npm install -g csslint

# Vim
pip install --user vim-vint
pip3 install --user vim-vint

# YAML
pip install --user yamllint
pip3 install --user yamllint

# Makefile
# https://github.com/mrtazz/checkmake

## Fixers

# CSS/JS/HTML/JSON/YAML/Markdown/and more!
npm install -g prettier

# Python
pip install --user black autopep8 reorder-python-imports
pip3 install --user black autopep8 reorder-python-imports

# Rust
rustup component add rustfmt
