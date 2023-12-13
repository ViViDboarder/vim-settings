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
            ;;
    esac
    shift
done

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
function command_exists() {
    command -v "$1" > /dev/null 2>&1;
}

# Runs a command or spits out the output
function maybe_run() {
    if command_exists "$1" ;then
        echo "> $*"
        # shellcheck disable=2048,2086
        eval $*
    else
        echo "ERROR: $1 does not exist. Could not run $*"
    fi
}

# Determine if we should install a command using userspace commands
function should_install_user() {
    if ! command_exists "$1" ;then
        # Install in userspace if command doesn't exist
        return 0
    fi

    local bin_path=""
    bin_path="$(which "$1")"

    # Install in user space if it's already installed in a subdir of the user
    # home dir
    if [[ ${bin_path}/ = ${HOME}/* ]] ;then
        return 0
    else
        echo "WARNING: $1 is already installed by the system."
        return 1
    fi
}

# Runs the "right" pip for installing if there is no global package
function maybe_pip_install() {
    # Filter for user path bins
    local user_bins=()
    for bin in "$@" ;do
        if should_install_user "$bin" ;then
            user_bins+=("$bin")
        fi
    done

    # Short circuit if empty
    if [ ${#user_bins[@]} -eq 0 ] ;then
        return
    fi

    if command_exists pipx ;then
        # Prefer pipx to keep environments isolated
        pipx upgrade "${user_bins[@]}"
    else
        if command_exists pip3 ;then
            # If pip3 is there, use it to ensure we're using python 3
            pip3 install --user --upgrade "${user_bins[@]}"
        else
            # Use pip and hope for the best
            pip install --user --upgrade "${user_bins[@]}"
        fi
    fi
}

# Installs npm packages if there is no global package
function maybe_npm_install() {
    # Filter for user path bins
    local user_bins=()
    for bin in "$@" ;do
        if should_install_user "$bin" ;then
            user_bins+=("$bin")
        fi
    done

    # Short circuit if empty
    if [ ${#user_bins[@]} -eq 0 ] ;then
        return
    fi

    maybe_run npm install -g "${user_bins[@]}"
}

## Language servers
function install_language_servers() {
    echo "### Installing language servers..."

    # bash
    if want_lang bash ;then
        maybe_npm_install bash-language-server
    fi

    # Kotlin
    # https://github.com/fwcd/kotlin-language-server/blob/master/BUILDING.md

    # Python
    if want_lang python ;then
        maybe_npm_install pyright
    fi

    # Rust
    if want_lang rust ;then
        maybe_run rustup component add rustfmt rust-analysis rust-src clippy rust-analyzer
        if ! command_exists rustup ;then
            maybe_run release-gitter --git-url "https://github.com/rust-lang/rust-analyzer" \
                --map-system Windows=pc-windows-msvc --map-system Linux=unknown-linux-gnu --map-system Darwin=apple-darwin \
                --exec "'F={}; gzip -d /tmp/\$F && mv /tmp/\$(echo \$F|sed s/\.gz\$//) ~/bin/rust-analyzer && chmod +x ~/bin/rust-analyzer'" \
                "rust-analyzer-{arch}-{system}.gz" /tmp/
        fi
    fi

    # Go
    if want_lang go ;then
        if should_install_user gopls ;then
            export GO111MODULE=on
            maybe_run go install golang.org/x/tools/gopls@latest
        fi
    fi

    echo ""
}

## Linters
function install_linters() {
    echo "### Installing linters..."

    # Python
    if want_lang python ;then
        maybe_pip_install mypy || echo "WARNING: mypy is py3 only"
    fi

    # CSS
    if want_lang css || want_lang web ;then
        maybe_npm_install csslint
    fi

    # Vim
    if want_lang vim || want_lang neovim ;then
        maybe_pip_install vim-vint
    fi

    # YAML
    if want_lang yaml ;then
        maybe_pip_install yamllint
    fi

    # Text / Markdown
    if want_lang text || want_lang prose ;then
        maybe_npm_install alex write-good
        maybe_pip_install proselint
    fi

    # Makefile
    # maybe_run go install github.com/mrtazz/checkmake@latest

    # Go
    if want_lang go ;then
        maybe_run release-gitter --git-url "https://github.com/golangci/golangci-lint" \
            --map-system Windows=windows --map-system Linux=linux --map-system Darwin=darwin \
            --map-arch x86_64=amd64 --map-arch armv7l=armv7 --map-arch aarch64=arm64 \
            --extract-all --exec "'mv /tmp/\$(echo {}|sed s/\.tar\.gz\$//)/golangci-lint ~/bin/'" \
            "golangci-lint-{version}-{system}-{arch}.tar.gz" /tmp/
    fi

    # Lua
    if want_lang lua || want_lang neovim ;then
        if ! maybe_run lua -e "'require(\"lfs\")'" ;then
            maybe_run luarocks --local install luafilesystem
        fi

        # Version pinned to version in pre-commit so we avoid global check
        maybe_run luarocks --local install luacheck 1.1.0
    fi

    # Docker
    if want_lang docker ;then
        if should_install_user hadolint ;then
            local hadolint_arm64=arm64
            if [ "$(uname -s)" == "Darwin" ] ;then
                hadolint_arm64=x86_64
            fi
            maybe_run release-gitter --git-url "https://github.com/hadolint/hadolint" \
                --map-arch aarch64=$hadolint_arm64 \
                --map-arch arm64=$hadolint_arm64 \
                --exec "'mv ~/bin/{} ~/bin/hadolint && chmod +x ~/bin/hadolint'" \
                "hadolint-{system}-{arch}" ~/bin
        fi
    fi

    # Terraform
    if want_lang terraform ;then
        maybe_run release-gitter --git-url "https://github.com/aquasecurity/tfsec" \
            --map-arch x86_64=amd64 \
            --map-arch aarch64=arm64 \
            --map-system Linux=linux --map-system Darwin=darwin \
            --exec "'mv ~/bin/{} ~/bin/tfsec && chmod +x ~/bin/tfsec'" \
            "tfsec-{system}-{arch}" ~/bin
        maybe_run release-gitter --git-url "https://github.com/terraform-linters/tflint" \
            --map-arch x86_64=amd64 \
            --map-arch aarch64=arm64 \
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
        maybe_npm_install prettier
    fi

    # Python
    if want_lang python ;then
        maybe_pip_install black reorder-python-imports
    fi

    # Rust
    if want_lang rust ;then
        maybe_run rustup component add rustfmt
    fi

    # Lua
    if want_lang lua || want_lang neovim ;then
      # Version pinned to version in pre-commit
      local stylua_version=0.19.1
        if ! release-gitter --git-url "https://github.com/JohnnyMorganz/StyLua" \
            --version "v$stylua_version" \
            --extract-files "stylua" \
            --map-arch arm64=aarch64 \
            --map-system Windows=windows --map-system Linux=linux --map-system Darwin=macos \
            --exec "chmod +x ~/bin/stylua" \
            "stylua-{system}-{arch}.zip" ~/bin ; then
            maybe_run cargo install --version "$stylua_version" stylua
        fi
    fi

    echo ""
}

## Debuggers
function install_debuggers() {
    # Python
    if want_lang python ;then
        maybe_pip_install debugpy
    fi
}

function main() {
    maybe_pip_install release-gitter

    install_language_servers
    install_linters
    install_fixers
    install_debuggers

    echo ""
    echo "DONE"
}

main
