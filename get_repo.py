from github.GithubException import GithubException, UnknownObjectException
import main
import os
import json
import time
import threading

userdata = main.user_cread()

# -----------------------------
# CACHE CONFIG
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
# GITHUB USER (reuse once)
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

def repo_changed(cache, current_repos):
    if not cache:
        return True
    return set(cache.get("repos", [])) != set(current_repos)

# -----------------------------
# FAST FETCH (light API call)
# -----------------------------
def fetch_repo_names():
    return [repo.name for repo in user.get_repos()]

# -----------------------------
# BACKGROUND REFRESH
# -----------------------------
def refresh_cache():
    try:
        # print("\n🔄 Background sync started...")

        repos = fetch_repo_names()

        save_cache({
            "timestamp": time.time(),
            "repos": repos
        })

        print("✔ Cache updated in background\n")

    except Exception as e:
        print(f"⚠ Background refresh failed: {e}")

def start_background_refresh():
    thread = threading.Thread(target=refresh_cache)
    thread.daemon = True
    thread.start()

# -----------------------------
# GET REPOS (STABLE + SWR MODEL)
# -----------------------------
def get_repos():
    cache = load_cache()

    # 1. If cache exists → return immediately (FAST PATH)
    if cache:
        repos = cache["repos"]

        # 2. check if refresh needed
        if is_stale(cache):
            start_background_refresh()
        else:
            # optional change detection (cheap API call avoided here)
            start_background_refresh()

        return repos

    # 3. first run → must fetch
    repos = fetch_repo_names()

    save_cache({
        "timestamp": time.time(),
        "repos": repos
    })

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
# LIST INSIDE REPO (OPTIMIZED)
# -----------------------------
def ls_inside_repo(lsts):
    repo_map = {r.name: r for r in user.get_repos()}

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
            print(f"{YELLOW}*{'-' * (len(warninglen) + len(con) + 1)}*{RESET}")

        except GithubException as e:
            if e.status == 404 and "empty" in str(e.data).lower():
                print(f"\n{YELLOW} Warning!: Repository '{con}' is empty!{RESET}")
            else:
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