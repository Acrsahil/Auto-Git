# Project Overview

## Project Purpose

`auto-git` is a command-line utility collection designed to simplify GitHub repository management from the terminal. It provides commands to:

- create new GitHub repositories and initialize them locally
- delete repositories from a GitHub account
- list repositories and repository contents
- push local changes using a secure token-based workflow

The project is focused on automating routine GitHub operations with small Python scripts and Bash wrappers.

## Technologies and Frameworks

- Python 3.x
- Bash shell scripting
- Git
- GitHub API via `PyGithub`
- `requests` library for HTTP / OAuth interactions
- shell aliases and manual pages under `man/`

## Workspace Structure

### Root directory

- `README.md` - user-facing documentation describing how the project is intended to work.
- `PROJECT_OVERVIEW.md` - this generated overview file.
- `install.sh` - the main installer script for setting up the project environment, aliases, virtualenv, and man pages.
- `main.py` - shared authentication logic and GitHub device flow helper.
- `gmkdir.py` - creates a GitHub repository and initializes a matching local project folder.
- `deleterepo.py` - deletes one or more GitHub repositories.
- `get_repo.py` - lists GitHub repositories or prints contents of specified repositories.
- `gpush.sh` - commits local changes and pushes to a GitHub repository using token-based HTTPS authentication.
- `getpath.py` - reads a local path from stdin and writes it to `path.txt`.
- `changepath.sh` - stores a local `cd` command to switch into the latest created repo directory.
- `cat.py` - fetches and prints a file from a GitHub repository.
- `exreadme.md` - README template used by `gmkdir.py` when creating a new repository.
- `path.txt` - local base path used by `gmkdir.py` to create new repository folders.
- `man/` - contains manual pages for generated shell commands.
- `1` - an auxiliary script that also demonstrates GitHub authentication and file retrieval, but is not linked from the documented workflow.

### `man/`

- `gls.1` - manual page for listing repos and repo contents.
- `gmkdir.1` - manual page for repository creation.
- `gpush.1` - manual page for pushing changes.
- `grmdir.1` - manual page for deleting repositories.

## Key File Responsibilities

- `install.sh`
  - creates a Python virtual environment at `myenv`
  - installs `PyGithub`
  - creates a secure key directory `.secure_keys`
  - prompts for a GitHub personal access token and saves it securely
  - creates shell aliases for `gmkdir`, `grmdir`, `gls`, and `gpush`
  - installs man pages and adds alias sourcing to shell config files

- `main.py`
  - handles GitHub device flow authentication
  - stores a token in `~/.gmkdir_token`
  - exposes `user_cread()` for the Python utilities to create authenticated GitHub API clients

- `gmkdir.py`
  - reads a target local path from `path.txt`
  - creates a new local directory, templated `README.md`, and `.gitignore`
  - creates the repository on GitHub
  - initializes the local directory as a Git repo and configures the remote origin
  - updates `changepath.sh` to change directory into the new repo

- `get_repo.py`
  - lists all repositories for the authenticated user when called without arguments
  - lists file contents of one or more specified repos when arguments are provided

- `deleterepo.py`
  - deletes one or more specified repositories from the authenticated GitHub account

- `gpush.sh`
  - commits changes locally and pushes them to GitHub via HTTPS with token injection
  - reads a token from `.secure_keys/mykey.txt`
  - assumes remote URL is HTTPS

## How to Run / Build

### 1. Prerequisites

- Python 3 installed (`python3`)
- `git` installed
- `pip` available for Python package installation
- Bash-compatible shell (e.g. `bash`, `zsh`)
- GitHub Personal Access Token with `repo` permissions

### 2. Install the project

From the repository root:

```bash
chmod +x install.sh
./install.sh
```

This script will:

- create `myenv` virtual environment
- install `PyGithub`
- prompt for a GitHub token and store it in `.secure_keys/mykey.txt`
- create or update alias definitions in `alias.sh`
- source the alias file from shell startup scripts if possible
- install man pages for available commands

### 3. Reload your shell / source aliases

After `install.sh` completes, either restart your terminal or source the generated alias file manually:

```bash
source ./alias.sh
```

### 4. Use the command helpers

- Create a repository:

```bash
gmkdir my-new-repo
```

- Delete repositories:

```bash
grmdir repo1 repo2
```

- List repositories:

```bash
gls
```

- List contents of repository(s):

```bash
gls repo1 repo2
```

- Commit and push changes:

```bash
gpush
```

### Notes

- `gmkdir` writes the local base path into `path.txt` via `getpath.py`.
- `main.py` uses OAuth device flow and stores a token in `~/.gmkdir_token`.
- `gpush.sh` uses `.secure_keys/mykey.txt` and a hard-coded username `Acrsahil`, which is an implementation detail of the current repository.
- The `README.md` in this repo references `./install.py`, but the actual installer script present is `install.sh`.

## Primary Dependencies / Technical Requirements

- Python 3.x
- `PyGithub` Python package
- `requests` Python package
- `git` command-line tool
- Bash-compatible shell
- GitHub Personal Access Token with at least `repo` scope
- System package manager available for `install.sh` to auto-install Python packages on Linux (`apt-get`, `dnf`, `yum`, or `pacman`)
- `mandb` and manpaths for installing manual pages

## Getting Started for Contributors

1. Clone the repository locally.
2. Inspect `install.sh` and verify your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`).
3. Run `./install.sh` and provide a GitHub token when prompted.
4. Confirm aliases are available by running `source ./alias.sh` or restarting the shell.
5. Try the main supported workflows:
   - `gmkdir <repo-name>`
   - `gls`
   - `gls <repo-name>`
   - `grmdir <repo-name>`
   - `gpush`
6. Review `main.py`, `gmkdir.py`, `get_repo.py`, and `deleterepo.py` to understand the GitHub API integration.
7. If you make changes, verify behavior against the local `myenv` virtual environment and token storage patterns.

## Important Observations

- Authentication is implemented in two different ways in this repo: `main.py` device flow with `~/.gmkdir_token`, and `install.sh` token storage in `.secure_keys/mykey.txt`.
- The file named `1` appears to be an extra or legacy script for GitHub content retrieval and is not part of the main documented workflow.
- There is a small mismatch between documentation and code: `README.md` mentions `install.py`, while the actual installer is `install.sh`.
