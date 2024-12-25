import os
import sys
from github import Github
from github import Auth
from github.GithubException import GithubException

# Get the repository names from command-line arguments
if len(sys.argv) < 2:
    print("Please provide the repository names to delete.")
    sys.exit(1)

lsts = sys.argv[1:]

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

# Attempt to delete the specified repositories
for repo_name in lsts:
    try:
        # Get the repository
        repo = g.get_user().get_repo(repo_name)
        # Delete the repository
        repo.delete()
        print(f"The repository '{repo_name}' was deleted successfully!")
    except GithubException as e:
        if e.status == 404:
            print(f"Error: The repository '{repo_name}' was not found.")
        elif e.status == 403:
            print(f"Error: Permission denied to delete the repository '{repo_name}'.")
        else:
            print(f"An unexpected error occurred while deleting '{repo_name}': {e}")
    except Exception as e:
        print(f"An error occurred while processing '{repo_name}': {e}")
