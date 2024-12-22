#!/bin/bash

CURRENT_SHELL=$(basename $SHELL)
ALIAS_NAME="gmkdir"
CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
KEY_FILE="$CURRENT_PATH/mykey.txt"

# Function to set up the virtual environment
setup_virtualenv() {
  if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment 'myenv' not found. Creating it..."
    python3 -m venv "$VENV_DIR"
    echo "Virtual environment 'myenv' created."

    echo "Installing required packages..."
    source "$VENV_DIR/bin/activate"
    pip install PyGithub
    deactivate
    echo "PyGithub installed in 'myenv'."
  else
    echo "Virtual environment 'myenv' already exists."
  fi
}

# Function to check for and create the key file
setup_key_file() {
  if [ ! -f "$KEY_FILE" ]; then
    echo "File 'mykey.txt' not found. Please enter your key:"
    read -r user_key
    echo "$user_key" > "$KEY_FILE"
    echo "Key saved to 'mykey.txt'."
  else
    echo "Key file 'mykey.txt' already exists."
  fi
}

# Function to add an alias to the shell configuration file
add_alias() {
  local config_file=$1
  if [ -w "$config_file" ]; then
    if grep -q "alias $ALIAS_NAME=" "$config_file"; then
      echo "Alias '$ALIAS_NAME' already exists in $config_file."
    else
      echo "alias $ALIAS_NAME='source $VENV_DIR/bin/activate && pwd | python $CURRENT_PATH/getpath.py && python $CURRENT_PATH/main.py'" >> "$config_file"
      echo "Alias '$ALIAS_NAME' created in $config_file."
    fi
  else
    echo "Permission denied to write to $config_file. Please check permissions."
  fi
}

# Function to determine the appropriate shell configuration file
setup_shell_config() {
  if [[ $CURRENT_SHELL == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ $CURRENT_SHELL == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
  else
    echo "Unsupported shell ($CURRENT_SHELL). Exiting."
    exit 1
  fi

  if ! grep -qF "alias $ALIAS_NAME=" "$SHELL_RC"; then
    add_alias "$SHELL_RC"
  else
    echo "Alias '$ALIAS_NAME' already exists in $SHELL_RC."
  fi
}

# Main function to orchestrate the setup
main() {
  setup_virtualenv
  setup_key_file
  setup_shell_config
}

# Run the main function
main
