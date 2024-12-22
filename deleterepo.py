import os
import sys
from github import Github
from github import Auth

# Get the repository name from command-line arguments
if len(sys.argv) < 2:
    print("Please provide the repository name to delete.")
    sys.exit(1)

delete = sys.argv[1]  # The first argument passed is the repo name
print(f"Attempting to delete repository: {delete}")

maindir = os.path.dirname(os.path.abspath(__file__))
maindir = maindir.strip()

# Read the token file
with open(f"{maindir}/mykey.txt", "r") as file:
    key = file.read().strip()

auth = Auth.Token(key)

# Connect to GitHub
g = Github(auth=auth)

# Get the repository and delete it
repo = g.get_user().get_repo(delete)
repo.delete()

print(f"Repository '{delete}' deleted successfully!")
