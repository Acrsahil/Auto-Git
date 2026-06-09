from github.GithubException import GithubException
from pathlib import Path
import os
import shutil


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

def delete_local_file(dir_name,dir_path):
    for dir in Path(dir_path).iterdir():
        if dir.is_dir() and dir.name == dir_name and dir.exists():
            deleted_dir_name = dir.name
            shutil.rmtree(dir)
            print(f"{deleted_dir_name}/ is deleted sucessfully!")









    

# delete_local_file("broishero",dir_path)





# # Attempt to delete the specified repositories

for repo_name in lsts:
    try:
        # Get the repository
        repo_name = repo_name.replace('/','')

        confirm = input(f"Delete '{repo_name}/'? [y/N]:")
        if confirm.lower() == 'y' or confirm.lower == "yes":
            delete_local_file(repo_name,dir_path)
            repo = userdata.g.get_user().get_repo(repo_name)
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
