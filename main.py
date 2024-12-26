import os
import sys
import subprocess
from github import Github

# Check if repository name is provided as a command-line argument
if len(sys.argv) < 2:
    print("Please provide the repository name.")
    sys.exit(1)

name = sys.argv[1]  # Get the repository name from the command-line arguments
print(f"Repository Name: {name}")

# Get the main directory of the script
maindir = os.path.dirname(os.path.abspath(__file__))

maindir = maindir.strip()

# Read the path from 'path.txt'
with open(f"{maindir}/path.txt", "r") as file:
    path = file.read().strip()

# Create a new directory for the repository
path = f"{path}/{name}"
os.system(f"mkdir -p {path}")

# Read the token from 'mykey.txt'
with open(f"{maindir}/mykey.txt", "r") as file:
    key = file.read().strip()

# Authenticate with GitHub
auth = Auth.Token(key)
g = Github(auth=auth)

# Create the repository on GitHub
user = g.get_user()
repo = user.create_repo(name)

# Initialize the git repository locally and set up the remote
os.system(
    f"cd {path} && git init && git remote add origin git@github.com:{user.login}/{name}.git && git branch -M main && git status"
)

print(f"Repository '{name}' created successfully on GitHub and initialized locally!")





