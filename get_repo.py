import json
import os
import subprocess
import sys
import time

from github.GithubException import GithubException, UnknownObjectException

import main

userdata = main.user_cread()

# -----------------------------
# CONFIG
# -----------------------------
CACHE_FILE = os.path.expanduser("~/.gh_repo_cache.json")
# If things fail, check this log file in your home directory to see the exact error:
DEBUG_LOG_FILE = os.path.expanduser("~/.gh_repo_cache_debug.log")
CACHE_TTL = 60 * 60  # 1 hour

# -----------------------------
# COLORS
# -----------------------------
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"
BLUE = "\033[94m"

reponaming = " Listing contents of   "
countrepolen = " Listing repos of  "
warninglen = " Warning!: Repository not found! "

# -----------------------------
# USER
# -----------------------------
user = userdata.g.get_user()


# -----------------------------
# CACHE HELPERS
# -----------------------------
def load_cache():
    if not os.path.exists(CACHE_FILE):
        return None
    try:
        with open(CACHE_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return None


def save_cache(data):
    with open(CACHE_FILE, "w") as f:
        json.dump(data, f)


def is_stale(cache):
    # if not cache or "timestamp" not in cache:
    # return True
    # return (time.time() - cache["timestamp"]) > CACHE_TTL
    return True


# -----------------------------
# FAST FETCH (ONLY WHEN NEEDED)
# -----------------------------
def fetch_repo_names():
    return [repo.name for repo in user.get_repos()]


def fetch_repo_objects():
    return list(user.get_repos())


# -----------------------------
# BACKGROUND REFRESH
# -----------------------------
def refresh_cache():
    try:
        repos = fetch_repo_names()
        save_cache({"timestamp": time.time(), "repos": repos})
    except Exception as e:
        # If it fails in the background, we capture the error out here
        with open(DEBUG_LOG_FILE, "a") as log:
            log.write(
                f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Background refresh failed: {e}\n"
            )


def start_background_refresh():
    """Spawns an insulated detached background process to run the cache routine."""
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    # Clone the environment and explicitly add the script folder to PYTHONPATH
    # This prevents the independent sub-process from losing track of `import main`
    env = os.environ.copy()
    env["PYTHONPATH"] = os.path.pathsep.join([script_dir, env.get("PYTHONPATH", "")])

    kwargs = {}
    if os.name == "nt":  # Windows
        kwargs["creationflags"] = (
            subprocess.CREATE_NEW_PROCESS_GROUP | subprocess.DETACHED_PROCESS
        )
    else:  # Linux / macOS
        kwargs["preexec_fn"] = os.setpgrp  # Untethers process group

    # Open log streams so background syntax or import errors can actually be written down
    try:
        log_file = open(DEBUG_LOG_FILE, "a")
    except Exception:
        log_file = subprocess.DEVNULL

    subprocess.Popen(
        [sys.executable, script_path, "--bg-refresh"],
        stdout=log_file,
        stderr=log_file,
        stdin=subprocess.DEVNULL,
        cwd=script_dir,  # Force background thread to evaluate from the code directory
        env=env,  # Pass the fixed paths
        close_fds=True,
        **kwargs,
    )


# -----------------------------
# GET REPOS (CACHE FIRST)
# -----------------------------
def get_repos():
    cache = load_cache()

    # 1. No cache → Fetch synchronously so the user sees results immediately
    if not cache:
        repos = fetch_repo_names()
        save_cache({"timestamp": time.time(), "repos": repos})
        return repos

    # 2. Cache exists but stale → Trigger the detached background runner
    if is_stale(cache):
        start_background_refresh()

    # 3. Return existing cached items instantly
    return cache["repos"]


# -----------------------------
# LIST REPOS
# -----------------------------
def ls_repos():
    try:
        repos = get_repos()

        print()
        print(f"{BLUE}*{'=' * (len(countrepolen) + len(user.login) + 1)}*{RESET}")
        print(f"{BLUE}| Listing repos of  {user.login} |{RESET}")
        print(f"{BLUE}*{'-' * (len(countrepolen) + len(user.login) + 1)}*{RESET}")
        print()

        for name in repos:
            print(f"{BLUE}     {name}{RESET}")

        print()
        print(f"{BLUE}     \033[1mTotal Repos: {len(repos)}{RESET}")
        print()

    except Exception as e:
        print(f"{YELLOW}Error: Unable to list repositories - {e}{RESET}")


# -----------------------------
# LIST INSIDE REPO
# -----------------------------
def ls_inside_repo(lsts):
    try:
        repo_objects = fetch_repo_objects()
        repo_map = {r.name: r for r in repo_objects}
    except Exception as e:
        print(f"{YELLOW}Error loading repos: {e}{RESET}")
        return

    for con in lsts:
        filecnt = 0
        dircnt = 0

        try:
            if con not in repo_map:
                raise UnknownObjectException(None, 404, "Repository not found")

            repo = repo_map[con]

            print()
            print(f"{BLUE}*{'=' * (len(reponaming) + len(con) + 1)}*{RESET}")
            print(f"{BLUE}| Listing contents of   {con} |{RESET}")
            print(f"{BLUE}*{'-' * (len(reponaming) + len(con) + 1)}*{RESET}")
            print()

            contents = repo.get_contents("")

            if not contents:
                print(f"{YELLOW} Warning: Repository '{con}' is empty.{RESET}")
                continue

            while contents:
                item = contents.pop(0)

                if item.type == "dir":
                    dircnt += 1
                    print(f"{BLUE}      {item.path}/ {RESET}")
                else:
                    filecnt += 1
                    print(f"{GREEN}      {item.path} {RESET}")

            print()
            print(f"{BLUE}      Dir: {dircnt} {GREEN}  File: {filecnt}{RESET}")
            print()

        except UnknownObjectException:
            print(f"\n{YELLOW} Warning!: Repository '{con}' not found! {RESET}")

        except GithubException as e:
            print(f"\n{YELLOW} GitHub error on '{con}' - {e}{RESET}")

        except Exception as e:
            print(f"\n{YELLOW} Unexpected error for '{con}' - {e}{RESET}")


# -----------------------------
# MAIN ENTRYPOINT
# -----------------------------
if __name__ == "__main__":
    args = sys.argv[1:]

    # Catch background loop immediately before anything runs
    if "--bg-refresh" in args:
        try:
            refresh_cache()
        except Exception as e:
            with open(DEBUG_LOG_FILE, "a") as log:
                log.write(
                    f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Core main loop exception: {e}\n"
                )
        sys.exit(0)

    # Standard CLI usage
    if len(args) > 0:
        ls_inside_repo(args)
    else:
        ls_repos()
