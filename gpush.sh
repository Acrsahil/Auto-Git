#!/bin/bash

# Secure token read
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
key=$(<"$SCRIPT_DIR/.secure_keys/mykey.txt")

# Prompt user for commit message
echo "Enter your commit message:"
read commit_message

# Add and commit
git add .
git commit -m "$commit_message"

# Push using token temporarily
remote_url=$(git remote get-url origin)
token_url="${remote_url/https:\/\//https:\/\/}"

git push "$token_url" HEAD:main

# Confirm
echo "✅ Changes pushed securely to main!"
