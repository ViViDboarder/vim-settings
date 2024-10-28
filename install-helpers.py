#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
import sys
from enum import Enum


class Language(Enum):
    ANSIBLE = "ansible"
    BASH = "bash"
    CSS = "css"
    DOCKER = "docker"
    GO = "go"
    HTML = "html"
    JAVASCRIPT = "javascript"
    JSON = "json"
    KOTLIN = "kotlin"
    LUA = "lua"
    NEOVIM = "neovim"
    PYTHON = "python"
    RUST = "rust"
    TERRAFORM = "terraform"
    TEXT = "text"
    VIM = "vim"
    WEB = "web"
    YAML = "yaml"


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def maybe_run(*args: str) -> bool:
    if command_exists(args[0]):
        print("> " + " ".join(args))
        result = subprocess.run(args)
        return result.returncode == 0
    else:
        print(f"ERROR: {args[0]} does not exist. Could not run {' '.join(args)}")
        return False


def should_install_user(command: str) -> bool:
    bin_path = shutil.which(command)
    if not bin_path:
        return True

    if bin_path.startswith(os.path.expanduser("~")):
        return True

    print("WARNING: Already installed by system. Skipping installation of", command)
    return False


def maybe_pip_install(*args: str, library=False) -> bool:
    user_bins = [arg for arg in args if should_install_user(arg)]
    if not user_bins:
        return True

    if not library and command_exists("pipx"):
        return maybe_run("pipx", "install", *user_bins)
    elif command_exists("pip3"):
        return maybe_run(
            "pip3",
            "install",
            "--user",
            "--upgrade",
            "--break-system-packages",
            *user_bins,
        )
    else:
        return maybe_run(
            "pip",
            "install",
            "--user",
            "--upgrade",
            "--break-system-packages",
            *user_bins,
        )


def maybe_npm_install(*args: str) -> bool:
    user_bins = [arg for arg in args if should_install_user(arg)]
    if not user_bins:
        return True

    return maybe_run("npm", "install", "-g", *user_bins)


def install_language_servers(langs: set[Language]):
    if Language.PYTHON in langs:
        maybe_npm_install("pyright")
    if Language.RUST in langs:
        maybe_run(
            "rustup",
            "component",
            "add",
            "rustfmt",
            "rust-analysis",
            "rust-src",
            "clippy",
            "rust-analyzer",
        )
    if Language.GO in langs:
        maybe_run("go", "install", "golang.org/x/tools/gopls@latest")


def install_linters(langs: set[Language]):
    if Language.PYTHON in langs:
        maybe_pip_install("mypy")
    if {Language.CSS, Language.WEB} & langs:
        maybe_npm_install("csslint")
    if {Language.VIM, Language.NEOVIM} in langs:
        maybe_pip_install("vim-vint")
    if Language.YAML in langs:
        maybe_pip_install("yamllint")
    if Language.TEXT in langs:
        maybe_npm_install("alex", "write-good")
        maybe_pip_install("proselint")
    if Language.ANSIBLE in langs:
        maybe_pip_install("ansible-lint")
    if Language.GO in langs:
        maybe_run(
            "release-gitter",
            "--git-url",
            "https://github.com/golangci/golangci-lint",
            "--map-arch",
            "armv7l=armv7",
            "--extract-all",
            "--exec",
            os.path.expanduser("mv /tmp/$(echo {}|sed s/\\.tar\\.gz$//)/golangci-lint ~/bin/"),
            "golangci-lint-{version}-{system}-{arch}.tar.gz",
            "/tmp/",
        )
    if {Language.LUA, Language.NEOVIM} & langs:
        if not maybe_run("lua", "-e", "require('lfs')"):
            maybe_run("luarocks", "--local", "install", "luafilesystem")
        maybe_run("luarocks", "--local", "install", "luacheck", "1.1.0")
    if Language.DOCKER in langs:
        if should_install_user("hadolint"):
            hadolint_arm64 = "arm64"
            if sys.platform == "darwin":
                hadolint_arm64 = "x86_64"
            maybe_run(
                "release-gitter",
                "--git-url",
                "https://github.com/hadolint/hadolint",
                "--map-arch",
                f"aarch64={hadolint_arm64}",
                "--map-arch",
                f"arm64={hadolint_arm64}",
                "--exec",
                os.path.expanduser("mv ~/bin/{} ~/bin/hadolint && chmod +x ~/bin/hadolint"),
                "hadolint-{system}-{arch}",
                os.path.expanduser("~/bin"),
            )
    if Language.TERRAFORM in langs:
        maybe_run(
            "release-gitter",
            "--git-url",
            "https://github.com/aquasecurity/tfsec",
            "--exec",
            os.path.expanduser("mv ~/bin/{} ~/bin/tfsec && chmod +x ~/bin/tfsec"),
            "tfsec-{system}-{arch}",
            os.path.expanduser("~/bin"),
        )
        maybe_run(
            "release-gitter",
            "--git-url",
            "https://github.com/terraform-linters/tflint",
            "--extract-all",
            "--exec",
            os.path.expanduser("chmod +x ~/bin/tflint"),
            "tflint_{system}_{arch}.zip",
            os.path.expanduser("~/bin"),
        )


def install_fixers(langs: set[Language]):
    if {
        Language.PYTHON,
        Language.HTML,
        Language.CSS,
        Language.WEB,
        Language.JSON,
    } & set(langs):
        maybe_npm_install("prettier")
    if Language.PYTHON in langs:
        maybe_pip_install("black", "reorder-python-imports", "isort")
    if Language.RUST in langs:
        maybe_run("rustup", "component", "add", "rustfmt")
    if {Language.LUA, Language.NEOVIM} in langs:
        maybe_run("luarocks", "--local", "install", "stylua", "0.19.1")


def install_debuggers(langs):
    if Language.PYTHON in langs:
        maybe_pip_install("debugpy")
    if Language.GO in langs:
        maybe_run("go", "install", "github.com/go-delve/delve/cmd/dlv@latest")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ignore-missing", action="store_true")
    parser.add_argument("langs", nargs="*", type=Language)
    parser.add_argument("--no-debuggers", action="store_true")
    args = parser.parse_args()

    maybe_pip_install("release-gitter")

    os.environ["PYTHONPATH"] = ""

    if args.ignore_missing:
        os.environ["set"] = "+e"
    else:
        os.environ["set"] = "-e"

    langs = set(args.langs or Language)

    # Handle some aliases
    if Language.NEOVIM in langs:
        langs.add(Language.VIM)
        langs.add(Language.LUA)
    if Language.WEB in langs:
        langs.add(Language.CSS)
        langs.add(Language.JAVASCRIPT)
        langs.add(Language.HTML)

    install_language_servers(langs)
    install_linters(langs)
    install_fixers(langs)

    if not args.no_debuggers:
        install_debuggers(langs)

    print("DONE")


if __name__ == "__main__":
    main()
