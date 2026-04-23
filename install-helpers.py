#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
import sys
from enum import Enum
from os.path import expanduser
from typing import NamedTuple, cast


class SemVer(NamedTuple):
    """Basic semver parser."""
    major: int
    minor: int
    patch: int

    @classmethod
    def from_str(cls, s: str) -> "SemVer":
        parts = s.split(".")

        major = int(parts[0])
        minor = int(parts[1]) if len(parts) > 1 else 0
        patch = int(parts[2]) if len(parts) > 2 else 0

        return cls(major, minor, patch)


class Language(Enum):
    """Supported languages for helper installation."""

    ACP_CLAUDE_CODE = "claude_code"
    AI = "ai"
    ANSIBLE = "ansible"
    BASH = "bash"
    CSS = "css"
    DOCKER = "docker"
    GO = "go"
    HTML = "html"
    JAVASCRIPT = "javascript"
    JSON = "json"
    KOTLIN = "kotlin"
    LLM = "llm"
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
    Language.AI: {Language.ACP_CLAUDE_CODE},
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


def should_install_user(command: str, upgrade_user: bool = False) -> bool:
    """
    Indicates if a local user version of a command should be installed.

    I don't want to shadow system installed packages, so this function
    checks for an existing installation and checks whether or not it's
    installed only for the current user. If it's not present or within
    the user's home directory, it will indiciate that we should install.
    """
    bin_path = shutil.which(command)
    if not bin_path:
        print(f"INFO: {command} not found. Will install to user.")
        return True

    if not upgrade_user:
        print(f"WARNING: Already installed. Skipping installation of {command}")
        return False

    if bin_path.startswith(expanduser("~")):
        return True

    print(f"WARNING: Already installed by system. Skipping installation of {command} to avoid shadowing")

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


def maybe_pip_install(*packages: str, cmd_packages: dict[str, str]|None = None, library: bool = False, upgrade: bool = False) -> bool:
    """
    Install user packages using pip.

    args can either be package names or a kwargs cmd=package to handle cases where the pip package name differs from the command name.

    Installation will be skipped if there is a system install, or if none of
    pipx, pip3, or pip are present.
    """
    user_packages = [pack for pack in packages if should_install_user(pack, upgrade_user=upgrade)]
    if cmd_packages:
        user_packages.extend([pack for cmd, pack in cmd_packages.items() if should_install_user(cmd, upgrade_user=upgrade)])
    if not user_packages:
        return True

    if not library and command_exists("pipx"):
        return all(
            [maybe_run("pipx", "upgrade", "--install", package) for package in user_packages]
        )
    elif command_exists("pip3"):
        return maybe_run(
            "pip3",
            "install",
            "--user",
            "--upgrade",
            "--break-system-packages",
            *user_packages,
        )
    else:
        return maybe_run(
            "pip",
            "install",
            "--user",
            "--upgrade",
            "--break-system-packages",
            *user_packages,
        )


def maybe_npm_install(*args: str, upgrade: bool = False) -> bool:
    """
    Install user packages using npm.

    Installation will be skipped if there is a system install or npm is missing.
    """
    user_bins = [arg for arg in args if should_install_user(arg, upgrade_user=upgrade)]
    if not user_bins:
        return True

    return maybe_run("npm", "install", "-g", *user_bins)


def maybe_go_install(upgrade: bool = False, **kwargs: str) -> bool:
    """
    Install user packages using go.

    Installation will be skipped if there is a system install or go is missing.
    """
    urls = [url for name, url in kwargs.items() if should_install_user(name, upgrade_user=upgrade)]
    if not urls:
        return True

    return maybe_run("go", "install", *urls)


def maybe_cargo_install(*args: str, upgrade: bool = False) -> bool:
    """
    Install user packages using cargo.

    Installation will be skipped if there is a system install or cargo is missing.
    """
    user_bins = [arg for arg in args if should_install_user(arg, upgrade_user=upgrade)]
    if not user_bins:
        return True

    return maybe_run("cargo", "install", *user_bins)


