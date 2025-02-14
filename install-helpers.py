#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
import sys
from enum import Enum


class Language(Enum):
    """Supported languages for helper installation."""
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


# Meta langs are for platforms that consist of multiple languages
META_LANGS: dict[Language, set[Language]] = {
    Language.NEOVIM: {Language.VIM, Language.LUA},
    Language.WEB: {Language.CSS, Language.JAVASCRIPT, Language.HTML},
}


def command_exists(command: str) -> bool:
    """Checks if a command exists in path."""
    return shutil.which(command) is not None


def maybe_run(*args: str) -> bool:
    """Tries to run a command and returns boolean success."""
    if command_exists(args[0]):
        print("> " + " ".join(args))
        result = subprocess.run(args)
        return result.returncode == 0
    else:
        print(f"ERROR: {args[0]} does not exist. Could not run {' '.join(args)}")
        return False


def should_install_user(command: str) -> bool:
    """
    Indicates if a local user version of a command should be installed.

    I don't want to shadow system installed packages, so this function
    checks for an existing installation and checks whether or not it's
    installed only for the current user. If it's not present or within
    the user's home directory, it will indiciate that we should install.
    """
    bin_path = shutil.which(command)
    if not bin_path:
        return True

    if bin_path.startswith(os.path.expanduser("~")):
        return True

    print(f"WARNING: Already installed by system. Skipping installation of {command}")
    return False


def maybe_upgrade_pipx():
    """
    Try to upgrade pipx if it's installed.

    To simplify installation, I use `pipx upgrade --install`, but some
    systems don't have a new enough version of pipx. If pipx is present,
    this will ensure there is an updated version of pipx installed.
    """
    if not command_exists("pipx"):
        return

    if maybe_run("pipx", "upgrade", "--install", "pipx"):
        return
    if maybe_run("pipx", "upgrade", "pipx"):
        return
    if maybe_run("pipx", "install", "pipx"):
        return


def maybe_pip_install(*args: str, library=False) -> bool:
    """
    Install user packages using pip.

    Installation will be skipped if there is a system install, or if none of
    pipx, pip3, or pip are present.
    """
    user_bins = [arg for arg in args if should_install_user(arg)]
    if not user_bins:
        return True

    if not library and command_exists("pipx"):
        return all(
            [maybe_run("pipx", "upgrade", "--install", bin) for bin in user_bins]
        )
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
    """
    Install user packages using npm.

    Installation will be skipped if there is a system install or npm is missing.
    """
    user_bins = [arg for arg in args if should_install_user(arg)]
    if not user_bins:
        return True

    return maybe_run("npm", "install", "-g", *user_bins)


def maybe_go_install(**kwargs: str) -> bool:
    """
    Install user packages using go.

    Installation will be skipped if there is a system install or go is missing.
    """
    urls = [url for name, url in kwargs.items() if should_install_user(name)]
    if not urls:
        return True

    return maybe_run("go", "install", *urls)


def maybe_cargo_install(*args: str) -> bool:
    """
    Install user packages using cargo.

    Installation will be skipped if there is a system install or cargo is missing.
    """
    user_bins = [arg for arg in args if should_install_user(arg)]
    if not user_bins:
        return True

    return maybe_run("cargo", "install", *user_bins)


def maybe_release_gitter(**commands: list[str]) -> bool:
    """
    Try to install user binary using release-gitter.

    Attempt to install binary packages using release-gitter.
    """
    command_names = [key for key in commands.keys() if should_install_user(key)]
    if not command_names:
        return True

    result = True
    for command in command_names:
        args = commands[command]
        result = result and maybe_run("release-gitter", *args)

    return result


def install_language_servers(langs: set[Language]):
    """Install language servers for requested languages."""
    if Language.PYTHON in langs:
        maybe_npm_install("pyright")
    if Language.RUST in langs:
        maybe_run(
            "rustup",
            "component",
            "add",
            "rustfmt",
            "rust-src",
            "clippy",
            "rust-analyzer",
        )
    if Language.GO in langs:
        maybe_go_install(gopls="golang.org/x/tools/gopls@latest")


