from github.GithubException import GithubException
from pathlib import Path
import os


import main
userdata = main.user_cread()
# Get the repository names from command-line arguments


parent_dir = Path(__file__).resolve().parent

if len(main.sys.argv) < 2:
    print("Please provide the repository names to delete.")
    main.sys.exit(1)

lsts = main.sys.argv[1:]


content = ""
with open(f"{parent_dir}/path.txt","r") as f:
    content = f.read()
    content+='/'
    print(content)


dir_path = content

def delete_local_file(file_name,dir_path):
    for file in Path(dir_path).iterdir():
        if file.is_file() and file.name == file_name:
            file.unlink()









    






# # Attempt to delete the specified repositories

for repo_name in lsts:
    try:
        # Get the repository
        repo = userdata.g.get_user().get_repo(repo_name)
        confirm = input(f"Delete '{repo_name}'? [y/N]:")
        if confirm.lower() == 'y' or confirm.lower == "yes":
        # Delete the repository
            repo.delete()
            delete_local_file(repo_name,dir_path)
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