def maybe_release_gitter(
    commands_arg: dict[str, list[str]] | None = None, _force: bool = False, upgrade: bool = False, **commands_kwargs: list[str]
) -> bool:
    """
    Try to install user binary using release-gitter.

    Attempt to install binary packages using release-gitter.
    """
    if commands_arg is None:
        commands_arg = {}

    commands = commands_arg | commands_kwargs

    command_names = [key for key in commands.keys() if _force or should_install_user(key, upgrade_user=upgrade)]
    if not command_names:
        return True

    result = True
    for command in command_names:
        args = commands[command]
        result = result and maybe_run("release-gitter", *args)

    return result


def install_language_servers(langs: set[Language], upgrade: bool = False):
    """Install language servers for requested languages."""
    if Language.PYTHON in langs:
        _ = maybe_pip_install("basedpyright", upgrade=upgrade)
    if Language.RUST in langs:
        _ = maybe_run(
            "rustup",
            "component",
            "add",
            "rustfmt",
            "rust-src",
            "clippy",
            "rust-analyzer",
        )
    if Language.GO in langs:
        _ = maybe_go_install(gopls="golang.org/x/tools/gopls@latest", upgrade=upgrade)
    if Language.LUA in langs:
        if not command_exists("lua-language-server") or upgrade:
            lua_ls_share = expanduser("~/.local/share/lua-language-server")
            shutil.rmtree(lua_ls_share, ignore_errors=True)
            os.mkdir(lua_ls_share)
            _ = maybe_release_gitter(
                {
                    "lua-language-server": [
                        "--git-url",
                        "https://github.com/LuaLS/lua-language-server",
                        "--version",
                        "3.16.4",  # Pin version due to bug with lazydev.nvim https://github.com/folke/lazydev.nvim/issues/136
                        "--map-arch",
                        "x86_64=x64",
                        "--extract-all",
                        "--exec",
                        expanduser(
                            "echo -e '#!/bin/sh\\n"
                            + 'exec "$HOME/.local/share/lua-language-server/bin/lua-language-server" "$@"\' >'
                            + " ~/.local/bin/lua-language-server &&"
                            + " chmod +x ~/.local/bin/lua-language-server"
                        ),
                        "lua-language-server-{version}-{system}-{arch}.tar.gz",
                        lua_ls_share,
                    ],
                },
                upgrade=upgrade,
            )


