import argparse
import re
from collections.abc import Generator, Iterable
from datetime import datetime, tzinfo
from pathlib import Path
from shutil import rmtree
from subprocess import check_call, check_output
from tempfile import mkdtemp
from typing import cast

TRUSTED_HOSTS = {
    "git.iamthefij.com",
}

TRUSTED_OWNERS = {
    "iamthefij",
    "preservim",
    "tpope",
    "vim-scripts",
    "vividboarder",
}

RE_REPO = re.compile(r'"(https?://([^/"]+)/([^/"]+)/([^/"]+))"')
RE_REPO_PARTS = re.compile(r"https?://([^/]+)/([^/]+)/([^/]+)")
RE_TIMEDELTA = re.compile(r"((\d+)y)?((\d+)m)?((\d+)d)?")


class RelativeDate:
    """A class to represent a relative date (e.g., '1y6m' for 1 year and 6 months)."""

    def __init__(self, s: str, past: bool = True) -> None:
        match = RE_TIMEDELTA.fullmatch(s)
        if not match:
            raise ValueError(f"Invalid time delta format: {s}")

        self._years: int = int(match.group(2) or 0) * (-1 if past else 1)
        self._months: int = int(match.group(4) or 0) * (-1 if past else 1)
        self._days: int = int(match.group(6) or 0) * (-1 if past else 1)

    def to_datetime(
        self, tz: tzinfo | None = None, from_dt: datetime | None = None
    ) -> datetime:
        """Convert the relative date to an absolute datetime."""
        if from_dt is None:
            from_dt = datetime.now(tz)

        if not tz:
            from_dt = from_dt.astimezone()

        year = from_dt.year + self._years
        month = from_dt.month + self._months
        day = from_dt.day + self._days

        return datetime(
            year,
            month,
            day,
            hour=from_dt.hour,
            minute=from_dt.minute,
            second=from_dt.second,
            tzinfo=from_dt.tzinfo,
        )


class GitRepo:
    """A simple wrapper for Git repository operations."""

    def __init__(
        self,
        repo_url: str,
        target_dir: Path | None = None,
        parent_dir: Path | None = None,
    ) -> None:
        self.repo_url: str = repo_url

        match = RE_REPO_PARTS.search(self.repo_url)
        if not match:
            raise ValueError(f"Invalid repository URL: {self.repo_url}")

        self._host: str = match.group(1)
        self._owner: str = match.group(2)
        self._project: str = match.group(3)

        if target_dir is not None:
            # If given a target dir, use it directly.
            self.local_dir: Path = target_dir
        else:
            # Otherwise, construct the local dir from the parent dir and project name.
            if parent_dir is None:
                # Default parent dir to the current working directory.
                parent_dir = Path.cwd()

            self.local_dir = parent_dir / self._project

    def host(self) -> str:
        """Return the host of the repository."""
        return self._host

    def owner(self) -> str:
        """Return the owner of the repository."""
        return self._owner

    def project(self) -> str:
        """Return the project name of the repository."""
        return self._project

    def clone(self) -> None:
        """Clone the repository to the local directory."""
        _ = check_call(
            ["git", "clone", "--depth", "1", self.repo_url, str(self.local_dir)],
        )

    def latest_commit_date(self) -> datetime:
        """Return the date of the latest commit in the repository."""
        output = check_output(
            ["git", "-C", str(self.local_dir), "log", "-1", "--format=%cI"],
        )
        commit_date_str = output.decode("utf-8").strip()
        return datetime.fromisoformat(commit_date_str)

    def maybe_stale(self, stale_datetime: datetime) -> bool:
        """Determine if the repository is stale based on the latest commit date."""
        if self.host().lower() in TRUSTED_HOSTS:
            return False
        if self.owner().lower() in TRUSTED_OWNERS:
            return False

        self.clone()
        latest_commit = self.latest_commit_date()

        print(latest_commit)
        print(stale_datetime)

        return latest_commit < stale_datetime


def find_repos_in_spec(lazy_spec: Path) -> Generator[str, None, None]:
    """Yield paths to repositories listed in the lazy spec file."""
    with lazy_spec.open() as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("--"):
                continue

            match = RE_REPO.search(line)
            if match:
                yield match.group(1)


def get_repos(lazy_specs: list[Path]) -> set[str]:
    """Return a set of repository URLs from the given lazy spec files."""
    repos: set[str] = set()

    for spec in lazy_specs:
        if not spec.is_file():
            raise FileNotFoundError(f"File not found: {spec}")

        repos.update(find_repos_in_spec(spec))

    return repos


def fetch_latest_commits(
    repos: Iterable[str],
) -> Generator[tuple[str, datetime], None, None]:
    """Fetch the latest commit date for each repository."""
    repo_dir = Path(mkdtemp(prefix="vim_git_repos_"))
    try:
        for repo_url in repos:
            git_repo = GitRepo(repo_url, parent_dir=repo_dir)
            git_repo.clone()

            latest_commit = git_repo.latest_commit_date()

            yield repo_url, latest_commit
    finally:
        rmtree(repo_dir)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="List repositories from lazy.spec file."
    )

    _ = parser.add_argument(
        "lazy_specs", nargs="+", type=Path, help="Path to any lazy specs"
    )
    _ = parser.add_argument(
        "--stale-after",
        type=RelativeDate,
        default=RelativeDate("1y"),
        help="Consider a repository stale if its latest commit is older than this duration (e.g., '1y6m' for 1 year and 6 months). Default is '1y'.",
    )

    args = parser.parse_args()
    stale_date = cast(RelativeDate, args.stale_after).to_datetime()
    lazy_specs = cast(list[Path], args.lazy_specs)

    # Get repos from spects
    repos = get_repos(lazy_specs)

    # Create temp dir to clone repos into
    repo_dir = Path(mkdtemp(prefix="vim_git_repos_"))

    maybe_stale: list[tuple[str, datetime]] = []

    try:
        for repo in sorted(repos):
            git_repo = GitRepo(repo, parent_dir=repo_dir)
            if git_repo.maybe_stale(stale_date):
                print(f"{repo} - Last commit: {git_repo.latest_commit_date()}")
                maybe_stale.append((repo, git_repo.latest_commit_date()))
    finally:
        rmtree(repo_dir)

    print(f"\nTotal stale repositories: {len(maybe_stale)}")
    for repo, commit_date in maybe_stale:
        print(f"- {repo} (last commit: {commit_date})")

    return 0


if __name__ == "__main__":
    exit(main())