def install_linters(langs: set[Language]):
    """Install linters for requested languages."""
    if Language.BASH in langs:
        maybe_release_gitter(
            shellcheck=[
                "--git-url",
                "https://github.com/koalaman/shellcheck",
                "--extract-files",
                "shellcheck-{version}/shellcheck",
                "--exec",
                os.path.expanduser(
                    "mv shellcheck-{version}/shellcheck ~/bin/ && chmod +x ~/bin/shellcheck"
                ),
                "--use-temp-dir",
                "shellcheck-{version}.{system}.{arch}.tar.xz",
            ]
        )

    if Language.PYTHON in langs:
        maybe_pip_install("mypy")
    if Language.CSS in langs:
        maybe_npm_install("csslint")
    if Language.VIM in langs:
        maybe_pip_install("vim-vint")
    if Language.YAML in langs:
        maybe_pip_install("yamllint")
    if Language.TEXT in langs:
        maybe_npm_install("alex", "write-good")
        maybe_pip_install("proselint")
    if Language.ANSIBLE in langs:
        maybe_pip_install("ansible-lint")
    if Language.GO in langs:
        # NOTE: Can't use maybe_release_gitter because name has a -
        maybe_run(
            "release-gitter",
            "--git-url",
            "https://github.com/golangci/golangci-lint",
            "--extract-files",
            "golangci-lint-{version}-{system}-{arch}/golangci-lint",
            "--exec",
            os.path.expanduser(
                "mv golangci-lint-{version}-{system}-{arch}/golangci-lint ~/bin/"
            ),
            "--use-temp-dir",
            "golangci-lint-{version}-{system}-{arch}.tar.gz",
        )
    if Language.LUA in langs:
        maybe_release_gitter(
            selene=[
                "--git-url",
                "https://github.com/Kampfkarren/selene",
                "--exec",
                os.path.expanduser("chmod +x ~/bin/selene"),
                "--extract-files",
                "selene",
                "selene-{version}-{system}.zip",
                os.path.expanduser("~/bin"),
            ]
        )
    if Language.DOCKER in langs:
        hadolint_arm64 = "arm64"
        if sys.platform == "darwin":
            hadolint_arm64 = "x86_64"
        maybe_release_gitter(
            hadolint=[
                "--git-url",
                "https://github.com/hadolint/hadolint",
                "--map-arch",
                f"aarch64={hadolint_arm64}",
                "--map-arch",
                f"arm64={hadolint_arm64}",
                "--exec",
                os.path.expanduser(
                    "mv ~/bin/{} ~/bin/hadolint && chmod +x ~/bin/hadolint"
                ),
                "hadolint-{system}-{arch}",
                os.path.expanduser("~/bin"),
            ]
        )
    if Language.TERRAFORM in langs:
        maybe_release_gitter(
            tfsec=[
                "--git-url",
                "https://github.com/aquasecurity/tfsec",
                "--exec",
                os.path.expanduser("mv ~/bin/{} ~/bin/tfsec && chmod +x ~/bin/tfsec"),
                "tfsec-{system}-{arch}",
                os.path.expanduser("~/bin"),
            ],
            tflint=[
                "--git-url",
                "https://github.com/terraform-linters/tflint",
                "--extract-all",
                "--exec",
                os.path.expanduser("chmod +x ~/bin/tflint"),
                "tflint_{system}_{arch}.zip",
                os.path.expanduser("~/bin"),
            ],
        )


def install_fixers(langs: set[Language]):
    """Install fixers for requested languages."""
    if {
        Language.PYTHON,
        Language.HTML,
        Language.CSS,
        Language.WEB,
        Language.JSON,
    } & langs:
        maybe_npm_install("prettier")
    if Language.PYTHON in langs:
        maybe_pip_install("black", "reorder-python-imports", "isort")
    if Language.RUST in langs:
        maybe_run("rustup", "component", "add", "rustfmt")
    if Language.LUA in langs:
        _ = maybe_release_gitter(
            stylua=[
                "--git-url",
                "https://github.com/JohnnyMorganz/StyLua",
                "--extract-files",
                "stylua",
                "--exec",
                os.path.expanduser("chmod +x ~/bin/stylua"),
                "stylua-{system}-{arch}.zip",
                os.path.expanduser("~/bin"),
            ]
        ) or maybe_cargo_install("stylua")

    if Language.GO in langs:
        maybe_go_install(
            gofumpt="mvdan.cc/gofumpt@latest",
            goimports="golang.org/x/tools/cmd/goimports@latest",
        )


def install_debuggers(langs):
    """Install debuggers for the requested languages."""
    if Language.PYTHON in langs:
        maybe_pip_install("debugpy")
    if Language.GO in langs:
        maybe_go_install(dlv="github.com/go-delve/delve/cmd/dlv@latest")


def install_release_gitter():
    """
    Install release-gitter.

    release-gitter is used to install precompiled binaries from GitHub.
    """
    if not maybe_pip_install("release-gitter"):
        # Manual install
        maybe_run(
            "wget",
            "-O",
            os.path.expanduser("~/bin/release-gitter"),
            "https://git.iamthefij.com/iamthefij/release-gitter/raw/branch/main/release_gitter.py",
        )
        maybe_run("chmod", "+x", os.path.expanduser("~/bin/release-gitter"))


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--ignore-missing", action="store_true")
    parser.add_argument("langs", nargs="*", type=Language)
    parser.add_argument("--no-language-servers", action="store_true")
    parser.add_argument("--no-debuggers", action="store_true")
    return parser.parse_args()

def get_langs(langs: list[Language]) -> set[Language]:
    """
    Gets all langs to be installed from user selection.

    Defaults to all languages and handles expanding meta langs.
    """
    lang_set = set(langs or Language)

    # Expand meta languages
    for lang, aliases in META_LANGS.items():
        if lang in lang_set:
            lang_set.update(aliases)

    return lang_set


def main():
    args = parse_args()
    langs = get_langs(args.langs)

    # Try to upgrade pipx
    maybe_upgrade_pipx()

    # Release gitter is required for some tools
    install_release_gitter()

    # Install fzf
    maybe_release_gitter(fzf=[
        "--git-url",
        "https://github.com/junegunn/fzf",
        "--extract-files",
        "fzf",
        "fzf-{version}-{system}_{arch}.tar.gz",
        os.path.expanduser("~/bin/"),
    ])

    # Keep a clean PYTHONPATH
    os.environ["PYTHONPATH"] = ""

    if args.ignore_missing:
        os.environ["set"] = "+e"
    else:
        os.environ["set"] = "-e"

    if not args.no_language_servers:
        install_language_servers(langs)

    install_linters(langs)
    install_fixers(langs)

    if not args.no_debuggers:
        install_debuggers(langs)

    print("DONE")


if __name__ == "__main__":
    main()
