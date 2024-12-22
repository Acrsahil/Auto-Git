#!/bin/bash

CURRENT_SHELL=$(basename $SHELL)
ALIAS_NAME="gmkdir"

# Get the current directory of the script, excluding the file name
CURRENT_PATH=$(dirname "$(realpath "$0")")

add_alias() {
  local config_file=$1
  if [ -w "$config_file" ]; then
    # Check if the alias already exists
    if grep -q "alias $ALIAS_NAME=" "$config_file"; then
      echo "Alias '$ALIAS_NAME' already exists in $config_file."
    else
      echo "alias $ALIAS_NAME='source $CURRENT_PATH/myenv/bin/activate && pwd | python $CURRENT_PATH/getpath.py && python $CURRENT_PATH/main.py'" >> "$config_file"
      echo "Alias '$ALIAS_NAME' created in $config_file."
    fi
  else
    echo "Permission denied to write to $config_file. Please check permissions."
  fi
}

# Print the name of the shell

# Determine the appropriate shell configuration file
if [[ $CURRENT_SHELL == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ $CURRENT_SHELL == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "Unsupported shell ($CURRENT_SHELL). Exiting."
    exit 1
fi

# Check if the alias already exists in the configuration file
if ! grep -qF "alias $ALIAS_NAME=" "$SHELL_RC"; then
    add_alias "$SHELL_RC"
else
    echo "Alias '$ALIAS_NAME' already exists in $SHELL_RC"
fi
