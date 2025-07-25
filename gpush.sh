#!/bin/bash

# === Securely read token from tool's .secure_keys directory ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_FILE="$SCRIPT_DIR/.secure_keys/mykey.txt"

if [ ! -f "$KEY_FILE" ]; then
    echo "❌ Token file not found at: $KEY_FILE"
    echo "🔑 Please run setup_key_file() first."
    exit 1
fi

key=$(<"$KEY_FILE")

# === Prompt for commit message ===
read -rp "Enter your commit message: " commit_message

# === Git add, commit ===
git add .
git commit -m "$commit_message"

# === Temporarily use token to push ===
remote_url=$(git remote get-url origin)

if [[ "$remote_url" != https://* ]]; then
    echo "❌ Remote is not using HTTPS. Token-based push won't work."
    echo "💡 Use SSH instead or reset remote with:"
    echo "    git remote set-url origin https://github.com/USERNAME/REPO.git"
    exit 1
fi

# Inject token into HTTPS URL
token_url="${remote_url/https:\/\//https:\/\/$key@}"

# === Push securely ===
if git push "$token_url" HEAD:main; then
    echo "✅ Changes pushed securely to main!"
else
    echo "❌ Push failed. Check your token or repo access."
fi
