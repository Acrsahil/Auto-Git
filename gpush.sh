#!/bin/bash

# Prompt user for commit message
echo "Enter your commit message:"
read commit_message

# Run Git commands
git add .
git commit -m "$commit_message"
git push -u origin main

# Confirm completion
echo "Changes have been pushed to the main branch!"