def install_linters(langs: set[Language], upgrade: bool = False):
    """Install linters for requested languages."""
    if Language.BASH in langs:
        _ = maybe_release_gitter(
            shellcheck=[
                "--git-url",
                "https://github.com/koalaman/shellcheck",
                "--extract-files",
                "shellcheck-{version}/shellcheck",
                "--exec",
                expanduser(
                    "mv shellcheck-{version}/shellcheck ~/bin/ && chmod +x ~/bin/shellcheck"
                ),
                "--use-temp-dir",
                "shellcheck-{version}.{system}.{arch}.tar.xz",
            ],
            upgrade=upgrade,
        )

    if Language.PYTHON in langs:
        _ = maybe_pip_install("mypy", upgrade=upgrade)
    if Language.CSS in langs:
        _ = maybe_npm_install("csslint", upgrade=upgrade)
    if Language.VIM in langs:
        _ = maybe_pip_install(cmd_packages={"vint": "vim-vint"}, upgrade=upgrade)
    if Language.YAML in langs:
        _ = maybe_pip_install("yamllint", upgrade=upgrade)
    if Language.TEXT in langs:
        _ = maybe_npm_install("alex", "write-good", upgrade=upgrade)
        _ = maybe_pip_install("proselint", upgrade=upgrade)
    if Language.ANSIBLE in langs:
        _ = maybe_pip_install("ansible-lint", upgrade=upgrade)
    if Language.GO in langs:
        _ = maybe_release_gitter(
            {
                "golangci-lint": [
                    "--git-url",
                    "https://github.com/golangci/golangci-lint",
                    "--extract-files",
                    "golangci-lint-{version}-{system}-{arch}/golangci-lint",
                    "--exec",
                    expanduser(
                        "mv golangci-lint-{version}-{system}-{arch}/golangci-lint ~/bin/"
                    ),
                    "--use-temp-dir",
                    "golangci-lint-{version}-{system}-{arch}.tar.gz",
                ]
            },
            upgrade=upgrade,
        )
    if Language.LUA in langs:
        _ = maybe_release_gitter(
            selene=[
                "--git-url",
                "https://github.com/Kampfkarren/selene",
                "--exec",
                expanduser("chmod +x ~/bin/selene"),
                "--extract-files",
                "selene",
                "selene-{version}-{system}.zip",
                expanduser("~/bin"),
            ],
            upgrade=upgrade,
        )
    if Language.DOCKER in langs:
        hadolint_arm64 = "arm64"
        if sys.platform == "darwin":
            hadolint_arm64 = "x86_64"
        _ = maybe_release_gitter(
            hadolint=[
                "--git-url",
                "https://github.com/hadolint/hadolint",
                "--map-arch",
                f"aarch64={hadolint_arm64}",
                "--map-arch",
                f"arm64={hadolint_arm64}",
                "--exec",
                expanduser(
                    "mv ~/bin/{} ~/bin/hadolint && chmod +x ~/bin/hadolint"
                ),
                "hadolint-{system}-{arch}",
                expanduser("~/bin"),
            ],
            upgrade=upgrade,
        )
    if Language.TERRAFORM in langs:
        _ = maybe_release_gitter(
            tflint=[
                "--git-url",
                "https://github.com/terraform-linters/tflint",
                "--extract-all",
                "--exec",
                expanduser("chmod +x ~/bin/tflint"),
                "tflint_{system}_{arch}.zip",
                expanduser("~/bin"),
            ],
            trivy=[
                "--git-url",
                "https://github.com/aquasecurity/trivy",
                "--map-arch",
                "x86=32bit",
                "--map-arch",
                "x86_64=64bit",
                "--extract-files",
                "trivy",
                "--exec",
                expanduser("chmod +x ~/bin/trivy"),
                "trivy_{version}_{system}-{arch}.tar.gz",
                expanduser("~/bin"),

            ],
            upgrade=upgrade,
        )
    if Language.LLM in langs:
        _ = maybe_pip_install("vectorcode", upgrade=upgrade)


def install_fixers(langs: set[Language], upgrade: bool = False):
    """Install fixers for requested languages."""
    if {
        Language.PYTHON,
        Language.HTML,
        Language.CSS,
        Language.WEB,
        Language.JSON,
    } & langs:
        _ = maybe_npm_install("prettier", upgrade=upgrade)
    if Language.PYTHON in langs:
        _ = maybe_pip_install("black", "reorder-python-imports", "isort", upgrade=upgrade)
    if Language.RUST in langs:
        _ = maybe_run("rustup", "component", "add", "rustfmt")
    if Language.LUA in langs:
        _ = maybe_release_gitter(
            stylua=[
                "--git-url",
                "https://github.com/JohnnyMorganz/StyLua",
                "--extract-files",
                "stylua",
                "--exec",
                expanduser("chmod +x ~/bin/stylua"),
                "stylua-{system}-{arch}.zip",
                expanduser("~/bin"),
            ],
            upgrade=upgrade,
        ) or maybe_cargo_install("stylua", upgrade=upgrade)

    if Language.GO in langs:
        _ = maybe_go_install(
            gofumpt="mvdan.cc/gofumpt@latest",
            goimports="golang.org/x/tools/cmd/goimports@latest",
            upgrade=upgrade,
        )


