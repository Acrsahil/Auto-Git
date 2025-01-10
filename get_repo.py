import os
import sys
from github import Github
from github import Auth
from github.GithubException import UnknownObjectException

lsts = []

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


def ls_inside_repo(lsts):
    for con in lsts:
        try:
            mycontent = g.get_user().get_repo(con)
            print(
                f"\n{GREEN}*==============================================================*{RESET}"
            )
            print(f"{GREEN} Listing contents of '{con}' repo:{RESET}")
            print(
                f"{GREEN}*--------------------------------------------------------------*{RESET}"
            )
            print()
            contents = mycontent.get_contents("")
            while contents:
                file_content = contents.pop(0)
                if file_content.type == "dir":
                    print(f"{BLUE}      {file_content.path}/ {RESET}")
                else:
                    print(f"{GREEN}      {file_content.path} {RESET}")
        except UnknownObjectException:
            print(
                f"\n{YELLOW} Warning!: Repository '{con}' not found in your GitHub account.{RESET}"
            )
            print(
                f"{YELLOW}*--------------------------------------------------------------*{RESET}"
            )
        except Exception as e:
            print(
                f"\n{YELLOW} Warning!: An unexpected error occurred while accessing '{con}' - {e}{RESET}"
            )
            print(
                f"{YELLOW}*--------------------------------------------------------------*{RESET}"
            )


def ls_repos():
    try:
        myrepos = g.get_user().get_repos()
        print()
        print(
            f"{GREEN}*==============================================================*{RESET}"
        )
        print(f"{GREEN} Listing repos of {user.login}{RESET}")
        print(
            f"{GREEN}*--------------------------------------------------------------*{RESET}"
        )
        print()
        for repo in myrepos:
            print(f"{GREEN}     {repo.name}{RESET}")
    except Exception as e:
        print(f"{YELLOW}Error: Unable to list repositories - {e}{RESET}")


# Main logic
lsts = sys.argv[1:]

if len(lsts) > 0:
    ls_inside_repo(lsts)
else:
    ls_repos()
