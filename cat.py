import os
import sys

from github import Auth, Github

reponaming = " Listing contents of   "
countrepolen = " Listing repos of  "
warninglen = " Warning!: Repository not found! "

maindir = os.path.dirname(os.path.abspath(__file__))

# Read the token from the file
try:
    with open(f"{maindir}/mykey.txt", "r") as file:
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


lsts = sys.argv[1:]
print(lsts)
repo = g.get_repo(f"{user.login}/Auto-Git")

# Fetch the file content
file_content = repo.get_contents("install.sh")

content = file_content.decoded_content.decode()
print(content)


# Main logic
