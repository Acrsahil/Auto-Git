#!/bin/bash

# Secure token read
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_FILE="$SCRIPT_DIR/.secure_keys/mykey.txt"

if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Token file not found at: $KEY_FILE"
    exit 1
fi

token=$(<"$KEY_FILE")
username="Acrsahil"

# Prompt user for commit message
read -rp "Enter your commit message: " commit_message

# Add and commit
git add .
git commit -m "$commit_message"

# Build remote URL with username and token
remote_url=$(git remote get-url origin)

if [[ "$remote_url" != https://* ]]; then
    echo "❌ Remote must be HTTPS for token-based push."
    exit 1
fi

# Inject username and token into remote URL
token_url="${remote_url/https:\/\//https:\/\/$username:$token@}"

# Push
if git push "$token_url" HEAD:main; then
    echo "✅ Changes pushed securely to main!"
else
    echo "❌ Push failed. Invalid token or permission issue."
fi
