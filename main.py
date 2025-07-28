import os
import sys
from github import Github
from github.Auth import Token

maindir = os.path.dirname(os.path.abspath(__file__))
def user_cread():

    # Read the token from the file
    try:
        with open(f"{maindir}/.secure_keys/mykey.txt", "r") as file:
            key = file.read().strip()
    except FileNotFoundError:
        print("\033[93mError: Token file 'mykey.txt' not found.\033[0m")
        sys.exit(1)

    auth = Token(key)
    g = Github(auth=auth)
    user = g.get_user()
    return type("GitData", (), {"user": user, "g": g})()


if __name__ == "__main__":
    user_cread()
