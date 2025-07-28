from github.GithubException import GithubException

import main

userdata = main.user_cread()
# Get the repository names from command-line arguments
if len(main.sys.argv) < 2:
    print("Please provide the repository names to delete.")
    main.sys.exit(1)

lsts = main.sys.argv[1:]


# Attempt to delete the specified repositories
for repo_name in lsts:
    try:
        # Get the repository
        repo = userdata.g.get_user().get_repo(repo_name)
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
