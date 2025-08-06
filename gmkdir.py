import main

userdata = main.user_cread()

# Check if repository name is provided as a command-line argument
if len(main.sys.argv) < 2:
    print("Please provide the repository name.")
    main.sys.exit(1)

# Get the repository name from the command-line arguments
name = main.sys.argv[1]
print(f"Repository Name: {name}")

# Get the main directory of the script
maindir = main.maindir.strip()

# Read the path from 'path.txt'
with open(f"{maindir}/path.txt", "r") as file:
    path = file.read().strip()

# Create a new directory for the repository
path = f"{path}/{name}"
main.os.system(
    f"mkdir -p {path} && touch {path}/README.md && cp {maindir}/exreadme.md {
        path
    }/README.md && touch {path}/.gitignore"
)


# Create the repository on GitHub
user = userdata.g.get_user()
repo = user.create_repo(name)


contributorsLink = f"https://github.com/{user.login}/{name}/graphs/contributors"
starLink = f"https://github.com/{user.login}/{name}/stargazers"
forkLink = f"https://github.com/{user.login}/{name}/forks"
licenseLink = f"https://github.com/{user.login}/{name}/blob/main/LICENSE"

contributorsBadgeLink = f"https://img.shields.io/github/contributors/{user.login}/{
    name
}?style=for-the-badge"
starBadgeLink = (
    f"https://img.shields.io/github/stars/{user.login}/{name}?style=for-the-badge"
)
forkBadgeLink = f"https://img.shields.io/github/forks/{user.login}/{
    name
}?style=for-the-badge&color=gold"
licenseBadgeLink = f"https://img.shields.io/github/license/{user.login}/{
    name
}?style=for-the-badge&color=purple"


gitCloneLink = f"git clone https://github.com/{user.login}/{name}"
cdPath = f"cd {name}"

with open(f"{path}/README.md", "r") as file:
    content = file.read().strip()
    content = content.replace("@18", name)
    content = content.replace("@auth", user.name)
    content = content.replace("@1", contributorsLink)
    content = content.replace("@2", starLink)
    content = content.replace("@3", forkLink)
    content = content.replace("@4", licenseLink)
    content = content.replace("@one", contributorsBadgeLink)
    content = content.replace("@two", starBadgeLink)
    content = content.replace("@three", starBadgeLink)
    content = content.replace("@four", licenseBadgeLink)
    content = content.replace("git_clone_Repository_Link", gitCloneLink)
    content = content.replace("cd_Project_Folder", cdPath)

# Step 2: Write the modified content back to the file
with open(f"{path}/README.md", "w") as file:
    file.write(content)

# Initialize the git repository locally and set up the remote
repo_url = f"https://github.com/{user.login}/{name}.git"
main.os.system(
    f"cd {path} && git init && git remote add origin {repo_url} && git branch -M main"
)
with open(f"{maindir}/changepath.sh", "w") as file:
    file.write(f"cd {path}")


print(f"Repository '{name}' created successfully on GitHub and initialized locally!")
