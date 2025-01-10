import os
import sys
from github import Github
from github import Auth

lsts = []


def ls_inside_repo(lsts):
    for con in lsts:
        mycontent = g.get_user().get_repo(con)
        contents = mycontent.get_contents("")
        while contents:
            file_content = contents.pop(0)
            if file_content.type == "dir":
                print(f"{file_content.path}/")
            else:
                print(file_content.path)


def ls_repos():
    myrepos = g.get_user().get_repos()
    for repo in myrepos:
        print(repo.name)


# Get the directory of the current script
maindir = os.path.dirname(os.path.abspath(__file__))

# Read the token from the file
try:
    with open(f"{maindir}/mykey.txt", "r") as file:
        key = file.read().strip()
except FileNotFoundError:
    print("Error: Token file 'mykey.txt' not found.")
    sys.exit(1)

# Authenticate with GitHub
auth = Auth.Token(key)
g = Github(auth=auth)


lsts = sys.argv[1:]


if len(lsts) > 0:
    ls_inside_repo(lsts)
else:
    ls_repos()
