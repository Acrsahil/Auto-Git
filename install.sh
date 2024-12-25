#!/bin/bash

CURRENT_SHELL=$(basename $SHELL)
ALIAS_NAME_CREATE="gmkdir"
ALIAS_NAME_DELETE="delrepo"
CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
KEY_FILE="$CURRENT_PATH/mykey.txt"
MAN_PAGE_FILE="$CURRENT_PATH/githubauto.1"
MAN_DIR="/usr/local/share/man/man1"

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
  local alias_name=$2
  local alias_command=$3

  if [ -w "$config_file" ]; then
    if grep -q "alias $alias_name=" "$config_file"; then
      echo "Alias '$alias_name' already exists in $config_file."
    else
      echo "alias $alias_name='$alias_command'" >> "$config_file"
      echo "Alias '$alias_name' created in $config_file."
    fi
  else
    echo "Permission denied to write to $config_file. Please check permissions."
  fi
}

# Function to set up the alias for creating repositories
setup_create_alias() {
  local create_command="source $VENV_DIR/bin/activate && pwd | python $CURRENT_PATH/getpath.py && python $CURRENT_PATH/main.py"
  add_alias "$SHELL_RC" "$ALIAS_NAME_CREATE" "$create_command"
}

# Function to set up the alias for deleting repositories
setup_delete_alias() {
  local delete_command="source $VENV_DIR/bin/activate && python $CURRENT_PATH/deleterepo.py"
  add_alias "$SHELL_RC" "$ALIAS_NAME_DELETE" "$delete_command"
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

  setup_create_alias
  setup_delete_alias
}

# Function to set up the man page
setup_man_page() {
  # Check if the man page already exists in the man directory
  if [ -f "$MAN_DIR/githubauto.1" ]; then
    echo "Man page already exists. Skipping setup."
  else
    if [ -f "$MAN_PAGE_FILE" ]; then
      echo "Setting up the man page..."
      sudo cp "$MAN_PAGE_FILE" "$MAN_DIR/"
      sudo mandb
    else
      echo "Man page file 'githubauto.1' not found. Skipping."
    fi
  fi
}

# Main function to orchestrate the setup
main() {
  setup_virtualenv
  setup_key_file
  setup_shell_config
  setup_man_page
  echo "All the Setup is done !"
}

# Run the main function
main