def install_debuggers(langs: set[Language], upgrade: bool = False):
    """Install debuggers for the requested languages."""
    if Language.PYTHON in langs:
        _ = maybe_pip_install("debugpy", upgrade=upgrade)
    if Language.GO in langs:
        _ = maybe_go_install(dlv="github.com/go-delve/delve/cmd/dlv@latest", upgrade=upgrade)


def install_acps(langs: set[Language], upgrade: bool = False):
    """Install ACP clients."""
    if Language.ACP_CLAUDE_CODE in langs:
        _ = maybe_npm_install("@zed-industries/claude-agent-acp", upgrade=upgrade)


def install_release_gitter():
    """
    Install release-gitter.

    release-gitter is used to install precompiled binaries from GitHub.
    """
    if not maybe_pip_install("release-gitter"):
        # Manual install
        _ = maybe_run(
            "wget",
            "-O",
            expanduser("~/bin/release-gitter"),
            "https://git.iamthefij.com/iamthefij/release-gitter/raw/branch/main/release_gitter.py",
        )
        _ = maybe_run("chmod", "+x", expanduser("~/bin/release-gitter"))


def install_fzf():
    """
    Install fzf

    Checks min version and will override system if version is incompatible with fzf-lua
    """
    force_fzf_user = not command_exists("fzf")
    if not force_fzf_user:
        # Check min version
        out = subprocess.check_output(["fzf", "--version"]).decode()
        version_string = out.split(" ")
        current_fzf = SemVer.from_str(version_string[0])
        force_fzf_user = current_fzf < SemVer(0, 39, 0)
        if force_fzf_user:
            print("FZF version is too low, installing user")

    _ = maybe_release_gitter(
        fzf=[
            "--git-url",
            "https://github.com/junegunn/fzf",
            "--extract-files",
            "fzf",
            "fzf-{version}-{system}_{arch}.tar.gz",
            expanduser("~/bin/"),
        ],
        _force=force_fzf_user
    )


def install_treesitter(upgrade: bool = False):
    """
    Install treesitter CLI
    """
    _ = maybe_release_gitter(
        {
            "tree-sitter": [
                "--git-url",
                "https://github.com/tree-sitter/tree-sitter",
                "--extract-files",
                "tree-sitter",
                "--exec",
                expanduser("chmod +x ~/bin/tree-sitter"),
                "tree-sitter-cli-{system}-{arch}.zip",
                expanduser("~/bin/"),
            ],
        },
        upgrade=upgrade,
    )


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser()
    _ = parser.add_argument("--ignore-missing", action="store_true")
    _ = parser.add_argument("langs", nargs="*", choices=[lang.value for lang in Language])
    _ = parser.add_argument("--no-language-servers", action="store_true")
    _ = parser.add_argument("--no-debuggers", action="store_true")
    _ = parser.add_argument("--ai", action="store_true")
    _ = parser.add_argument("--upgrade", action="store_true")
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
    langs = get_langs(cast(list[Language], [Language(lang) for lang in args.langs]))
    upgrade = cast(bool, args.upgrade)

    # Try to upgrade pipx
    maybe_upgrade_pipx()

    # Release gitter is required for some tools
    install_release_gitter()

    # Install fzf because it's used by nvim plugin
    install_fzf()

    # Keep a clean PYTHONPATH
    os.environ["PYTHONPATH"] = ""

    if cast(bool, args.ignore_missing):
        os.environ["set"] = "+e"
    else:
        os.environ["set"] = "-e"

    if not cast(bool, args.no_language_servers):
        install_language_servers(langs, upgrade=upgrade)

    install_linters(langs, upgrade=upgrade)
    install_fixers(langs, upgrade=upgrade)
    install_treesitter(upgrade=upgrade)

    if not cast(bool, args.no_debuggers):
        install_debuggers(langs, upgrade=upgrade)

    if cast(bool, args.ai):
        install_acps(langs, upgrade=upgrade)

    print("DONE")


if __name__ == "__main__":
    main()
