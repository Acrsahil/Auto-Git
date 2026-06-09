import time
import webbrowser
import requests
import os
import sys
from github import Github
from github.Auth import Token

CLIENT_ID = "Ov23lieCNiZfxauy62Nh"
TOKEN_FILE = os.path.expanduser("~/.gmkdir_token")
maindir = os.path.dirname(os.path.abspath(__file__))


# -----------------------------
# DEVICE FLOW LOGIN
# -----------------------------
def github_device_login():
    res = requests.post(
        "https://github.com/login/device/code",
        data={
            "client_id": CLIENT_ID,
            "scope": "repo delete_repo",
        },
        headers={"Accept": "application/json"},
    )

    data = res.json()

    device_code = data["device_code"]
    user_code = data["user_code"]
    verification_uri = data["verification_uri"]
    interval = data.get("interval", 5)

    print("\nOpen:", verification_uri)
    print("Code:", user_code)

    webbrowser.open(verification_uri)

    # poll for token
    while True:
        time.sleep(interval)

        token_res = requests.post(
            "https://github.com/login/oauth/access_token",
            headers={"Accept": "application/json"},
            data={
                "client_id": CLIENT_ID,
                "device_code": device_code,
                "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
            },
        )

        result = token_res.json()

        if "access_token" in result:
            token = result["access_token"]
            break

        if result.get("error") == "authorization_pending":
            continue

        raise Exception(result)

    # save token
    os.makedirs(os.path.dirname(TOKEN_FILE), exist_ok=True)

    with open(TOKEN_FILE, "w") as f:
        f.write(token)

    print("\n✓ Login successful")
    return token


# -----------------------------
# TOKEN LOADER
# -----------------------------
def get_token():
    if os.path.exists(TOKEN_FILE):
        return open(TOKEN_FILE).read().strip()

    return github_device_login()


# -----------------------------
# PYGITHUB WRAPPER (YOUR METHOD)
# -----------------------------
def user_cread():
    token = get_token()

    auth = Token(token)
    g = Github(auth=auth)
    user = g.get_user()

    return type("GitData", (), {"user": user, "g": g})()


# -----------------------------
# TEST
# -----------------------------
if __name__ == "__main__":
    data = user_cread()

    print("Logged in as:", data.user.login)