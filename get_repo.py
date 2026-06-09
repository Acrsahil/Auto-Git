from github.GithubException import GithubException, UnknownObjectException
import main
import os
import json
import time
import threading

userdata = main.user_cread()

# -----------------------------
# CONFIG
# -----------------------------
CACHE_FILE = os.path.expanduser("~/.gh_repo_cache.json")
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
    with open(CACHE_FILE, "r") as f:
        return json.load(f)

def save_cache(data):
    with open(CACHE_FILE, "w") as f:
        json.dump(data, f)

def is_stale(cache):
    return not cache or (time.time() - cache["timestamp"] > CACHE_TTL)

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
        save_cache({
            "timestamp": time.time(),
            "repos": repos
        })
    except Exception as e:
        print(f"⚠ Background refresh failed: {e}")

def start_background_refresh():
    thread = threading.Thread(target=refresh_cache)
    thread.daemon = True
    thread.start()

# -----------------------------
# GET REPOS (CACHE FIRST, NO EXTRA API CALLS HERE)
# -----------------------------
def get_repos():
    cache = load_cache()

    # 1. No cache → fetch once
    if not cache:
        repos = fetch_repo_names()
        save_cache({
            "timestamp": time.time(),
            "repos": repos
        })
        return repos

    # 2. Return cached data immediately (FAST)
    repos = cache["repos"]

    # 3. Only trigger refresh in background (NO blocking API call here)
    if is_stale(cache):
        start_background_refresh()

    return repos

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
# LIST INSIDE REPO (NO EXTRA USER.get_repos CALL)
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
# MAIN
# -----------------------------
if __name__ == "__main__":
    lsts = main.sys.argv[1:]

    if len(lsts) > 0:
        ls_inside_repo(lsts)
    else:
        ls_repos()