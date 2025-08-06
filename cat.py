import os
import sys

from github import Auth, Github

reponaming = " Listing contents of   "
countrepolen = " Listing repos of  "
warninglen = " Warning!: Repository not found! "

maindir = os.path.dirname(os.path.abspath(__file__))

# Read the token from the file
try:
    with open(f"{maindir}/.secure_keys/mykey.txt", "r") as file:
        key = file.read().strip()
except FileNotFoundError:
    print(
        "\033[93mError: Token file 'mykey.txt' not found.\033[0m"
    )  # Yellow text for error
    sys.exit(1)

auth = Auth.Token(key)
g = Github(auth=auth)
user = g.get_user()

# Color codes
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"
BLUE = "\033[94m"


# Take repo name from command line
if len(sys.argv) < 2:
    print(f"{YELLOW}Usage: python3 {sys.argv[0]} <repo_name>{RESET}")
    sys.exit(1)

repo_name = sys.argv[1]
repo_full_name = f"{user.login}/{repo_name}"

# Now get that repo
try:
    repo = g.get_repo(repo_full_name)
except:
    print(f"{YELLOW}{warninglen} '{repo_full_name}'{RESET}")
    sys.exit(1)

# Fetch the file content
file_content = repo.get_contents(f"{sys.argv[2]}")
content = file_content.decoded_content.decode()
print(content)


# Main logic
